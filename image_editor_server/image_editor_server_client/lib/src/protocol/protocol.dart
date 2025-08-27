/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'greeting.dart' as _i2;
import 'image_data.dart' as _i3;
import 'image_process_request.dart' as _i4;
import 'image_upload_response.dart' as _i5;
import 'job_status_response.dart' as _i6;
import 'processing_job.dart' as _i7;
import 'package:image_editor_server_client/src/protocol/image_data.dart' as _i8;
import 'package:image_editor_server_client/src/protocol/processing_job.dart'
    as _i9;
export 'greeting.dart';
export 'image_data.dart';
export 'image_process_request.dart';
export 'image_upload_response.dart';
export 'job_status_response.dart';
export 'processing_job.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.ImageData) {
      return _i3.ImageData.fromJson(data) as T;
    }
    if (t == _i4.ImageProcessRequest) {
      return _i4.ImageProcessRequest.fromJson(data) as T;
    }
    if (t == _i5.ImageUploadResponse) {
      return _i5.ImageUploadResponse.fromJson(data) as T;
    }
    if (t == _i6.JobStatusResponse) {
      return _i6.JobStatusResponse.fromJson(data) as T;
    }
    if (t == _i7.ProcessingJob) {
      return _i7.ProcessingJob.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ImageData?>()) {
      return (data != null ? _i3.ImageData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ImageProcessRequest?>()) {
      return (data != null ? _i4.ImageProcessRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.ImageUploadResponse?>()) {
      return (data != null ? _i5.ImageUploadResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.JobStatusResponse?>()) {
      return (data != null ? _i6.JobStatusResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ProcessingJob?>()) {
      return (data != null ? _i7.ProcessingJob.fromJson(data) : null) as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map((k, v) =>
          MapEntry(deserialize<String>(k), deserialize<dynamic>(v))) as T;
    }
    if (t == List<_i8.ImageData>) {
      return (data as List).map((e) => deserialize<_i8.ImageData>(e)).toList()
          as T;
    }
    if (t == List<_i9.ProcessingJob>) {
      return (data as List)
          .map((e) => deserialize<_i9.ProcessingJob>(e))
          .toList() as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Greeting) {
      return 'Greeting';
    }
    if (data is _i3.ImageData) {
      return 'ImageData';
    }
    if (data is _i4.ImageProcessRequest) {
      return 'ImageProcessRequest';
    }
    if (data is _i5.ImageUploadResponse) {
      return 'ImageUploadResponse';
    }
    if (data is _i6.JobStatusResponse) {
      return 'JobStatusResponse';
    }
    if (data is _i7.ProcessingJob) {
      return 'ProcessingJob';
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
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'ImageData') {
      return deserialize<_i3.ImageData>(data['data']);
    }
    if (dataClassName == 'ImageProcessRequest') {
      return deserialize<_i4.ImageProcessRequest>(data['data']);
    }
    if (dataClassName == 'ImageUploadResponse') {
      return deserialize<_i5.ImageUploadResponse>(data['data']);
    }
    if (dataClassName == 'JobStatusResponse') {
      return deserialize<_i6.JobStatusResponse>(data['data']);
    }
    if (dataClassName == 'ProcessingJob') {
      return deserialize<_i7.ProcessingJob>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
