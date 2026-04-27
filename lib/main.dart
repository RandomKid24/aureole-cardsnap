import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService.init();

  final db = AppDatabase();
  await db.contactsDao.cleanOldDrafts(DateTime.now().subtract(const Duration(hours: 24)));
  await cleanOrphanedImages(db);

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  runApp(
    Provider<AppDatabase>.value(
      value: db,
      child: CardSnapApp(seenOnboarding: seenOnboarding),
    ),
  );
}
