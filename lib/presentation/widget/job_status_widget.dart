import 'package:flutter/material.dart';
import '../../domain/model/processing_job_model.dart';

/// Widget to display job processing status and progress
class JobStatusWidget extends StatelessWidget {
  final ProcessingJobModel? job;
  final VoidCallback? onCancel;

  const JobStatusWidget({
    super.key,
    this.job,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (job == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job!.statusMessage,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _getStatusColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (job!.isActive && onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
              ],
            ),
            if (job!.isActive) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: job!.progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Processing with ${job!.processorType}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${(job!.progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (job!.isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                'Processing completed successfully',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (job!.isFailed && job!.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job!.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (job!.status) {
      case ProcessingJobModel.statusPending:
        return Icons.schedule;
      case ProcessingJobModel.statusInProgress:
        return Icons.sync;
      case ProcessingJobModel.statusCompleted:
        return Icons.check_circle;
      case ProcessingJobModel.statusFailed:
        return Icons.error;
      case ProcessingJobModel.statusCancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (job!.status) {
      case ProcessingJobModel.statusPending:
        return Theme.of(context).colorScheme.outline;
      case ProcessingJobModel.statusInProgress:
        return Theme.of(context).colorScheme.primary;
      case ProcessingJobModel.statusCompleted:
        return Colors.green;
      case ProcessingJobModel.statusFailed:
        return Theme.of(context).colorScheme.error;
      case ProcessingJobModel.statusCancelled:
        return Theme.of(context).colorScheme.outline;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }
}
