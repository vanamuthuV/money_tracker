import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/add_expense/add_expense_screen.dart';
import 'core/animations/page_transitions.dart';
import 'features/history/history_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/categories/category_screen.dart';
import 'core/services/app_data_service.dart';

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // initialize app data persistence
    AppDataService.instance.init();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
      theme: AppTheme.dark,
      initialRoute: SplashScreen.route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SplashScreen.route:
            return SlideFadePageRoute(page: const SplashScreen());
          case HomeScreen.route:
            return SlideFadePageRoute(page: const HomeScreen());
          case AddExpenseScreen.route:
            return ScaleFadePageRoute(page: const AddExpenseScreen());
          case HistoryScreen.route:
            return FlipPageRoute(page: const HistoryScreen());
          case SettingsScreen.route:
            return SlideFadePageRoute(page: const SettingsScreen());
          case CategoryScreen.route:
            return SlideFadePageRoute(page: const CategoryScreen());
          default:
            return SlideFadePageRoute(page: const SplashScreen());
        }
      },
    );
  }
}
