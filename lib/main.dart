import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'core/auth/auth_service.dart';
import 'core/database/database.dart';
import 'core/notifications/notification_service.dart';

Future<void> cleanOrphanedImages(AppDatabase db) async {
  final dir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory('${dir.path}/card_images');
  if (!await imagesDir.exists()) return;

  final contacts = await db.contactsDao.getAllContacts();
  final validPaths = contacts
      .expand((c) => [c.imageFrontPath, c.imageBackPath])
      .whereType<String>()
      .toSet();

  await for (final file in imagesDir.list()) {
    if (file is File && !validPaths.contains(file.path)) {
      await file.delete();
    }
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // The database is the only piece the app genuinely can't run without.
    final db = AppDatabase();

    // Everything else is best-effort — a failure here must not block startup.
    try {
      await NotificationService.init();
    } catch (e, s) {
      debugPrint('Startup: NotificationService.init failed: $e\n$s');
    }
    try {
      await db.contactsDao.cleanOldDrafts(DateTime.now().subtract(const Duration(hours: 24)));
      await cleanOrphanedImages(db);
    } catch (e, s) {
      debugPrint('Startup: housekeeping failed: $e\n$s');
    }

    bool seenOnboarding = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    } catch (e, s) {
      debugPrint('Startup: could not read prefs: $e\n$s');
    }

    // HRMS/RBAC session. restore() runs in the background — the router shows a
    // splash until it resolves to authenticated / unauthenticated.
    final auth = AuthService();
    unawaited(auth.restore());

    runApp(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          ChangeNotifierProvider<AuthService>.value(value: auth),
        ],
        child: CardSnapApp(seenOnboarding: seenOnboarding, auth: auth),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}
