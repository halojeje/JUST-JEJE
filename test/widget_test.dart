import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_jeje/main.dart';
import 'package:just_jeje/theme/app_themes.dart';
import 'package:just_jeje/views/login_view.dart';
import 'package:just_jeje/views/register_view.dart';

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
    expect(find.text('First time user? '), findsOneWidget);
    expect(find.text('Register here'), findsOneWidget);

    // Test entering email and submitting
    final emailField = find.byType(TextField).first;
    await tester.enterText(emailField, 'jeihan.maharani@gmail.com');
    await tester.tap(find.text('LOGIN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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
    await tester.pump(const Duration(milliseconds: 100));

    expect(loggedName, 'Jeihan Maharani');
    expect(loggedEmail, 'jeihanm@gmail.com');
  });

  testWidgets('RegisterView renders all required fields and validates 6 digit password', (WidgetTester tester) async {
    String? registeredName;

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterView(
          theme: AppThemes.allThemes.first,
          onNavigateLogin: () {},
          onRegisterSuccess: (name, email, pic) {
            registeredName = name;
          },
        ),
      ),
    );

    // Verify REGISTER card and form labels
    expect(find.text('REGISTER'), findsNWidgets(2));
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Login here'), findsOneWidget);

    // Test password < 6 digits fails
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'jeihan');
    await tester.enterText(fields.at(1), 'jeihan@gmail.com');
    await tester.enterText(fields.at(2), '12345'); // only 5 digits
    await tester.tap(find.widgetWithText(ElevatedButton, 'REGISTER'));
    await tester.pump();

    expect(find.text('Password harus minimal 6 digit!'), findsOneWidget);
    expect(registeredName, isNull);

    // Test password >= 6 digits succeeds
    await tester.enterText(fields.at(2), '123456'); // 6 digits
    await tester.tap(find.widgetWithText(ElevatedButton, 'REGISTER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(registeredName, 'jeihan');
  });
}
