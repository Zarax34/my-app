import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/local_storage_service.dart';

/// Provider for the local storage service
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final service = LocalStorageService();
  service.init();
  return service;
});

/// Provider for dark mode state
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(ref.watch(localStorageServiceProvider));
});

class DarkModeNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  DarkModeNotifier(this._storage) : super(true) {
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final enabled = await _storage.isDarkModeEnabled();
    state = enabled;
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state;
    state = newValue;
    await _storage.setDarkModeEnabled(newValue);
  }

  Future<void> setDarkMode(bool enabled) async {
    state = enabled;
    await _storage.setDarkModeEnabled(enabled);
  }
}

/// Provider for temperature setting
final temperatureProvider = StateNotifierProvider<TemperatureNotifier, double>(
  (ref) {
    return TemperatureNotifier(ref.watch(localStorageServiceProvider));
  },
);

class TemperatureNotifier extends StateNotifier<double> {
  final LocalStorageService _storage;

  TemperatureNotifier(this._storage) : super(0.7) {
    _loadTemperature();
  }

  Future<void> _loadTemperature() async {
    state = await _storage.getTemperature();
  }

  Future<void> setTemperature(double value) async {
    state = value;
    await _storage.setTemperature(value);
  }
}

/// Provider for context length setting
final contextLengthProvider =
    StateNotifierProvider<ContextLengthNotifier, int>((ref) {
  return ContextLengthNotifier(ref.watch(localStorageServiceProvider));
});

class ContextLengthNotifier extends StateNotifier<int> {
  final LocalStorageService _storage;

  ContextLengthNotifier(this._storage) : super(4096) {
    _loadContextLength();
  }

  Future<void> _loadContextLength() async {
    state = await _storage.getContextLength();
  }

  Future<void> setContextLength(int value) async {
    state = value;
    await _storage.setContextLength(value);
  }
}
