import 'package:flutter/material.dart';
import 'package:lockstars_app/services/auth.dart';

class authProvider extends InheritedWidget {
  final AuthService auth;
  authProvider({
    Key? key,
    required this.auth,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWiddget) {
    return true;
  }

  static authProvider? of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<authProvider>());
}
