import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_jeje/main.dart';
import 'package:just_jeje/models/models.dart';
import 'package:just_jeje/theme/app_themes.dart';
import 'package:just_jeje/views/login_view.dart';
import 'package:just_jeje/views/register_view.dart';
import 'package:just_jeje/widgets/jeje_widget_card.dart';
import 'package:just_jeje/widgets/modals/widget_settings_modal.dart';

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

  testWidgets('JejeWidgetCard renders group title and tasks properly', (WidgetTester tester) async {
    final group = TaskGroup(
      id: 'grp-1',
      title: 'Tugas Kuliah',
      tasks: [
        Task(id: 't-1', text: 'Kerjakan laporan', completed: false, createdAt: 1000),
        Task(id: 't-2', text: 'Presentasi to-do app', completed: true, createdAt: 2000),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JejeWidgetCard(
            group: group,
            theme: AppThemes.allThemes.first,
          ),
        ),
      ),
    );

    expect(find.text('Tugas Kuliah'), findsOneWidget);
    expect(find.text('1/2 Selesai'), findsOneWidget);
    expect(find.text('Kerjakan laporan'), findsOneWidget);
    expect(find.text('Presentasi to-do app'), findsOneWidget);
    expect(find.text('JUST JEJE'), findsOneWidget);
  });

  testWidgets('WidgetSettingsModal renders preview and installation steps', (WidgetTester tester) async {
    final group = TaskGroup(
      id: 'grp-1',
      title: 'Pekerjaan',
      tasks: [
        Task(id: 't-1', text: 'Rapat tim', completed: false, createdAt: 1000),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetSettingsModal(
            taskGroups: [group],
            theme: AppThemes.allThemes.first,
          ),
        ),
      ),
    );

    expect(find.text('Widget Screen Android'), findsOneWidget);
    expect(find.text('Preview Tampilan Widget:'), findsOneWidget);
    expect(find.text('Pekerjaan'), findsOneWidget);
    expect(find.text('Cara Memasang di Layar Utama HP:'), findsOneWidget);
    expect(find.text('Perbarui Widget Sekarang'), findsOneWidget);
  });
}
