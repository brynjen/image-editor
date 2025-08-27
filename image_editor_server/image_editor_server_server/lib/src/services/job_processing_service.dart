import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'qwen_image_service.dart';

/// Service for managing and processing image editing jobs
class JobProcessingService {
  final QwenImageService _qwenImageService;

  JobProcessingService(this._qwenImageService);

  /// Create a new processing job
  Future<ProcessingJob> createJob({
    required Session session,
    required int imageId,
    required String processorType,
    required String instructions,
  }) async {
    try {
      session.log('Creating processing job for image $imageId');

      final job = ProcessingJob(
        imageId: imageId,
        status: 'pending',
        processorType: processorType,
        instructions: instructions,
        createdAt: DateTime.now(),
        progress: 0.0,
      );

      final savedJob = await ProcessingJob.db.insertRow(session, job);
      session.log('Created processing job ${savedJob.id}');

      return savedJob;
    } catch (e) {
      session.log('Error creating processing job: $e');
      rethrow;
    }
  }

  /// Get job status
  Future<JobStatusResponse?> getJobStatus(Session session, int jobId) async {
    try {
      final job = await ProcessingJob.db.findById(session, jobId);
      if (job == null) {
        return null;
      }

      return JobStatusResponse(
        jobId: job.id!,
        status: job.status,
        progress: job.progress,
        message: job.errorMessage,
        resultImageId: job.resultImageId,
        processingTimeMs: job.processingTimeMs,
        createdAt: job.createdAt,
        startedAt: job.startedAt,
        completedAt: job.completedAt,
      );
    } catch (e) {
      session.log('Error getting job status: $e');
      return null;
    }
  }

  /// Process a job (called by future call)
  Future<void> processJob(Session session, int jobId) async {
    ProcessingJob? job;
    final startTime = DateTime.now();

    try {
      session.log('Processing job $jobId');

      // Get the job
      job = await ProcessingJob.db.findById(session, jobId);
      if (job == null) {
        session.log('Job $jobId not found');
        return;
      }

      // Update job status to processing
      job = job.copyWith(
        status: 'processing',
        startedAt: startTime,
        progress: 0.1,
      );
      await ProcessingJob.db.updateRow(session, job);

      // Get the image data
      final imageData = await ImageData.db.findById(session, job.imageId);
      if (imageData == null) {
        await _failJob(session, job, 'Image not found');
        return;
      }

      // Check if image file exists
      final originalFile = File('storage/images/${imageData.filename}');
      if (!await originalFile.exists()) {
        await _failJob(session, job, 'Image file not found');
        return;
      }

      // Update progress
      job = job.copyWith(progress: 0.2);
      await ProcessingJob.db.updateRow(session, job);

      // Check if Qwen service is healthy
      final isHealthy = await _qwenImageService.isHealthy();
      if (!isHealthy) {
        session.log('Qwen service not healthy, using fallback processing');
        await _fallbackProcessJob(session, job, imageData);
        return;
      }

      // Update progress
      job = job.copyWith(progress: 0.3);
      await ProcessingJob.db.updateRow(session, job);

      // Read and encode image
      final imageBytes = await originalFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Update progress
      job = job.copyWith(progress: 0.4);
      await ProcessingJob.db.updateRow(session, job);

      session.log('Sending image to Qwen service for processing');

      // Process with Qwen service
      final result = await _qwenImageService.processImage(
        imageBase64: imageBase64,
        prompt: job.instructions,
        model: job.processorType,
      );

      // Update progress
      job = job.copyWith(progress: 0.8);
      await ProcessingJob.db.updateRow(session, job);

      if (!result.success || result.processedImageBase64 == null) {
        await _failJob(session, job, result.message ?? 'Processing failed');
        return;
      }

      // Save processed image
      final processedImageBytes = base64Decode(result.processedImageBase64!);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final processedFilename = '${timestamp}_processed_${imageData.filename}';

      final processedFile = File('storage/images/$processedFilename');
      await processedFile.writeAsBytes(processedImageBytes);

      // Create database record for processed image
      final processedImageData = ImageData(
        filename: processedFilename,
        originalName: 'processed_${imageData.originalName}',
        mimeType: imageData.mimeType,
        size: processedImageBytes.length,
        uploadedAt: DateTime.now(),
        processorType: job.processorType,
        instructions: job.instructions,
        processedAt: DateTime.now(),
      );

      final savedProcessedImage = await ImageData.db.insertRow(session, processedImageData);

      // Complete the job
      final completedAt = DateTime.now();
      final processingTimeMs = completedAt.difference(startTime).inMilliseconds;

      job = job.copyWith(
        status: 'completed',
        completedAt: completedAt,
        processingTimeMs: processingTimeMs,
        resultImageId: savedProcessedImage.id,
        progress: 1.0,
      );

      await ProcessingJob.db.updateRow(session, job);

      session.log('Job $jobId completed successfully in ${processingTimeMs}ms');

    } catch (e) {
      session.log('Error processing job $jobId: $e');
      if (job != null) {
        await _failJob(session, job, e.toString());
      }
    }
  }

  /// Fallback processing when Qwen service is unavailable
  Future<void> _fallbackProcessJob(
    Session session,
    ProcessingJob job,
    ImageData imageData,
  ) async {
    try {
      session.log('Using fallback processing for job ${job.id}');

      // Generate processed filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final processedFilename = '${timestamp}_fallback_${imageData.filename}';

      // Copy the original file (fallback processing)
      final originalFile = File('storage/images/${imageData.filename}');
      final processedFile = File('storage/images/$processedFilename');
      await originalFile.copy(processedFile.path);

      // Create database record for processed image
      final processedImageData = ImageData(
        filename: processedFilename,
        originalName: 'fallback_${imageData.originalName}',
        mimeType: imageData.mimeType,
        size: imageData.size,
        uploadedAt: DateTime.now(),
        processorType: job.processorType,
        instructions: job.instructions,
        processedAt: DateTime.now(),
      );

      final savedProcessedImage = await ImageData.db.insertRow(session, processedImageData);

      // Complete the job
      final completedAt = DateTime.now();
      final processingTimeMs = completedAt.difference(job.createdAt).inMilliseconds;

      final updatedJob = job.copyWith(
        status: 'completed',
        completedAt: completedAt,
        processingTimeMs: processingTimeMs,
        resultImageId: savedProcessedImage.id,
        progress: 1.0,
      );

      await ProcessingJob.db.updateRow(session, updatedJob);

      session.log('Fallback processing completed for job ${job.id}');
    } catch (e) {
      await _failJob(session, job, 'Fallback processing failed: $e');
    }
  }

  /// Mark a job as failed
  Future<void> _failJob(Session session, ProcessingJob job, String errorMessage) async {
    try {
      final failedJob = job.copyWith(
        status: 'failed',
        completedAt: DateTime.now(),
        errorMessage: errorMessage,
      );

      await ProcessingJob.db.updateRow(session, failedJob);
      session.log('Job ${job.id} failed: $errorMessage');
    } catch (e) {
      session.log('Error updating failed job ${job.id}: $e');
    }
  }

  /// Get pending jobs count
  Future<int> getPendingJobsCount(Session session) async {
    try {
      final jobs = await ProcessingJob.db.find(
        session,
        where: (t) => t.status.equals('pending'),
      );
      return jobs.length;
    } catch (e) {
      session.log('Error getting pending jobs count: $e');
      return 0;
    }
  }

  /// Get all jobs for monitoring
  Future<List<ProcessingJob>> getAllJobs(Session session, {int limit = 100}) async {
    try {
      return await ProcessingJob.db.find(
        session,
        orderBy: (t) => t.createdAt,
        orderDescending: true,
        limit: limit,
      );
    } catch (e) {
      session.log('Error getting all jobs: $e');
      return [];
    }
  }
}
