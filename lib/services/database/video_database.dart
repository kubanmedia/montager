import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:injectable/injectable.dart';

part 'video_database.g.dart';

// Data class representing a video frame/scene with its embedding
@DataClassName("VideoEmbedding")
class VideoEmbeddings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get videoPath => text().withLength(min: 1, max: 1024)();
  IntColumn get frameNumber => integer()();
  RealColumn get timestampSeconds => real()();
  BlobColumn get embedding => blob()(); // Store embedding vectors
  TextColumn get description => text().withLength(max: 500)();
  TextColumn get objects => text().withLength(max: 500)(); // JSON array of detected objects
  TextColumn get scene => text().withLength(max: 100)();
  RealColumn get qualityScore => real()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}

// Data class for video metadata and processing status
@DataClassName("VideoMetadata")
class VideoMetadataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get videoPath => text().withLength(min: 1, max: 1024)();
  RealColumn get durationSeconds => real()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextColumn get format => text().withLength(max: 50)();
  TextColumn get codec => text().withLength(max: 50)();
  RealColumn get frameRate => real()();
  IntColumn get totalFrames => integer()();
  DateTimeColumn get processedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  BoolColumn get isProcessed =>
      boolean().withDefault(const Constant(false))();
}

// Data class for storing search queries and results for learning
@DataClassName("SearchQuery")
class SearchQueryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get queryText => text().withLength(min: 1, max: 500)();
  BlobColumn get queryEmbedding => blob()();
  // Stored as JSON-encoded text (nullable); replaces the old
  // non-existent integerArrayList column type.
  TextColumn get resultIds => text().nullable()();
  IntColumn get resultCount => integer()();
  DateTimeColumn get searchedAt =>
      dateTime().clientDefault(() => DateTime.now())();
}

// The actual database implementation
@DriftDatabase(tables: [VideoEmbeddings, VideoMetadataTable, SearchQueryTable])
@LazySingleton(as: AppDatabase)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase.getInstance() => _instance;

  static LazyDatabase _openConnection() {
    // sqlite3 via FFI isn't web-compatible, so use an in-memory DB on web.
    if (kIsWeb) {
      return LazyDatabase(() async => NativeDatabase.memory());
    } else {
      return LazyDatabase(() async {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'video_embeddings.db'));
        return NativeDatabase(file);
      });
    }
  }

  @override
  int get schemaVersion => 1;

  // DAO-like methods for video embeddings
  Future<void> insertVideoEmbedding(VideoEmbeddingsCompanion embedding) async {
    await into(videoEmbeddings).insert(embedding);
  }

  Future<List<VideoEmbedding>> getVideoEmbeddingsByPath(String videoPath) async {
    return (select(videoEmbeddings)
          ..where((tbl) => tbl.videoPath.equals(videoPath)))
        .get();
  }

  Future<List<VideoEmbedding>> getRecentEmbeddings({int limit = 100}) async {
    return (select(videoEmbeddings)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> deleteVideoEmbeddingsByPath(String videoPath) async {
    await (delete(videoEmbeddings)
          ..where((tbl) => tbl.videoPath.equals(videoPath)))
        .go();
  }

  // DAO-like methods for video metadata
  Future<void> insertVideoMetadata(VideoMetadataTableCompanion metadata) async {
    await into(videoMetadataTable).insert(metadata);
  }

  Future<VideoMetadata?> getVideoMetadataByPath(String videoPath) async {
    return (select(videoMetadataTable)
          ..where((tbl) => tbl.videoPath.equals(videoPath))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> updateVideoProcessingStatus(String videoPath, bool processed) async {
    await (update(videoMetadataTable)
          ..where((tbl) => tbl.videoPath.equals(videoPath)))
        .write(VideoMetadataTableCompanion(
      isProcessed: Value(processed),
    ));
  }

  // DAO-like methods for search queries
  Future<void> insertSearchQuery(SearchQueryTableCompanion query) async {
    await into(searchQueryTable).insert(query);
  }

  Future<List<SearchQuery>> getRecentSearches({int limit = 20}) async {
    return (select(searchQueryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
          ..limit(limit))
        .get();
  }

  // Vector similarity search (cosine similarity)
  // Note: This is a simplified implementation - in production you'd use specialized vector indexes
  Future<List<VideoEmbedding>> searchSimilarEmbeddings(
      List<double> queryEmbedding, {
        int limit = 10,
        double similarityThreshold = 0.7,
      }) async {
    // For now, we'll do a simple linear scan - in production use proper vector indexing
    final allEmbeddings = await getRecentEmbeddings(limit: 1000);

    // Calculate cosine similarity for each embedding
    final scoredResults = <MapEntry<VideoEmbedding, double>>[];

    for (final embedding in allEmbeddings) {
      try {
        final storedEmbedding = _decodeEmbedding(embedding.embedding);
        final similarity = _cosineSimilarity(queryEmbedding, storedEmbedding);

        if (similarity >= similarityThreshold) {
          scoredResults.add(MapEntry(embedding, similarity));
        }
      } catch (e) {
        // Skip corrupted embeddings
        continue;
      }
    }

    // Sort by similarity (descending) and take top results
    scoredResults.sort((a, b) => b.value.compareTo(a.value));
    return scoredResults.take(limit).map((e) => e.key).toList();
  }

  List<double> _decodeEmbedding(Uint8List bytes) {
    // Simple implementation: assume 32-bit floats
    final float32List = Float32List.view(bytes.buffer);
    return float32List.toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
