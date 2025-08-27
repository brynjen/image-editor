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
import 'dart:async' as _i2;
import 'package:image_editor_server_client/src/protocol/image_upload_response.dart'
    as _i3;
import 'package:image_editor_server_client/src/protocol/image_data.dart' as _i4;
import 'package:image_editor_server_client/src/protocol/image_process_request.dart'
    as _i5;
import 'package:image_editor_server_client/src/protocol/greeting.dart' as _i6;
import 'protocol.dart' as _i7;

/// Endpoint for handling image upload and retrieval operations
/// {@category Endpoint}
class EndpointImage extends _i1.EndpointRef {
  EndpointImage(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'image';

  /// Health check endpoint to verify server connectivity
  _i2.Future<String> healthCheck() => caller.callServerEndpoint<String>(
        'image',
        'healthCheck',
        {},
      );

  /// Upload an image file and return the stored image data
  _i2.Future<_i3.ImageUploadResponse> uploadImage(
    String filename,
    String originalName,
    String mimeType,
    String imageDataBase64,
  ) =>
      caller.callServerEndpoint<_i3.ImageUploadResponse>(
        'image',
        'uploadImage',
        {
          'filename': filename,
          'originalName': originalName,
          'mimeType': mimeType,
          'imageDataBase64': imageDataBase64,
        },
      );

  /// Get image data by ID
  _i2.Future<_i4.ImageData?> getImage(int imageId) =>
      caller.callServerEndpoint<_i4.ImageData?>(
        'image',
        'getImage',
        {'imageId': imageId},
      );

  /// Get image file bytes by ID as base64
  _i2.Future<String?> getImageFile(int imageId) =>
      caller.callServerEndpoint<String?>(
        'image',
        'getImageFile',
        {'imageId': imageId},
      );

  /// Process an image with given instructions
  _i2.Future<_i3.ImageUploadResponse> processImage(
          _i5.ImageProcessRequest request) =>
      caller.callServerEndpoint<_i3.ImageUploadResponse>(
        'image',
        'processImage',
        {'request': request},
      );

  /// List all images for a user (for now, all images)
  _i2.Future<List<_i4.ImageData>> listImages() =>
      caller.callServerEndpoint<List<_i4.ImageData>>(
        'image',
        'listImages',
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i6.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i6.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i7.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    image = EndpointImage(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointImage image;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'image': image,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
