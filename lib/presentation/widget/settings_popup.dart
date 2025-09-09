import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../domain/model/settings_model.dart';

/// Settings popup widget that shows server configuration and model status
class SettingsPopup extends StatelessWidget {
  const SettingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const SettingsLoadRequested()),
      child: const _SettingsPopupView(),
    );
  }
}

/// Internal settings popup view with BLoC access
class _SettingsPopupView extends StatefulWidget {
  const _SettingsPopupView();

  @override
  State<_SettingsPopupView> createState() => _SettingsPopupViewState();
}

class _SettingsPopupViewState extends State<_SettingsPopupView> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  String _selectedScheme = 'http';

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _updateControllers(ServerSettings settings) {
    // Update text without triggering full text selection
    _hostController.text = settings.host;
    _portController.text = settings.port.toString();
    _selectedScheme = settings.scheme;
    
    // Set cursor position to end of text to avoid full selection
    _hostController.selection = TextSelection.collapsed(offset: _hostController.text.length);
    _portController.selection = TextSelection.collapsed(offset: _portController.text.length);
  }

  void _onSettingsChanged() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SettingsBloc>().add(SettingsServerUpdated(
        host: _hostController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 8000,
        scheme: _selectedScheme,
      ));
    }
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SettingsBloc>().add(const SettingsSaveRequested());
    }
  }

  void _testConnection() {
    if (_formKey.currentState?.validate() ?? false) {
      _onSettingsChanged(); // Update settings first
      context.read<SettingsBloc>().add(const SettingsConnectionTestRequested());
    }
  }

  String? _validateHost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host is required';
    }
    
    final host = value.trim();
    
    // Basic validation for IP address or hostname
    if (host == 'localhost') return null;
    
    // Simple IP address pattern
    final ipPattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (ipPattern.hasMatch(host)) {
      // Validate IP octets
      final parts = host.split('.');
      for (final part in parts) {
        final octet = int.tryParse(part);
        if (octet == null || octet < 0 || octet > 255) {
          return 'Invalid IP address';
        }
      }
      return null;
    }
    
    // Simple hostname validation
    final hostnamePattern = RegExp(r'^[a-zA-Z0-9.-]+$');
    if (!hostnamePattern.hasMatch(host)) {
      return 'Invalid hostname format';
    }
    
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required';
    }
    
    final port = int.tryParse(value.trim());
    if (port == null || port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          _updateControllers(state.settings);
        } else if (state is SettingsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 700),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final settings = state is SettingsLoaded 
                  ? state.settings 
                  : state is SettingsError 
                      ? state.settings ?? ServerSettings.initial()
                      : ServerSettings.initial();
              
              final isLoaded = state is SettingsLoaded;
              final isTesting = isLoaded ? state.isTesting : false;
              final isSaving = isLoaded ? state.isSaving : false;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Server Configuration Section
                            _buildSectionHeader('Server Configuration'),
                            const SizedBox(height: 16),
                            
                            // Protocol dropdown
                            _buildDropdown(
                              label: 'Protocol',
                              value: _selectedScheme,
                              items: const [
                                DropdownMenuItem(value: 'http', child: Text('HTTP')),
                                DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedScheme = value!);
                                _onSettingsChanged();
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Host field
                            _buildTextField(
                              controller: _hostController,
                              label: 'Host / IP Address',
                              hint: 'e.g., 192.168.1.100 or localhost',
                              prefixIcon: Icons.computer,
                              validator: _validateHost,
                              onChanged: (_) => _onSettingsChanged(),
                            ),
                            const SizedBox(height: 16),
                            
                            // Port field
                            _buildTextField(
                              controller: _portController,
                              label: 'Port',
                              hint: '8000',
                              prefixIcon: Icons.router,
                              validator: _validatePort,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => _onSettingsChanged(),
                            ),
                            const SizedBox(height: 16),
                            
                            // URL Preview
                            _buildUrlPreview(settings.url),
                            const SizedBox(height: 32),
                            
                            // Server Status Section
                            _buildSectionHeader('Server Status'),
                            const SizedBox(height: 16),
                            _buildServerStatus(settings, isTesting),
                            const SizedBox(height: 32),
                            
                            // Model Status Section
                            _buildSectionHeader('Model Status'),
                            const SizedBox(height: 16),
                            _buildModelStatus(settings.modelStatus),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Actions
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: isTesting || isSaving ? null : _testConnection,
                          icon: isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.network_check, size: 18),
                          label: Text(isTesting ? 'Testing...' : 'Test Connection'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: isTesting || isSaving ? null : () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isTesting || isSaving ? null : _saveSettings,
                          child: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            prefixIcon: Icon(prefixIcon),
          ),
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildUrlPreview(String url) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Server URL: $url',
              style: TextStyle(
                color: Colors.blue[800],
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerStatus(ServerSettings settings, bool isTesting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(settings.isConnected).withOpacity(0.3)),
        color: _getStatusColor(settings.isConnected).withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settings.isConnected ? Icons.check_circle : Icons.error,
                color: _getStatusColor(settings.isConnected),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  settings.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(settings.isConnected),
                  ),
                ),
              ),
              if (settings.lastChecked != null)
                Text(
                  'Last checked: ${_formatTime(settings.lastChecked!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          if (settings.connectionError != null) ...[
            const SizedBox(height: 8),
            Text(
              settings.connectionError!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelStatus(ModelStatus modelStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getModelStatusColor(modelStatus).withOpacity(0.3)),
        color: _getModelStatusColor(modelStatus).withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getModelStatusIcon(modelStatus),
                color: _getModelStatusColor(modelStatus),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getModelStatusText(modelStatus),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getModelStatusColor(modelStatus),
                  ),
                ),
              ),
            ],
          ),
          
          if (modelStatus.modelName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Model: ${modelStatus.modelName}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          
          if (modelStatus.isDownloading) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Download Progress',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${(modelStatus.downloadProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: modelStatus.downloadProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getModelStatusColor(modelStatus),
                  ),
                ),
              ],
            ),
          ],
          
          if (modelStatus.error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${modelStatus.error}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
              ),
            ),
          ],
          
          if (modelStatus.lastChecked != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last checked: ${_formatTime(modelStatus.lastChecked!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(bool isConnected) {
    return isConnected ? Colors.green : Colors.red;
  }

  Color _getModelStatusColor(ModelStatus status) {
    if (status.error != null) return Colors.red;
    if (status.isLoaded) return Colors.green;
    if (status.isDownloading) return Colors.orange;
    return Colors.grey;
  }

  IconData _getModelStatusIcon(ModelStatus status) {
    if (status.error != null) return Icons.error;
    if (status.isLoaded) return Icons.check_circle;
    if (status.isDownloading) return Icons.download;
    return Icons.help_outline;
  }

  String _getModelStatusText(ModelStatus status) {
    if (status.error != null) return 'Error';
    if (status.isLoaded) return 'Model Loaded';
    if (status.isDownloading) return 'Downloading Model';
    return 'Model Not Available';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
