import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/services/theme_service.dart';
import 'package:todo_app/theme/app_theme.dart';

Future<void> initHive() async {
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('mybox');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  ThemeService().init();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
        );
      },
    );
  }
}