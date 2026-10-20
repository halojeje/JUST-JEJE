import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_jeje/main.dart';
import 'package:just_jeje/theme/app_themes.dart';
import 'package:just_jeje/views/login_view.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JustJejeApp());
    expect(find.byType(JustJejeApp), findsOneWidget);
  });

  testWidgets('LoginView renders mockup elements correctly', (WidgetTester tester) async {
    String? loggedName;
    String? loggedEmail;
    String? loggedPic;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(
          theme: AppThemes.allThemes.first,
          onLoginSuccess: (name, email, pic) {
            loggedName = name;
            loggedEmail = email;
            loggedPic = pic;
          },
        ),
      ),
    );

    // Verify title and labels matching the mockup
    expect(find.text('JUST JEJE'), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('lupa kata sandi?'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('atau'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Test entering email and submitting
    final emailField = find.byType(TextField).first;
    await tester.enterText(emailField, 'jeihan.maharani@gmail.com');
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(loggedName, 'Jeihan Maharani');
    expect(loggedEmail, 'jeihan.maharani@gmail.com');
    expect(loggedPic, isNotNull);
  });

  testWidgets('LoginView Sign in with Google triggers callback', (WidgetTester tester) async {
    String? loggedName;
    String? loggedEmail;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(
          theme: AppThemes.allThemes.first,
          onLoginSuccess: (name, email, pic) {
            loggedName = name;
            loggedEmail = email;
          },
        ),
      ),
    );

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();

    expect(loggedName, 'Jeihan Maharani');
    expect(loggedEmail, 'jeihanm@gmail.com');
  });
}
