import 'package:flutter_riverpod/flutter_riverpod.dart';

class Preferences {
  const Preferences({
    this.reminders = true,
    this.biometrics = true,
    this.reduceMotion = false,
  });

  final bool reminders;
  final bool biometrics;
  final bool reduceMotion;

  Preferences copyWith({
    bool? reminders,
    bool? biometrics,
    bool? reduceMotion,
  }) => Preferences(
    reminders: reminders ?? this.reminders,
    biometrics: biometrics ?? this.biometrics,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}

class PreferencesController extends Notifier<Preferences> {
  @override
  Preferences build() => const Preferences();

  void setReminders(bool v) => state = state.copyWith(reminders: v);

  void setBiometrics(bool v) => state = state.copyWith(biometrics: v);

  void setReduceMotion(bool v) => state = state.copyWith(reduceMotion: v);
}

final preferencesProvider =
    NotifierProvider<PreferencesController, Preferences>(
      PreferencesController.new,
    );
