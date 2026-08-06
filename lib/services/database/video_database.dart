import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:injectable/injectable.dart';

// Data class representing a video frame/scene with its embedding
@DataClassName("VideoEmbedding")
class VideoEmbeddings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextField get videoPath => text().withLength(min: 1, max: 1024)();
  IntColumn get frameNumber => integer()();
  RealField get timestampSeconds => real()();
  BlobField get embedding => blob().withLength(min: 1, max: 4096)(); // Store embedding vectors
  TextField get description => text().withLength(max: 500)();
  TextField get objects => text().withLength(max: 500)(); // JSON array of detected objects
  TextField get scene => text().withLength(max: 100)();
  RealField get qualityScore => real()();
  DateTime get createdAt => dateTime().clientDefault(() => DateTime.now())();
}

// Data class for video metadata and processing status
@DataClassName("VideoMetadata")
class VideoMetadataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextField get videoPath => text().withLength(min: 1, max: 1024)();
  RealField get durationSeconds => real()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextField get format => text().withLength(max: 50)();
  TextField get codec => text().withLength(max: 50)();
  RealField get frameRate => real()();
  IntColumn get totalFrames => integer()();
  DateTime get processedAt => dateTime().clientDefault(() => DateTime.now())();
  BoolField get isProcessed => boolean().withDefaultConstant(false)();
}

// Data class for storing search queries and results for learning
@DataClassName("SearchQuery")
class SearchQueryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextField get queryText => text().withLength(min: 1, max: 500)();
  BlobField get queryEmbedding => blob().withLength(min: 1, max: 1024)();
  IntArrayList get resultIds => integerArrayList().customConstraint('NULL')();
  IntColumn get resultCount => integer()();
  DateTime get searchedAt => dateTime().clientDefault(() => DateTime.now())();
}

// The actual database implementation
@LazySingleton(as: AppDatabase)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase.getInstance() => _instance;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'video_embeddings.db'));
      return NativeDatabase(file);
    });
  }

  @override
  int get schemaVersion => 1;

  // Table getters
  VideoEmbeddings get videoEmbeddings => VideoEmbeddings();
  VideoMetadataTable get videoMetadata => VideoMetadataTable();
  SearchQueryTable get searchQueries => SearchQueryTable();

  // DAO-like methods for video embeddings
  Future<void> insertVideoEmbedding(VideoEmbeddingCompanion embedding) async {
    await into(videoEmbeddings).insert(embedding);
  }

  Future<List<VideoEmbedding>> getVideoEmbeddingsByPath(String videoPath) async {
    return (select(videoEmbeddings)
          ..where((tbl) => tbl.videoPath.equals(videoPath)))
        .get();
  }

  Future<List<VideoEmbedding>> getRecentEmbeddings({int limit = 100}) async {
    return (select(videoEmbeddings)
          ..orderBy([(t) => t.createdAt.desc()])
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
    await into(videoMetadata).insert(metadata);
  }

  Future<VideoMetadataTableData?> getVideoMetadataByPath(String videoPath) async {
    return (select(videoMetadata)
          ..where((tbl) => tbl.videoPath.equals(videoPath))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> updateVideoProcessingStatus(String videoPath, bool processed) async {
    await (update(videoMetadata)
          ..where((tbl) => tbl.videoPath.equals(videoPath)))
        .write(VideoMetadataTableCompanion(
      isProcessed: Value(processed),
    ));
  }

  // DAO-like methods for search queries
  Future<void> insertSearchQuery(SearchQueryTableCompanion query) async {
    await into(searchQueries).insert(query);
  }

  Future<List<SearchQueryTableData>> getRecentSearches({int limit = 20}) async {
    return (select(searchQueries)
          ..orderBy([(t) => t.searchedAt.desc()])
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
    final scoredResults = <VideoEmbedding, double>[];
    
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