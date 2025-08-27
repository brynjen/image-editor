import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/qwen_image_service.dart';
import '../services/job_processing_service.dart';

/// Endpoint for managing image processing jobs
class JobEndpoint extends Endpoint {
  late final JobProcessingService _jobProcessingService;

  @override
  void initialize(Server server, String name, String? moduleName) {
    super.initialize(server, name, moduleName);
    final qwenImageService = QwenImageService();
    _jobProcessingService = JobProcessingService(qwenImageService);
  }

  /// Create a new image processing job
  Future<ProcessingJob> createProcessingJob(
    Session session,
    int imageId,
    String processorType,
    String instructions,
  ) async {
    try {
      session.log('Creating processing job for image $imageId');

      // Verify the image exists
      final imageData = await ImageData.db.findById(session, imageId);
      if (imageData == null) {
        throw Exception('Image with ID $imageId not found');
      }

      // Create the job
      final job = await _jobProcessingService.createJob(
        session: session,
        imageId: imageId,
        processorType: processorType,
        instructions: instructions,
      );

      // Schedule the job for background processing
      await session.serverpod.futureCallWithDelay(
        'imageProcessing',
        ProcessingJob(
          id: job.id!,
          imageId: job.imageId,
          status: job.status,
          processorType: job.processorType,
          instructions: job.instructions,
          createdAt: job.createdAt,
          progress: job.progress,
        ),
        Duration.zero,
      );

      session.log('Scheduled processing job ${job.id} for execution');
      return job;

    } catch (e) {
      session.log('Error creating processing job: $e');
      rethrow;
    }
  }

  /// Get job status
  Future<JobStatusResponse?> getJobStatus(Session session, int jobId) async {
    session.log('Getting status for job $jobId');
    return await _jobProcessingService.getJobStatus(session, jobId);
  }

  /// Get job result (processed image data)
  Future<ImageData?> getJobResult(Session session, int jobId) async {
    try {
      session.log('Getting result for job $jobId');

      final job = await ProcessingJob.db.findById(session, jobId);
      if (job == null) {
        session.log('Job $jobId not found');
        return null;
      }

      if (job.status != 'completed' || job.resultImageId == null) {
        session.log('Job $jobId not completed or has no result');
        return null;
      }

      final resultImage = await ImageData.db.findById(session, job.resultImageId!);
      if (resultImage == null) {
        session.log('Result image ${job.resultImageId} not found for job $jobId');
        return null;
      }

      return resultImage;
    } catch (e) {
      session.log('Error getting job result: $e');
      return null;
    }
  }

  /// Cancel a pending job
  Future<bool> cancelJob(Session session, int jobId) async {
    try {
      session.log('Canceling job $jobId');

      final job = await ProcessingJob.db.findById(session, jobId);
      if (job == null) {
        session.log('Job $jobId not found');
        return false;
      }

      if (job.status != 'pending') {
        session.log('Job $jobId cannot be canceled (status: ${job.status})');
        return false;
      }

      final canceledJob = job.copyWith(
        status: 'cancelled',
        completedAt: DateTime.now(),
        errorMessage: 'Job cancelled by user',
      );

      await ProcessingJob.db.updateRow(session, canceledJob);
      session.log('Job $jobId cancelled successfully');
      return true;

    } catch (e) {
      session.log('Error canceling job $jobId: $e');
      return false;
    }
  }

  /// List user's jobs (for now, all jobs)
  Future<List<ProcessingJob>> listJobs(Session session, {int limit = 50}) async {
    session.log('Listing jobs (limit: $limit)');
    return await _jobProcessingService.getAllJobs(session, limit: limit);
  }

  /// Get processing statistics
  Future<Map<String, dynamic>> getProcessingStats(Session session) async {
    try {
      session.log('Getting processing statistics');

      final allJobs = await ProcessingJob.db.find(session);
      
      final stats = <String, int>{};
      for (final job in allJobs) {
        stats[job.status] = (stats[job.status] ?? 0) + 1;
      }

      final pendingCount = await _jobProcessingService.getPendingJobsCount(session);
      
      return {
        'total_jobs': allJobs.length,
        'pending_jobs': pendingCount,
        'status_breakdown': stats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      session.log('Error getting processing stats: $e');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
