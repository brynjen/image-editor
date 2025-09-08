import 'package:equatable/equatable.dart';
import '../../domain/model/settings_model.dart';

/// States for the settings BLoC
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading settings from storage
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Settings loaded successfully
class SettingsLoaded extends SettingsState {
  final ServerSettings settings;
  final bool isTesting;
  final bool isSaving;
  final String? error;

  const SettingsLoaded({
    required this.settings,
    this.isTesting = false,
    this.isSaving = false,
    this.error,
  });

  SettingsLoaded copyWith({
    ServerSettings? settings,
    bool? isTesting,
    bool? isSaving,
    String? error,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isTesting: isTesting ?? this.isTesting,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [settings, isTesting, isSaving, error];
}

/// Settings save operation completed
class SettingsSaved extends SettingsState {
  final ServerSettings settings;

  const SettingsSaved({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// Error occurred
class SettingsError extends SettingsState {
  final String message;
  final ServerSettings? settings;

  const SettingsError({
    required this.message,
    this.settings,
  });

  @override
  List<Object?> get props => [message, settings];
}

