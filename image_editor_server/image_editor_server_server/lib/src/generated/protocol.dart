/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'greeting.dart' as _i3;
import 'image_data.dart' as _i4;
import 'image_process_request.dart' as _i5;
import 'image_upload_response.dart' as _i6;
import 'job_status_response.dart' as _i7;
import 'processing_job.dart' as _i8;
import 'package:image_editor_server_server/src/generated/image_data.dart'
    as _i9;
import 'package:image_editor_server_server/src/generated/processing_job.dart'
    as _i10;
export 'greeting.dart';
export 'image_data.dart';
export 'image_process_request.dart';
export 'image_upload_response.dart';
export 'job_status_response.dart';
export 'processing_job.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'image_data',
      dartName: 'ImageData',
      schema: 'public',
      module: 'image_editor_server',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'image_data_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'filename',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'originalName',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'mimeType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'size',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'uploadedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'processorType',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'instructions',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'processedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'processedFilename',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'image_data_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'processing_jobs',
      dartName: 'ProcessingJob',
      schema: 'public',
      module: 'image_editor_server',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'processing_jobs_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'imageId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'processorType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'instructions',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'startedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'completedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'errorMessage',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'processingTimeMs',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'resultImageId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'progress',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '0.0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'processing_jobs_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i3.Greeting) {
      return _i3.Greeting.fromJson(data) as T;
    }
    if (t == _i4.ImageData) {
      return _i4.ImageData.fromJson(data) as T;
    }
    if (t == _i5.ImageProcessRequest) {
      return _i5.ImageProcessRequest.fromJson(data) as T;
    }
    if (t == _i6.ImageUploadResponse) {
      return _i6.ImageUploadResponse.fromJson(data) as T;
    }
    if (t == _i7.JobStatusResponse) {
      return _i7.JobStatusResponse.fromJson(data) as T;
    }
    if (t == _i8.ProcessingJob) {
      return _i8.ProcessingJob.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.Greeting?>()) {
      return (data != null ? _i3.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ImageData?>()) {
      return (data != null ? _i4.ImageData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ImageProcessRequest?>()) {
      return (data != null ? _i5.ImageProcessRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.ImageUploadResponse?>()) {
      return (data != null ? _i6.ImageUploadResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.JobStatusResponse?>()) {
      return (data != null ? _i7.JobStatusResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ProcessingJob?>()) {
      return (data != null ? _i8.ProcessingJob.fromJson(data) : null) as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<dynamic>(v))) as T;
    }
    if (t == List<_i9.ImageData>) {
      return (data as List).map((e) => deserialize<_i9.ImageData>(e)).toList()
          as T;
    }
    if (t == List<_i10.ProcessingJob>) {
      return (data as List)
          .map((e) => deserialize<_i10.ProcessingJob>(e))
          .toList() as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i3.Greeting) {
      return 'Greeting';
    }
    if (data is _i4.ImageData) {
      return 'ImageData';
    }
    if (data is _i5.ImageProcessRequest) {
      return 'ImageProcessRequest';
    }
    if (data is _i6.ImageUploadResponse) {
      return 'ImageUploadResponse';
    }
    if (data is _i7.JobStatusResponse) {
      return 'JobStatusResponse';
    }
    if (data is _i8.ProcessingJob) {
      return 'ProcessingJob';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i3.Greeting>(data['data']);
    }
    if (dataClassName == 'ImageData') {
      return deserialize<_i4.ImageData>(data['data']);
    }
    if (dataClassName == 'ImageProcessRequest') {
      return deserialize<_i5.ImageProcessRequest>(data['data']);
    }
    if (dataClassName == 'ImageUploadResponse') {
      return deserialize<_i6.ImageUploadResponse>(data['data']);
    }
    if (dataClassName == 'JobStatusResponse') {
      return deserialize<_i7.JobStatusResponse>(data['data']);
    }
    if (dataClassName == 'ProcessingJob') {
      return deserialize<_i8.ProcessingJob>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i4.ImageData:
        return _i4.ImageData.t;
      case _i8.ProcessingJob:
        return _i8.ProcessingJob.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'image_editor_server';
}
