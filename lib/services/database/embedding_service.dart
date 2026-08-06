import 'dart:typed_data';
import 'dart:math';
import 'package:montager/services/database/video_database.dart';
import 'package:montager/services/database/database_module.dart';

/// Service for generating and managing video embeddings for semantic search
class EmbeddingService {
  final AppDatabase _database;
  
  EmbeddingService() : _database = database;

  /// Generates an embedding vector for a given text description
  /// In a real implementation, this would use a text embedding model like:
  /// - Sentence-BERT
  /// - Universal Sentence Encoder
  /// - OpenAI embeddings
  /// - Local alternatives like MiniLM
  Future<List<double>> generateTextEmbedding(String text) async {
    // Placeholder implementation - in reality, call an embedding model
    // For now, return a deterministic hash-based vector for demo purposes
    final hashValues = _stringToHashValues(text);
    final vectorLength = 384; // Common embedding size
    
    // Normalize to unit vector
    final List<double> embedding = List.filled(vectorLength, 0.0);
    for (int i = 0; i < vectorLength; i++) {
      embedding[i] = hashValues[i % hashValues.length] / 255.0 * 2 - 1; // Scale to [-1, 1]
    }
    
    // Normalize
    double norm = 0.0;
    for (final val in embedding) {
      norm += val * val;
    }
    norm = sqrt(norm);
    if (norm > 0) {
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] /= norm;
      }
    }
    
    return embedding;
  }

  /// Generates an embedding vector for image features
  /// In reality, this would use a vision model like CLIP or similar
  Future<List<double>> generateImageEmbedding(Uint8List imageBytes) async {
    // Placeholder implementation
    // In production, use CLIP, DINOv2, or similar vision-language model
    final hashValues = _bytesToHashValues(imageBytes);
    final vectorLength = 512; // Common image embedding size
    
    final List<double> embedding = List.filled(vectorLength, 0.0);
    for (int i = 0; i < vectorLength; i++) {
      embedding[i] = hashValues[i % hashValues.length] / 255.0 * 2 - 1;
    }
    
    // Normalize
    double norm = 0.0;
    for (final val in embedding) {
      norm += val * val;
    }
    norm = sqrt(norm);
    if (norm > 0) {
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] /= norm;
      }
    }
    
    return embedding;
  }

  /// Encodes a list of doubles as bytes for storage in the database
  Uint8List _encodeEmbedding(List<double> embedding) {
    // Convert to Float32List for efficient storage
    final float32List = Float32List.fromList(embedding);
    return Uint8List.view(float32List.buffer);
  }

  /// Decodes bytes back to list of doubles
  List<double> _decodeEmbedding(Uint8List bytes) {
    final float32List = Float32List.view(bytes.buffer);
    return float32List.toList();
  }

  /// Stores a video frame embedding with associated metadata
  Future<void> storeFrameEmbedding({
    required String videoPath,
    required int frameNumber,
    required double timestampSeconds,
    required List<double> embedding,
    required String description,
    required List<String> objects,
    required String scene,
    required double qualityScore,
  }) async {
    final embeddingBytes = _encodeEmbedding(embedding);
    
    await _database.insertVideoEmbedding(
      VideoEmbeddingsCompanion.insert(
        videoPath: videoPath,
        frameNumber: frameNumber,
        timestampSeconds: timestampSeconds,
        embedding: embeddingBytes,
        description: description,
        objects: '[' + objects.map((e) => '"$e"').join(',') + ']',
        scene: scene,
        qualityScore: qualityScore,
      ),
    );
  }

  /// Retrieves stored embedding for a specific frame
  Future<List<double>?> getFrameEmbedding(String videoPath, int frameNumber) async {
    final results = await (select(_database.videoEmbeddings)
          ..where((tbl) => 
            tbl.videoPath.equals(videoPath) & 
            tbl.frameNumber.equals(frameNumber)))
        .get();
    
    if (results.isEmpty) return null;
    
    return _decodeEmbedding(results.first.embedding);
  }

  /// Searches for similar frames using embedding similarity
  Future<List<VideoEmbeddingData>> searchSimilarFrames(
    List<double> queryEmbedding, {
      int limit = 10,
      double similarityThreshold = 0.7,
    }) async {
    return await _database.searchSimilarEmbeddings(
      queryEmbedding,
      limit: limit,
      similarityThreshold: similarityThreshold,
    );
  }

  /// Finds video segments relevant to a text query
  Future<List<VideoEmbeddingData>> searchByText(String queryText, {
      int limit = 20,
      double similarityThreshold = 0.6,
    }) async {
    final queryEmbedding = await generateTextEmbedding(queryText);
    return await searchSimilarFrames(
      queryEmbedding,
      limit: limit,
      similarityThreshold: similarityThreshold,
    );
  }

  /// Gets all embeddings for a specific video
  Future<List<VideoEmbeddingData>> getVideoEmbeddings(String videoPath) async {
    return await _database.getVideoEmbeddingsByPath(videoPath);
  }

  /// Stores video metadata
  Future<void> storeVideoMetadata({
    required String videoPath,
    required double durationSeconds,
    required int width,
    required int height,
    required String format,
    required String codec,
    required double frameRate,
    required int totalFrames,
  }) async {
    await _database.insertVideoMetadata(
      VideoMetadataTableCompanion.insert(
        videoPath: videoPath,
        durationSeconds: durationSeconds,
        width: width,
        height: height,
        format: format,
        codec: codec,
        frameRate: frameRate,
        totalFrames: totalFrames,
      ),
    );
  }

  /// Marks a video as processed
  Future<void> markVideoAsProcessed(String videoPath) async {
    await _database.updateVideoProcessingStatus(videoPath, true);
  }

  /// Checks if a video has been processed
  Future<bool> isVideoProcessed(String videoPath) async {
    final metadata = await _database.getVideoMetadataByPath(videoPath);
    return metadata != null && metadata.isProcessed;
  }

  // Helper methods for generating hash-based embeddings (placeholder)
  List<int> _stringToHashValues(String text) {
    final List<int> values = [];
    for (int i = 0; i < text.length; i++) {
      values.add(text.codeUnitAt(i));
    }
    // Ensure we have enough values
    if (values.isEmpty) values.add(1);
    while (values.length < 10) {
      values.addAll(List.from(values));
    }
    return values.take(10).toList();
  }

  List<int> _bytesToHashValues(Uint8List bytes) {
    final List<int> values = [];
    for (int i = 0; i < bytes.length; i++) {
      values.add(bytes[i]);
    }
    // Ensure we have enough values
    if (values.isEmpty) values.add(1);
    while (values.length < 10) {
      values.addAll(List.from(values));
    }
    return values.take(10).toList();
  }
}