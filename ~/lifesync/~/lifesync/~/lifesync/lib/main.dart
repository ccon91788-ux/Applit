import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'core/database/database_helper.dart';
import 'screens/home_shell.dart';
import 'providers/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await DatabaseHelper.instance.database;
  await NotificationService.instance.initialize();
  final themeMode = await AppTheme.loadThemeMode();
  runApp(LifeSyncApp(initialThemeMode: themeMode));
}

class LifeSyncApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const LifeSyncApp({super.key, required this.initialThemeMode});

  @override
  State<LifeSyncApp> createState() => _LifeSyncAppState();
}

class _LifeSyncAppState extends State<LifeSyncApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    AppTheme.saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: MaterialApp(
        title: 'LifeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        locale: const Locale('vi', 'VN'),
        home: HomeShell(themeMode: _themeMode, onThemeChanged: _setThemeMode),
      ),
    );
  }
}
