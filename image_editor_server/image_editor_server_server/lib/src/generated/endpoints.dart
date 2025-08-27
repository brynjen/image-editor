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
import '../endpoints/image_endpoint.dart' as _i2;
import '../endpoints/job_endpoint.dart' as _i3;
import '../greeting_endpoint.dart' as _i4;
import 'package:image_editor_server_server/src/generated/image_process_request.dart'
    as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'image': _i2.ImageEndpoint()
        ..initialize(
          server,
          'image',
          null,
        ),
      'job': _i3.JobEndpoint()
        ..initialize(
          server,
          'job',
          null,
        ),
      'greeting': _i4.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['image'] = _i1.EndpointConnector(
      name: 'image',
      endpoint: endpoints['image']!,
      methodConnectors: {
        'healthCheck': _i1.MethodConnector(
          name: 'healthCheck',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).healthCheck(session),
        ),
        'checkQwenHealth': _i1.MethodConnector(
          name: 'checkQwenHealth',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint)
                  .checkQwenHealth(session),
        ),
        'uploadImage': _i1.MethodConnector(
          name: 'uploadImage',
          params: {
            'filename': _i1.ParameterDescription(
              name: 'filename',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'originalName': _i1.ParameterDescription(
              name: 'originalName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mimeType': _i1.ParameterDescription(
              name: 'mimeType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'imageDataBase64': _i1.ParameterDescription(
              name: 'imageDataBase64',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).uploadImage(
            session,
            params['filename'],
            params['originalName'],
            params['mimeType'],
            params['imageDataBase64'],
          ),
        ),
        'getImage': _i1.MethodConnector(
          name: 'getImage',
          params: {
            'imageId': _i1.ParameterDescription(
              name: 'imageId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).getImage(
            session,
            params['imageId'],
          ),
        ),
        'getImageFile': _i1.MethodConnector(
          name: 'getImageFile',
          params: {
            'imageId': _i1.ParameterDescription(
              name: 'imageId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).getImageFile(
            session,
            params['imageId'],
          ),
        ),
        'processImageAsync': _i1.MethodConnector(
          name: 'processImageAsync',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i5.ImageProcessRequest>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).processImageAsync(
            session,
            params['request'],
          ),
        ),
        'processImage': _i1.MethodConnector(
          name: 'processImage',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i5.ImageProcessRequest>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).processImage(
            session,
            params['request'],
          ),
        ),
        'listImages': _i1.MethodConnector(
          name: 'listImages',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['image'] as _i2.ImageEndpoint).listImages(session),
        ),
      },
    );
    connectors['job'] = _i1.EndpointConnector(
      name: 'job',
      endpoint: endpoints['job']!,
      methodConnectors: {
        'createProcessingJob': _i1.MethodConnector(
          name: 'createProcessingJob',
          params: {
            'imageId': _i1.ParameterDescription(
              name: 'imageId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'processorType': _i1.ParameterDescription(
              name: 'processorType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'instructions': _i1.ParameterDescription(
              name: 'instructions',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['job'] as _i3.JobEndpoint).createProcessingJob(
            session,
            params['imageId'],
            params['processorType'],
            params['instructions'],
          ),
        ),
        'getJobStatus': _i1.MethodConnector(
          name: 'getJobStatus',
          params: {
            'jobId': _i1.ParameterDescription(
              name: 'jobId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['job'] as _i3.JobEndpoint).getJobStatus(
            session,
            params['jobId'],
          ),
        ),
        'getJobResult': _i1.MethodConnector(
          name: 'getJobResult',
          params: {
            'jobId': _i1.ParameterDescription(
              name: 'jobId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['job'] as _i3.JobEndpoint).getJobResult(
            session,
            params['jobId'],
          ),
        ),
        'cancelJob': _i1.MethodConnector(
          name: 'cancelJob',
          params: {
            'jobId': _i1.ParameterDescription(
              name: 'jobId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['job'] as _i3.JobEndpoint).cancelJob(
            session,
            params['jobId'],
          ),
        ),
        'listJobs': _i1.MethodConnector(
          name: 'listJobs',
          params: {
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['job'] as _i3.JobEndpoint).listJobs(
            session,
            limit: params['limit'],
          ),
        ),
        'getProcessingStats': _i1.MethodConnector(
          name: 'getProcessingStats',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['job'] as _i3.JobEndpoint).getProcessingStats(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['greeting'] as _i4.GreetingEndpoint).hello(
            session,
            params['name'],
          ),
        )
      },
    );
  }
}
