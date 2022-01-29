import 'package:flutter/material.dart';
import 'package:lockstars_app/services/database.dart';
import 'package:lockstars_app/shared/globals.dart';

class dbProvider extends InheritedWidget {
  DatabaseService db = DatabaseService(uid: GlobalData.whoami.uid ?? "");
  dbProvider({
    Key? key,
    required this.db,
    required Widget child,
  }) : super(key: key, child: child);
  @override
  bool updateShouldNotify(InheritedWidget oldWiddget) {
    return true;
  }

  static dbProvider? of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<dbProvider>());
}
