import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cardsnap/app.dart';
import 'package:cardsnap/core/auth/auth_service.dart';
import 'package:cardsnap/core/database/database.dart';

void main() {
  testWidgets('App shows the splash while the session is resolving', (tester) async {
    final db = AppDatabase();
    addTearDown(db.close);
    final auth = AuthService(); // status stays `unknown` (restore not called)

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          ChangeNotifierProvider<AuthService>.value(value: auth),
        ],
        child: CardSnapApp(seenOnboarding: true, auth: auth),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
