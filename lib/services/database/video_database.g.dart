// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_database.dart';

// ignore_for_file: type=lint
class $VideoEmbeddingsTable extends VideoEmbeddings
    with TableInfo<$VideoEmbeddingsTable, VideoEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _videoPathMeta =
      const VerificationMeta('videoPath');
  @override
  late final GeneratedColumn<String> videoPath = GeneratedColumn<String>(
      'video_path', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1, maxTextLength: 1024),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _frameNumberMeta =
      const VerificationMeta('frameNumber');
  @override
  late final GeneratedColumn<int> frameNumber = GeneratedColumn<int>(
      'frame_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampSecondsMeta =
      const VerificationMeta('timestampSeconds');
  @override
  late final GeneratedColumn<double> timestampSeconds = GeneratedColumn<double>(
      'timestamp_seconds', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _embeddingMeta =
      const VerificationMeta('embedding');
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
      'embedding', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _objectsMeta =
      const VerificationMeta('objects');
  @override
  late final GeneratedColumn<String> objects = GeneratedColumn<String>(
      'objects', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sceneMeta = const VerificationMeta('scene');
  @override
  late final GeneratedColumn<String> scene = GeneratedColumn<String>(
      'scene', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _qualityScoreMeta =
      const VerificationMeta('qualityScore');
  @override
  late final GeneratedColumn<double> qualityScore = GeneratedColumn<double>(
      'quality_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  @override
  List<GeneratedColumn> get $columns => [
        id,
        videoPath,
        frameNumber,
        timestampSeconds,
        embedding,
        description,
        objects,
        scene,
        qualityScore,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_embeddings';
  @override
  VerificationContext validateIntegrity(Insertable<VideoEmbedding> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('video_path')) {
      context.handle(_videoPathMeta,
          videoPath.isAcceptableOrUnknown(data['video_path']!, _videoPathMeta));
    } else if (isInserting) {
      context.missing(_videoPathMeta);
    }
    if (data.containsKey('frame_number')) {
      context.handle(
          _frameNumberMeta,
          frameNumber.isAcceptableOrUnknown(
              data['frame_number']!, _frameNumberMeta));
    } else if (isInserting) {
      context.missing(_frameNumberMeta);
    }
    if (data.containsKey('timestamp_seconds')) {
      context.handle(
          _timestampSecondsMeta,
          timestampSeconds.isAcceptableOrUnknown(
              data['timestamp_seconds']!, _timestampSecondsMeta));
    } else if (isInserting) {
      context.missing(_timestampSecondsMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(_embeddingMeta,
          embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta));
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('objects')) {
      context.handle(_objectsMeta,
          objects.isAcceptableOrUnknown(data['objects']!, _objectsMeta));
    } else if (isInserting) {
      context.missing(_objectsMeta);
    }
    if (data.containsKey('scene')) {
      context.handle(
          _sceneMeta, scene.isAcceptableOrUnknown(data['scene']!, _sceneMeta));
    } else if (isInserting) {
      context.missing(_sceneMeta);
    }
    if (data.containsKey('quality_score')) {
      context.handle(
          _qualityScoreMeta,
          qualityScore.isAcceptableOrUnknown(
              data['quality_score']!, _qualityScoreMeta));
    } else if (isInserting) {
      context.missing(_qualityScoreMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoEmbedding(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      videoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_path'])!,
      frameNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frame_number'])!,
      timestampSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}timestamp_seconds'])!,
      embedding: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}embedding'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      objects: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objects'])!,
      scene: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene'])!,
      qualityScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quality_score'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VideoEmbeddingsTable createAlias(String alias) {
    return $VideoEmbeddingsTable(attachedDatabase, alias);
  }
}

class VideoEmbedding extends DataClass implements Insertable<VideoEmbedding> {
  final int id;
  final String videoPath;
  final int frameNumber;
  final double timestampSeconds;
  final Uint8List embedding;
  final String description;
  final String objects;
  final String scene;
  final double qualityScore;
  final DateTime createdAt;
  const VideoEmbedding(
      {required this.id,
      required this.videoPath,
      required this.frameNumber,
      required this.timestampSeconds,
      required this.embedding,
      required this.description,
      required this.objects,
      required this.scene,
      required this.qualityScore,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['video_path'] = Variable<String>(videoPath);
    map['frame_number'] = Variable<int>(frameNumber);
    map['timestamp_seconds'] = Variable<double>(timestampSeconds);
    map['embedding'] = Variable<Uint8List>(embedding);
    map['description'] = Variable<String>(description);
    map['objects'] = Variable<String>(objects);
    map['scene'] = Variable<String>(scene);
    map['quality_score'] = Variable<double>(qualityScore);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VideoEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return VideoEmbeddingsCompanion(
      id: Value(id),
      videoPath: Value(videoPath),
      frameNumber: Value(frameNumber),
      timestampSeconds: Value(timestampSeconds),
      embedding: Value(embedding),
      description: Value(description),
      objects: Value(objects),
      scene: Value(scene),
      qualityScore: Value(qualityScore),
      createdAt: Value(createdAt),
    );
  }

  factory VideoEmbedding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoEmbedding(
      id: serializer.fromJson<int>(json['id']),
      videoPath: serializer.fromJson<String>(json['videoPath']),
      frameNumber: serializer.fromJson<int>(json['frameNumber']),
      timestampSeconds: serializer.fromJson<double>(json['timestampSeconds']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      description: serializer.fromJson<String>(json['description']),
      objects: serializer.fromJson<String>(json['objects']),
      scene: serializer.fromJson<String>(json['scene']),
      qualityScore: serializer.fromJson<double>(json['qualityScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'videoPath': serializer.toJson<String>(videoPath),
      'frameNumber': serializer.toJson<int>(frameNumber),
      'timestampSeconds': serializer.toJson<double>(timestampSeconds),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'description': serializer.toJson<String>(description),
      'objects': serializer.toJson<String>(objects),
      'scene': serializer.toJson<String>(scene),
      'qualityScore': serializer.toJson<double>(qualityScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VideoEmbedding copyWith(
          {int? id,
          String? videoPath,
          int? frameNumber,
          double? timestampSeconds,
          Uint8List? embedding,
          String? description,
          String? objects,
          String? scene,
          double? qualityScore,
          DateTime? createdAt}) =>
      VideoEmbedding(
        id: id ?? this.id,
        videoPath: videoPath ?? this.videoPath,
        frameNumber: frameNumber ?? this.frameNumber,
        timestampSeconds: timestampSeconds ?? this.timestampSeconds,
        embedding: embedding ?? this.embedding,
        description: description ?? this.description,
        objects: objects ?? this.objects,
        scene: scene ?? this.scene,
        qualityScore: qualityScore ?? this.qualityScore,
        createdAt: createdAt ?? this.createdAt,
      );
  VideoEmbedding copyWithCompanion(VideoEmbeddingsCompanion data) {
    return VideoEmbedding(
      id: data.id.present ? data.id.value : this.id,
      videoPath: data.videoPath.present ? data.videoPath.value : this.videoPath,
      frameNumber:
          data.frameNumber.present ? data.frameNumber.value : this.frameNumber,
      timestampSeconds: data.timestampSeconds.present
          ? data.timestampSeconds.value
          : this.timestampSeconds,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      description:
          data.description.present ? data.description.value : this.description,
      objects: data.objects.present ? data.objects.value : this.objects,
      scene: data.scene.present ? data.scene.value : this.scene,
      qualityScore: data.qualityScore.present
          ? data.qualityScore.value
          : this.qualityScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoEmbedding(')
          ..write('id: $id, ')
          ..write('videoPath: $videoPath, ')
          ..write('frameNumber: $frameNumber, ')
          ..write('timestampSeconds: $timestampSeconds, ')
          ..write('embedding: $embedding, ')
          ..write('description: $description, ')
          ..write('objects: $objects, ')
          ..write('scene: $scene, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      videoPath,
      frameNumber,
      timestampSeconds,
      $driftBlobEquality.hash(embedding),
      description,
      objects,
      scene,
      qualityScore,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoEmbedding &&
          other.id == this.id &&
          other.videoPath == this.videoPath &&
          other.frameNumber == this.frameNumber &&
          other.timestampSeconds == this.timestampSeconds &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.description == this.description &&
          other.objects == this.objects &&
          other.scene == this.scene &&
          other.qualityScore == this.qualityScore &&
          other.createdAt == this.createdAt);
}

class VideoEmbeddingsCompanion extends UpdateCompanion<VideoEmbedding> {
  final Value<int> id;
  final Value<String> videoPath;
  final Value<int> frameNumber;
  final Value<double> timestampSeconds;
  final Value<Uint8List> embedding;
  final Value<String> description;
  final Value<String> objects;
  final Value<String> scene;
  final Value<double> qualityScore;
  final Value<DateTime> createdAt;
  const VideoEmbeddingsCompanion({
    this.id = const Value.absent(),
    this.videoPath = const Value.absent(),
    this.frameNumber = const Value.absent(),
    this.timestampSeconds = const Value.absent(),
    this.embedding = const Value.absent(),
    this.description = const Value.absent(),
    this.objects = const Value.absent(),
    this.scene = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VideoEmbeddingsCompanion.insert({
    this.id = const Value.absent(),
    required String videoPath,
    required int frameNumber,
    required double timestampSeconds,
    required Uint8List embedding,
    required String description,
    required String objects,
    required String scene,
    required double qualityScore,
    this.createdAt = const Value.absent(),
  })  : videoPath = Value(videoPath),
        frameNumber = Value(frameNumber),
        timestampSeconds = Value(timestampSeconds),
        embedding = Value(embedding),
        description = Value(description),
        objects = Value(objects),
        scene = Value(scene),
        qualityScore = Value(qualityScore);
  static Insertable<VideoEmbedding> custom({
    Expression<int>? id,
    Expression<String>? videoPath,
    Expression<int>? frameNumber,
    Expression<double>? timestampSeconds,
    Expression<Uint8List>? embedding,
    Expression<String>? description,
    Expression<String>? objects,
    Expression<String>? scene,
    Expression<double>? qualityScore,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoPath != null) 'video_path': videoPath,
      if (frameNumber != null) 'frame_number': frameNumber,
      if (timestampSeconds != null) 'timestamp_seconds': timestampSeconds,
      if (embedding != null) 'embedding': embedding,
      if (description != null) 'description': description,
      if (objects != null) 'objects': objects,
      if (scene != null) 'scene': scene,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VideoEmbeddingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? videoPath,
      Value<int>? frameNumber,
      Value<double>? timestampSeconds,
      Value<Uint8List>? embedding,
      Value<String>? description,
      Value<String>? objects,
      Value<String>? scene,
      Value<double>? qualityScore,
      Value<DateTime>? createdAt}) {
    return VideoEmbeddingsCompanion(
      id: id ?? this.id,
      videoPath: videoPath ?? this.videoPath,
      frameNumber: frameNumber ?? this.frameNumber,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      embedding: embedding ?? this.embedding,
      description: description ?? this.description,
      objects: objects ?? this.objects,
      scene: scene ?? this.scene,
      qualityScore: qualityScore ?? this.qualityScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (videoPath.present) {
      map['video_path'] = Variable<String>(videoPath.value);
    }
    if (frameNumber.present) {
      map['frame_number'] = Variable<int>(frameNumber.value);
    }
    if (timestampSeconds.present) {
      map['timestamp_seconds'] = Variable<double>(timestampSeconds.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (objects.present) {
      map['objects'] = Variable<String>(objects.value);
    }
    if (scene.present) {
      map['scene'] = Variable<String>(scene.value);
    }
    if (qualityScore.present) {
      map['quality_score'] = Variable<double>(qualityScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoEmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('videoPath: $videoPath, ')
          ..write('frameNumber: $frameNumber, ')
          ..write('timestampSeconds: $timestampSeconds, ')
          ..write('embedding: $embedding, ')
          ..write('description: $description, ')
          ..write('objects: $objects, ')
          ..write('scene: $scene, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VideoMetadataTableTable extends VideoMetadataTable
    with TableInfo<$VideoMetadataTableTable, VideoMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _videoPathMeta =
      const VerificationMeta('videoPath');
  @override
  late final GeneratedColumn<String> videoPath = GeneratedColumn<String>(
      'video_path', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1, maxTextLength: 1024),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _codecMeta = const VerificationMeta('codec');
  @override
  late final GeneratedColumn<String> codec = GeneratedColumn<String>(
      'codec', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _frameRateMeta =
      const VerificationMeta('frameRate');
  @override
  late final GeneratedColumn<double> frameRate = GeneratedColumn<double>(
      'frame_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalFramesMeta =
      const VerificationMeta('totalFrames');
  @override
  late final GeneratedColumn<int> totalFrames = GeneratedColumn<int>(
      'total_frames', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _processedAtMeta =
      const VerificationMeta('processedAt');
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
      'processed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _isProcessedMeta =
      const VerificationMeta('isProcessed');
  @override
  late final GeneratedColumn<bool> isProcessed = GeneratedColumn<bool>(
      'is_processed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_processed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        videoPath,
        durationSeconds,
        width,
        height,
        format,
        codec,
        frameRate,
        totalFrames,
        processedAt,
        isProcessed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_metadata_table';
  @override
  VerificationContext validateIntegrity(Insertable<VideoMetadata> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('video_path')) {
      context.handle(_videoPathMeta,
          videoPath.isAcceptableOrUnknown(data['video_path']!, _videoPathMeta));
    } else if (isInserting) {
      context.missing(_videoPathMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('codec')) {
      context.handle(
          _codecMeta, codec.isAcceptableOrUnknown(data['codec']!, _codecMeta));
    } else if (isInserting) {
      context.missing(_codecMeta);
    }
    if (data.containsKey('frame_rate')) {
      context.handle(_frameRateMeta,
          frameRate.isAcceptableOrUnknown(data['frame_rate']!, _frameRateMeta));
    } else if (isInserting) {
      context.missing(_frameRateMeta);
    }
    if (data.containsKey('total_frames')) {
      context.handle(
          _totalFramesMeta,
          totalFrames.isAcceptableOrUnknown(
              data['total_frames']!, _totalFramesMeta));
    } else if (isInserting) {
      context.missing(_totalFramesMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
          _processedAtMeta,
          processedAt.isAcceptableOrUnknown(
              data['processed_at']!, _processedAtMeta));
    }
    if (data.containsKey('is_processed')) {
      context.handle(
          _isProcessedMeta,
          isProcessed.isAcceptableOrUnknown(
              data['is_processed']!, _isProcessedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoMetadata(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      videoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_path'])!,
      durationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}duration_seconds'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      codec: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codec'])!,
      frameRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}frame_rate'])!,
      totalFrames: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_frames'])!,
      processedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}processed_at'])!,
      isProcessed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_processed'])!,
    );
  }

  @override
  $VideoMetadataTableTable createAlias(String alias) {
    return $VideoMetadataTableTable(attachedDatabase, alias);
  }
}

class VideoMetadata extends DataClass implements Insertable<VideoMetadata> {
  final int id;
  final String videoPath;
  final double durationSeconds;
  final int width;
  final int height;
  final String format;
  final String codec;
  final double frameRate;
  final int totalFrames;
  final DateTime processedAt;
  final bool isProcessed;
  const VideoMetadata(
      {required this.id,
      required this.videoPath,
      required this.durationSeconds,
      required this.width,
      required this.height,
      required this.format,
      required this.codec,
      required this.frameRate,
      required this.totalFrames,
      required this.processedAt,
      required this.isProcessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['video_path'] = Variable<String>(videoPath);
    map['duration_seconds'] = Variable<double>(durationSeconds);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['format'] = Variable<String>(format);
    map['codec'] = Variable<String>(codec);
    map['frame_rate'] = Variable<double>(frameRate);
    map['total_frames'] = Variable<int>(totalFrames);
    map['processed_at'] = Variable<DateTime>(processedAt);
    map['is_processed'] = Variable<bool>(isProcessed);
    return map;
  }

  VideoMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return VideoMetadataTableCompanion(
      id: Value(id),
      videoPath: Value(videoPath),
      durationSeconds: Value(durationSeconds),
      width: Value(width),
      height: Value(height),
      format: Value(format),
      codec: Value(codec),
      frameRate: Value(frameRate),
      totalFrames: Value(totalFrames),
      processedAt: Value(processedAt),
      isProcessed: Value(isProcessed),
    );
  }

  factory VideoMetadata.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoMetadata(
      id: serializer.fromJson<int>(json['id']),
      videoPath: serializer.fromJson<String>(json['videoPath']),
      durationSeconds: serializer.fromJson<double>(json['durationSeconds']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      format: serializer.fromJson<String>(json['format']),
      codec: serializer.fromJson<String>(json['codec']),
      frameRate: serializer.fromJson<double>(json['frameRate']),
      totalFrames: serializer.fromJson<int>(json['totalFrames']),
      processedAt: serializer.fromJson<DateTime>(json['processedAt']),
      isProcessed: serializer.fromJson<bool>(json['isProcessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'videoPath': serializer.toJson<String>(videoPath),
      'durationSeconds': serializer.toJson<double>(durationSeconds),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'format': serializer.toJson<String>(format),
      'codec': serializer.toJson<String>(codec),
      'frameRate': serializer.toJson<double>(frameRate),
      'totalFrames': serializer.toJson<int>(totalFrames),
      'processedAt': serializer.toJson<DateTime>(processedAt),
      'isProcessed': serializer.toJson<bool>(isProcessed),
    };
  }

  VideoMetadata copyWith(
          {int? id,
          String? videoPath,
          double? durationSeconds,
          int? width,
          int? height,
          String? format,
          String? codec,
          double? frameRate,
          int? totalFrames,
          DateTime? processedAt,
          bool? isProcessed}) =>
      VideoMetadata(
        id: id ?? this.id,
        videoPath: videoPath ?? this.videoPath,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        width: width ?? this.width,
        height: height ?? this.height,
        format: format ?? this.format,
        codec: codec ?? this.codec,
        frameRate: frameRate ?? this.frameRate,
        totalFrames: totalFrames ?? this.totalFrames,
        processedAt: processedAt ?? this.processedAt,
        isProcessed: isProcessed ?? this.isProcessed,
      );
  VideoMetadata copyWithCompanion(VideoMetadataTableCompanion data) {
    return VideoMetadata(
      id: data.id.present ? data.id.value : this.id,
      videoPath: data.videoPath.present ? data.videoPath.value : this.videoPath,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      format: data.format.present ? data.format.value : this.format,
      codec: data.codec.present ? data.codec.value : this.codec,
      frameRate: data.frameRate.present ? data.frameRate.value : this.frameRate,
      totalFrames:
          data.totalFrames.present ? data.totalFrames.value : this.totalFrames,
      processedAt:
          data.processedAt.present ? data.processedAt.value : this.processedAt,
      isProcessed:
          data.isProcessed.present ? data.isProcessed.value : this.isProcessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoMetadata(')
          ..write('id: $id, ')
          ..write('videoPath: $videoPath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('format: $format, ')
          ..write('codec: $codec, ')
          ..write('frameRate: $frameRate, ')
          ..write('totalFrames: $totalFrames, ')
          ..write('processedAt: $processedAt, ')
          ..write('isProcessed: $isProcessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, videoPath, durationSeconds, width, height,
      format, codec, frameRate, totalFrames, processedAt, isProcessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoMetadata &&
          other.id == this.id &&
          other.videoPath == this.videoPath &&
          other.durationSeconds == this.durationSeconds &&
          other.width == this.width &&
          other.height == this.height &&
          other.format == this.format &&
          other.codec == this.codec &&
          other.frameRate == this.frameRate &&
          other.totalFrames == this.totalFrames &&
          other.processedAt == this.processedAt &&
          other.isProcessed == this.isProcessed);
}

class VideoMetadataTableCompanion extends UpdateCompanion<VideoMetadata> {
  final Value<int> id;
  final Value<String> videoPath;
  final Value<double> durationSeconds;
  final Value<int> width;
  final Value<int> height;
  final Value<String> format;
  final Value<String> codec;
  final Value<double> frameRate;
  final Value<int> totalFrames;
  final Value<DateTime> processedAt;
  final Value<bool> isProcessed;
  const VideoMetadataTableCompanion({
    this.id = const Value.absent(),
    this.videoPath = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.format = const Value.absent(),
    this.codec = const Value.absent(),
    this.frameRate = const Value.absent(),
    this.totalFrames = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.isProcessed = const Value.absent(),
  });
  VideoMetadataTableCompanion.insert({
    this.id = const Value.absent(),
    required String videoPath,
    required double durationSeconds,
    required int width,
    required int height,
    required String format,
    required String codec,
    required double frameRate,
    required int totalFrames,
    this.processedAt = const Value.absent(),
    this.isProcessed = const Value.absent(),
  })  : videoPath = Value(videoPath),
        durationSeconds = Value(durationSeconds),
        width = Value(width),
        height = Value(height),
        format = Value(format),
        codec = Value(codec),
        frameRate = Value(frameRate),
        totalFrames = Value(totalFrames);
  static Insertable<VideoMetadata> custom({
    Expression<int>? id,
    Expression<String>? videoPath,
    Expression<double>? durationSeconds,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? format,
    Expression<String>? codec,
    Expression<double>? frameRate,
    Expression<int>? totalFrames,
    Expression<DateTime>? processedAt,
    Expression<bool>? isProcessed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoPath != null) 'video_path': videoPath,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (format != null) 'format': format,
      if (codec != null) 'codec': codec,
      if (frameRate != null) 'frame_rate': frameRate,
      if (totalFrames != null) 'total_frames': totalFrames,
      if (processedAt != null) 'processed_at': processedAt,
      if (isProcessed != null) 'is_processed': isProcessed,
    });
  }

  VideoMetadataTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? videoPath,
      Value<double>? durationSeconds,
      Value<int>? width,
      Value<int>? height,
      Value<String>? format,
      Value<String>? codec,
      Value<double>? frameRate,
      Value<int>? totalFrames,
      Value<DateTime>? processedAt,
      Value<bool>? isProcessed}) {
    return VideoMetadataTableCompanion(
      id: id ?? this.id,
      videoPath: videoPath ?? this.videoPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      width: width ?? this.width,
      height: height ?? this.height,
      format: format ?? this.format,
      codec: codec ?? this.codec,
      frameRate: frameRate ?? this.frameRate,
      totalFrames: totalFrames ?? this.totalFrames,
      processedAt: processedAt ?? this.processedAt,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (videoPath.present) {
      map['video_path'] = Variable<String>(videoPath.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (codec.present) {
      map['codec'] = Variable<String>(codec.value);
    }
    if (frameRate.present) {
      map['frame_rate'] = Variable<double>(frameRate.value);
    }
    if (totalFrames.present) {
      map['total_frames'] = Variable<int>(totalFrames.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (isProcessed.present) {
      map['is_processed'] = Variable<bool>(isProcessed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('videoPath: $videoPath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('format: $format, ')
          ..write('codec: $codec, ')
          ..write('frameRate: $frameRate, ')
          ..write('totalFrames: $totalFrames, ')
          ..write('processedAt: $processedAt, ')
          ..write('isProcessed: $isProcessed')
          ..write(')'))
        .toString();
  }
}

class $SearchQueryTableTable extends SearchQueryTable
    with TableInfo<$SearchQueryTableTable, SearchQuery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchQueryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _queryTextMeta =
      const VerificationMeta('queryText');
  @override
  late final GeneratedColumn<String> queryText = GeneratedColumn<String>(
      'query_text', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _queryEmbeddingMeta =
      const VerificationMeta('queryEmbedding');
  @override
  late final GeneratedColumn<Uint8List> queryEmbedding =
      GeneratedColumn<Uint8List>('query_embedding', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _resultIdsMeta =
      const VerificationMeta('resultIds');
  @override
  late final GeneratedColumn<String> resultIds = GeneratedColumn<String>(
      'result_ids', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultCountMeta =
      const VerificationMeta('resultCount');
  @override
  late final GeneratedColumn<int> resultCount = GeneratedColumn<int>(
      'result_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _searchedAtMeta =
      const VerificationMeta('searchedAt');
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
      'searched_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  @override
  List<GeneratedColumn> get $columns =>
      [id, queryText, queryEmbedding, resultIds, resultCount, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_query_table';
  @override
  VerificationContext validateIntegrity(Insertable<SearchQuery> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query_text')) {
      context.handle(_queryTextMeta,
          queryText.isAcceptableOrUnknown(data['query_text']!, _queryTextMeta));
    } else if (isInserting) {
      context.missing(_queryTextMeta);
    }
    if (data.containsKey('query_embedding')) {
      context.handle(
          _queryEmbeddingMeta,
          queryEmbedding.isAcceptableOrUnknown(
              data['query_embedding']!, _queryEmbeddingMeta));
    } else if (isInserting) {
      context.missing(_queryEmbeddingMeta);
    }
    if (data.containsKey('result_ids')) {
      context.handle(_resultIdsMeta,
          resultIds.isAcceptableOrUnknown(data['result_ids']!, _resultIdsMeta));
    }
    if (data.containsKey('result_count')) {
      context.handle(
          _resultCountMeta,
          resultCount.isAcceptableOrUnknown(
              data['result_count']!, _resultCountMeta));
    } else if (isInserting) {
      context.missing(_resultCountMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
          _searchedAtMeta,
          searchedAt.isAcceptableOrUnknown(
              data['searched_at']!, _searchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchQuery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchQuery(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      queryText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query_text'])!,
      queryEmbedding: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}query_embedding'])!,
      resultIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_ids']),
      resultCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}result_count'])!,
      searchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}searched_at'])!,
    );
  }

  @override
  $SearchQueryTableTable createAlias(String alias) {
    return $SearchQueryTableTable(attachedDatabase, alias);
  }
}

class SearchQuery extends DataClass implements Insertable<SearchQuery> {
  final int id;
  final String queryText;
  final Uint8List queryEmbedding;
  final String? resultIds;
  final int resultCount;
  final DateTime searchedAt;
  const SearchQuery(
      {required this.id,
      required this.queryText,
      required this.queryEmbedding,
      this.resultIds,
      required this.resultCount,
      required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query_text'] = Variable<String>(queryText);
    map['query_embedding'] = Variable<Uint8List>(queryEmbedding);
    if (!nullToAbsent || resultIds != null) {
      map['result_ids'] = Variable<String>(resultIds);
    }
    map['result_count'] = Variable<int>(resultCount);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  SearchQueryTableCompanion toCompanion(bool nullToAbsent) {
    return SearchQueryTableCompanion(
      id: Value(id),
      queryText: Value(queryText),
      queryEmbedding: Value(queryEmbedding),
      resultIds: resultIds == null && nullToAbsent
          ? const Value.absent()
          : Value(resultIds),
      resultCount: Value(resultCount),
      searchedAt: Value(searchedAt),
    );
  }

  factory SearchQuery.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchQuery(
      id: serializer.fromJson<int>(json['id']),
      queryText: serializer.fromJson<String>(json['queryText']),
      queryEmbedding: serializer.fromJson<Uint8List>(json['queryEmbedding']),
      resultIds: serializer.fromJson<String?>(json['resultIds']),
      resultCount: serializer.fromJson<int>(json['resultCount']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queryText': serializer.toJson<String>(queryText),
      'queryEmbedding': serializer.toJson<Uint8List>(queryEmbedding),
      'resultIds': serializer.toJson<String?>(resultIds),
      'resultCount': serializer.toJson<int>(resultCount),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  SearchQuery copyWith(
          {int? id,
          String? queryText,
          Uint8List? queryEmbedding,
          Value<String?> resultIds = const Value.absent(),
          int? resultCount,
          DateTime? searchedAt}) =>
      SearchQuery(
        id: id ?? this.id,
        queryText: queryText ?? this.queryText,
        queryEmbedding: queryEmbedding ?? this.queryEmbedding,
        resultIds: resultIds.present ? resultIds.value : this.resultIds,
        resultCount: resultCount ?? this.resultCount,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  SearchQuery copyWithCompanion(SearchQueryTableCompanion data) {
    return SearchQuery(
      id: data.id.present ? data.id.value : this.id,
      queryText: data.queryText.present ? data.queryText.value : this.queryText,
      queryEmbedding: data.queryEmbedding.present
          ? data.queryEmbedding.value
          : this.queryEmbedding,
      resultIds: data.resultIds.present ? data.resultIds.value : this.resultIds,
      resultCount:
          data.resultCount.present ? data.resultCount.value : this.resultCount,
      searchedAt:
          data.searchedAt.present ? data.searchedAt.value : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchQuery(')
          ..write('id: $id, ')
          ..write('queryText: $queryText, ')
          ..write('queryEmbedding: $queryEmbedding, ')
          ..write('resultIds: $resultIds, ')
          ..write('resultCount: $resultCount, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      queryText,
      $driftBlobEquality.hash(queryEmbedding),
      resultIds,
      resultCount,
      searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchQuery &&
          other.id == this.id &&
          other.queryText == this.queryText &&
          $driftBlobEquality.equals(
              other.queryEmbedding, this.queryEmbedding) &&
          other.resultIds == this.resultIds &&
          other.resultCount == this.resultCount &&
          other.searchedAt == this.searchedAt);
}

class SearchQueryTableCompanion extends UpdateCompanion<SearchQuery> {
  final Value<int> id;
  final Value<String> queryText;
  final Value<Uint8List> queryEmbedding;
  final Value<String?> resultIds;
  final Value<int> resultCount;
  final Value<DateTime> searchedAt;
  const SearchQueryTableCompanion({
    this.id = const Value.absent(),
    this.queryText = const Value.absent(),
    this.queryEmbedding = const Value.absent(),
    this.resultIds = const Value.absent(),
    this.resultCount = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  SearchQueryTableCompanion.insert({
    this.id = const Value.absent(),
    required String queryText,
    required Uint8List queryEmbedding,
    this.resultIds = const Value.absent(),
    required int resultCount,
    this.searchedAt = const Value.absent(),
  })  : queryText = Value(queryText),
        queryEmbedding = Value(queryEmbedding),
        resultCount = Value(resultCount);
  static Insertable<SearchQuery> custom({
    Expression<int>? id,
    Expression<String>? queryText,
    Expression<Uint8List>? queryEmbedding,
    Expression<String>? resultIds,
    Expression<int>? resultCount,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queryText != null) 'query_text': queryText,
      if (queryEmbedding != null) 'query_embedding': queryEmbedding,
      if (resultIds != null) 'result_ids': resultIds,
      if (resultCount != null) 'result_count': resultCount,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  SearchQueryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? queryText,
      Value<Uint8List>? queryEmbedding,
      Value<String?>? resultIds,
      Value<int>? resultCount,
      Value<DateTime>? searchedAt}) {
    return SearchQueryTableCompanion(
      id: id ?? this.id,
      queryText: queryText ?? this.queryText,
      queryEmbedding: queryEmbedding ?? this.queryEmbedding,
      resultIds: resultIds ?? this.resultIds,
      resultCount: resultCount ?? this.resultCount,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queryText.present) {
      map['query_text'] = Variable<String>(queryText.value);
    }
    if (queryEmbedding.present) {
      map['query_embedding'] = Variable<Uint8List>(queryEmbedding.value);
    }
    if (resultIds.present) {
      map['result_ids'] = Variable<String>(resultIds.value);
    }
    if (resultCount.present) {
      map['result_count'] = Variable<int>(resultCount.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchQueryTableCompanion(')
          ..write('id: $id, ')
          ..write('queryText: $queryText, ')
          ..write('queryEmbedding: $queryEmbedding, ')
          ..write('resultIds: $resultIds, ')
          ..write('resultCount: $resultCount, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideoEmbeddingsTable videoEmbeddings =
      $VideoEmbeddingsTable(this);
  late final $VideoMetadataTableTable videoMetadataTable =
      $VideoMetadataTableTable(this);
  late final $SearchQueryTableTable searchQueryTable =
      $SearchQueryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [videoEmbeddings, videoMetadataTable, searchQueryTable];
}

typedef $$VideoEmbeddingsTableCreateCompanionBuilder = VideoEmbeddingsCompanion
    Function({
  Value<int> id,
  required String videoPath,
  required int frameNumber,
  required double timestampSeconds,
  required Uint8List embedding,
  required String description,
  required String objects,
  required String scene,
  required double qualityScore,
  Value<DateTime> createdAt,
});
typedef $$VideoEmbeddingsTableUpdateCompanionBuilder = VideoEmbeddingsCompanion
    Function({
  Value<int> id,
  Value<String> videoPath,
  Value<int> frameNumber,
  Value<double> timestampSeconds,
  Value<Uint8List> embedding,
  Value<String> description,
  Value<String> objects,
  Value<String> scene,
  Value<double> qualityScore,
  Value<DateTime> createdAt,
});

class $$VideoEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoEmbeddingsTable> {
  $$VideoEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frameNumber => $composableBuilder(
      column: $table.frameNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get timestampSeconds => $composableBuilder(
      column: $table.timestampSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objects => $composableBuilder(
      column: $table.objects, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scene => $composableBuilder(
      column: $table.scene, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$VideoEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoEmbeddingsTable> {
  $$VideoEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frameNumber => $composableBuilder(
      column: $table.frameNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get timestampSeconds => $composableBuilder(
      column: $table.timestampSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objects => $composableBuilder(
      column: $table.objects, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scene => $composableBuilder(
      column: $table.scene, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VideoEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoEmbeddingsTable> {
  $$VideoEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoPath =>
      $composableBuilder(column: $table.videoPath, builder: (column) => column);

  GeneratedColumn<int> get frameNumber => $composableBuilder(
      column: $table.frameNumber, builder: (column) => column);

  GeneratedColumn<double> get timestampSeconds => $composableBuilder(
      column: $table.timestampSeconds, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get objects =>
      $composableBuilder(column: $table.objects, builder: (column) => column);

  GeneratedColumn<String> get scene =>
      $composableBuilder(column: $table.scene, builder: (column) => column);

  GeneratedColumn<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VideoEmbeddingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideoEmbeddingsTable,
    VideoEmbedding,
    $$VideoEmbeddingsTableFilterComposer,
    $$VideoEmbeddingsTableOrderingComposer,
    $$VideoEmbeddingsTableAnnotationComposer,
    $$VideoEmbeddingsTableCreateCompanionBuilder,
    $$VideoEmbeddingsTableUpdateCompanionBuilder,
    (
      VideoEmbedding,
      BaseReferences<_$AppDatabase, $VideoEmbeddingsTable, VideoEmbedding>
    ),
    VideoEmbedding,
    PrefetchHooks Function()> {
  $$VideoEmbeddingsTableTableManager(
      _$AppDatabase db, $VideoEmbeddingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> videoPath = const Value.absent(),
            Value<int> frameNumber = const Value.absent(),
            Value<double> timestampSeconds = const Value.absent(),
            Value<Uint8List> embedding = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> objects = const Value.absent(),
            Value<String> scene = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              VideoEmbeddingsCompanion(
            id: id,
            videoPath: videoPath,
            frameNumber: frameNumber,
            timestampSeconds: timestampSeconds,
            embedding: embedding,
            description: description,
            objects: objects,
            scene: scene,
            qualityScore: qualityScore,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String videoPath,
            required int frameNumber,
            required double timestampSeconds,
            required Uint8List embedding,
            required String description,
            required String objects,
            required String scene,
            required double qualityScore,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              VideoEmbeddingsCompanion.insert(
            id: id,
            videoPath: videoPath,
            frameNumber: frameNumber,
            timestampSeconds: timestampSeconds,
            embedding: embedding,
            description: description,
            objects: objects,
            scene: scene,
            qualityScore: qualityScore,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VideoEmbeddingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideoEmbeddingsTable,
    VideoEmbedding,
    $$VideoEmbeddingsTableFilterComposer,
    $$VideoEmbeddingsTableOrderingComposer,
    $$VideoEmbeddingsTableAnnotationComposer,
    $$VideoEmbeddingsTableCreateCompanionBuilder,
    $$VideoEmbeddingsTableUpdateCompanionBuilder,
    (
      VideoEmbedding,
      BaseReferences<_$AppDatabase, $VideoEmbeddingsTable, VideoEmbedding>
    ),
    VideoEmbedding,
    PrefetchHooks Function()>;
typedef $$VideoMetadataTableTableCreateCompanionBuilder
    = VideoMetadataTableCompanion Function({
  Value<int> id,
  required String videoPath,
  required double durationSeconds,
  required int width,
  required int height,
  required String format,
  required String codec,
  required double frameRate,
  required int totalFrames,
  Value<DateTime> processedAt,
  Value<bool> isProcessed,
});
typedef $$VideoMetadataTableTableUpdateCompanionBuilder
    = VideoMetadataTableCompanion Function({
  Value<int> id,
  Value<String> videoPath,
  Value<double> durationSeconds,
  Value<int> width,
  Value<int> height,
  Value<String> format,
  Value<String> codec,
  Value<double> frameRate,
  Value<int> totalFrames,
  Value<DateTime> processedAt,
  Value<bool> isProcessed,
});

class $$VideoMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $VideoMetadataTableTable> {
  $$VideoMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codec => $composableBuilder(
      column: $table.codec, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get frameRate => $composableBuilder(
      column: $table.frameRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalFrames => $composableBuilder(
      column: $table.totalFrames, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => ColumnFilters(column));
}

class $$VideoMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoMetadataTableTable> {
  $$VideoMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codec => $composableBuilder(
      column: $table.codec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get frameRate => $composableBuilder(
      column: $table.frameRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalFrames => $composableBuilder(
      column: $table.totalFrames, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => ColumnOrderings(column));
}

class $$VideoMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoMetadataTableTable> {
  $$VideoMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoPath =>
      $composableBuilder(column: $table.videoPath, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get codec =>
      $composableBuilder(column: $table.codec, builder: (column) => column);

  GeneratedColumn<double> get frameRate =>
      $composableBuilder(column: $table.frameRate, builder: (column) => column);

  GeneratedColumn<int> get totalFrames => $composableBuilder(
      column: $table.totalFrames, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => column);

  GeneratedColumn<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => column);
}

class $$VideoMetadataTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideoMetadataTableTable,
    VideoMetadata,
    $$VideoMetadataTableTableFilterComposer,
    $$VideoMetadataTableTableOrderingComposer,
    $$VideoMetadataTableTableAnnotationComposer,
    $$VideoMetadataTableTableCreateCompanionBuilder,
    $$VideoMetadataTableTableUpdateCompanionBuilder,
    (
      VideoMetadata,
      BaseReferences<_$AppDatabase, $VideoMetadataTableTable, VideoMetadata>
    ),
    VideoMetadata,
    PrefetchHooks Function()> {
  $$VideoMetadataTableTableTableManager(
      _$AppDatabase db, $VideoMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> videoPath = const Value.absent(),
            Value<double> durationSeconds = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<String> codec = const Value.absent(),
            Value<double> frameRate = const Value.absent(),
            Value<int> totalFrames = const Value.absent(),
            Value<DateTime> processedAt = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
          }) =>
              VideoMetadataTableCompanion(
            id: id,
            videoPath: videoPath,
            durationSeconds: durationSeconds,
            width: width,
            height: height,
            format: format,
            codec: codec,
            frameRate: frameRate,
            totalFrames: totalFrames,
            processedAt: processedAt,
            isProcessed: isProcessed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String videoPath,
            required double durationSeconds,
            required int width,
            required int height,
            required String format,
            required String codec,
            required double frameRate,
            required int totalFrames,
            Value<DateTime> processedAt = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
          }) =>
              VideoMetadataTableCompanion.insert(
            id: id,
            videoPath: videoPath,
            durationSeconds: durationSeconds,
            width: width,
            height: height,
            format: format,
            codec: codec,
            frameRate: frameRate,
            totalFrames: totalFrames,
            processedAt: processedAt,
            isProcessed: isProcessed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VideoMetadataTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideoMetadataTableTable,
    VideoMetadata,
    $$VideoMetadataTableTableFilterComposer,
    $$VideoMetadataTableTableOrderingComposer,
    $$VideoMetadataTableTableAnnotationComposer,
    $$VideoMetadataTableTableCreateCompanionBuilder,
    $$VideoMetadataTableTableUpdateCompanionBuilder,
    (
      VideoMetadata,
      BaseReferences<_$AppDatabase, $VideoMetadataTableTable, VideoMetadata>
    ),
    VideoMetadata,
    PrefetchHooks Function()>;
typedef $$SearchQueryTableTableCreateCompanionBuilder
    = SearchQueryTableCompanion Function({
  Value<int> id,
  required String queryText,
  required Uint8List queryEmbedding,
  Value<String?> resultIds,
  required int resultCount,
  Value<DateTime> searchedAt,
});
typedef $$SearchQueryTableTableUpdateCompanionBuilder
    = SearchQueryTableCompanion Function({
  Value<int> id,
  Value<String> queryText,
  Value<Uint8List> queryEmbedding,
  Value<String?> resultIds,
  Value<int> resultCount,
  Value<DateTime> searchedAt,
});

class $$SearchQueryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SearchQueryTableTable> {
  $$SearchQueryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryText => $composableBuilder(
      column: $table.queryText, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get queryEmbedding => $composableBuilder(
      column: $table.queryEmbedding,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultIds => $composableBuilder(
      column: $table.resultIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resultCount => $composableBuilder(
      column: $table.resultCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => ColumnFilters(column));
}

class $$SearchQueryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchQueryTableTable> {
  $$SearchQueryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryText => $composableBuilder(
      column: $table.queryText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get queryEmbedding => $composableBuilder(
      column: $table.queryEmbedding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultIds => $composableBuilder(
      column: $table.resultIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resultCount => $composableBuilder(
      column: $table.resultCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => ColumnOrderings(column));
}

class $$SearchQueryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchQueryTableTable> {
  $$SearchQueryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queryText =>
      $composableBuilder(column: $table.queryText, builder: (column) => column);

  GeneratedColumn<Uint8List> get queryEmbedding => $composableBuilder(
      column: $table.queryEmbedding, builder: (column) => column);

  GeneratedColumn<String> get resultIds =>
      $composableBuilder(column: $table.resultIds, builder: (column) => column);

  GeneratedColumn<int> get resultCount => $composableBuilder(
      column: $table.resultCount, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => column);
}

class $$SearchQueryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchQueryTableTable,
    SearchQuery,
    $$SearchQueryTableTableFilterComposer,
    $$SearchQueryTableTableOrderingComposer,
    $$SearchQueryTableTableAnnotationComposer,
    $$SearchQueryTableTableCreateCompanionBuilder,
    $$SearchQueryTableTableUpdateCompanionBuilder,
    (
      SearchQuery,
      BaseReferences<_$AppDatabase, $SearchQueryTableTable, SearchQuery>
    ),
    SearchQuery,
    PrefetchHooks Function()> {
  $$SearchQueryTableTableTableManager(
      _$AppDatabase db, $SearchQueryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchQueryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchQueryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchQueryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> queryText = const Value.absent(),
            Value<Uint8List> queryEmbedding = const Value.absent(),
            Value<String?> resultIds = const Value.absent(),
            Value<int> resultCount = const Value.absent(),
            Value<DateTime> searchedAt = const Value.absent(),
          }) =>
              SearchQueryTableCompanion(
            id: id,
            queryText: queryText,
            queryEmbedding: queryEmbedding,
            resultIds: resultIds,
            resultCount: resultCount,
            searchedAt: searchedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String queryText,
            required Uint8List queryEmbedding,
            Value<String?> resultIds = const Value.absent(),
            required int resultCount,
            Value<DateTime> searchedAt = const Value.absent(),
          }) =>
              SearchQueryTableCompanion.insert(
            id: id,
            queryText: queryText,
            queryEmbedding: queryEmbedding,
            resultIds: resultIds,
            resultCount: resultCount,
            searchedAt: searchedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchQueryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchQueryTableTable,
    SearchQuery,
    $$SearchQueryTableTableFilterComposer,
    $$SearchQueryTableTableOrderingComposer,
    $$SearchQueryTableTableAnnotationComposer,
    $$SearchQueryTableTableCreateCompanionBuilder,
    $$SearchQueryTableTableUpdateCompanionBuilder,
    (
      SearchQuery,
      BaseReferences<_$AppDatabase, $SearchQueryTableTable, SearchQuery>
    ),
    SearchQuery,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideoEmbeddingsTableTableManager get videoEmbeddings =>
      $$VideoEmbeddingsTableTableManager(_db, _db.videoEmbeddings);
  $$VideoMetadataTableTableTableManager get videoMetadataTable =>
      $$VideoMetadataTableTableTableManager(_db, _db.videoMetadataTable);
  $$SearchQueryTableTableTableManager get searchQueryTable =>
      $$SearchQueryTableTableTableManager(_db, _db.searchQueryTable);
}
