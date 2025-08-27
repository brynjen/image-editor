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
import '../greeting_endpoint.dart' as _i3;
import 'package:image_editor_server_server/src/generated/image_process_request.dart'
    as _i4;

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
      'greeting': _i3.GreetingEndpoint()
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
        'processImage': _i1.MethodConnector(
          name: 'processImage',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i4.ImageProcessRequest>(),
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
              (endpoints['greeting'] as _i3.GreetingEndpoint).hello(
            session,
            params['name'],
          ),
        )
      },
    );
  }
}
