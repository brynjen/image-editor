import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'services/qwen_image_service.dart';
import 'services/job_processing_service.dart';

/// Future call for processing image editing jobs in the background
class ImageProcessingFutureCall extends FutureCall {

  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    if (object == null) {
      session.log('ImageProcessingFutureCall: No job object provided');
      return;
    }
    
    final job = object as ProcessingJob;
    final jobId = job.id!;
    session.log('ImageProcessingFutureCall: Processing job $jobId');
    
    try {
      final qwenImageService = QwenImageService.fromConfig(session);
      final jobProcessingService = JobProcessingService(qwenImageService);
      await jobProcessingService.processJob(session, jobId);
      session.log('ImageProcessingFutureCall: Successfully processed job $jobId');
    } catch (e) {
      session.log('ImageProcessingFutureCall: Error processing job $jobId: $e');
      rethrow;
    }
  }
}
