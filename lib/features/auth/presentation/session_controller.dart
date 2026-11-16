import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionController extends Notifier<bool> {
  @override
  bool build() => false;

  void signIn() => state = true;

  void signOut() => state = false;
}

final sessionProvider = NotifierProvider<SessionController, bool>(
  SessionController.new,
);
