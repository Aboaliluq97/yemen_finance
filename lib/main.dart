import 'package:flutter/material.dart';

import 'app/app_colors.dart';
import 'database/app_database.dart';
import 'models/account_model.dart';
import 'screens/accounts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.instance.database;

  runApp(const MuhasibiUniversalApp());
}

class MuhasibiUniversalApp extends StatefulWidget {
  const MuhasibiUniversalApp({super.key});

  @override
  State<MuhasibiUniversalApp> createState() =>
      _MuhasibiUniversalAppState();
}

class _MuhasibiUniversalAppState
    extends State<MuhasibiUniversalApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useArabicDigits = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محاسبي الشامل',
      themeMode: _themeMode,
      theme: _buildTheme(
        brightness: Brightness.light,
      ),
      darkTheme: _buildTheme(
        brightness: Brightness.dark,
      ),
      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MuhasibiHomeScreen(
        themeMode: _themeMode,
        useArabicDigits: _useArabicDigits,
        onThemeChanged: (ThemeMode value) {
          setState(() {
            _themeMode = value;
          });
        },
        onArabicDigitsChanged: (bool value) {
          setState(() {
            _useArabicDigits = value;
          });
        },
      ),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark
            ? Colors.white
            : AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? const Color(0xFF192523)
            : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF192523)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white24
                : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.emerald,
            width: 1.5,
          ),
        ),
      ),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class MuhasibiHomeScreen extends StatefulWidget {
  const MuhasibiHomeScreen({
    super.key,
    required this.themeMode,
    required this.useArabicDigits,
    required this.onThemeChanged,
    required this.onArabicDigitsChanged,
  });

  final ThemeMode themeMode;
  final bool useArabicDigits;

  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onArabicDigitsChanged;

  @override
  State<MuhasibiHomeScreen> createState() =>
      _MuhasibiHomeScreenState();
}

class _MuhasibiHomeScreenState
    extends State<MuhasibiHomeScreen> {
  int _selectedIndex = 0;

  void _openAccount(AccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AccountDetailsScreen(
            account: account,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      AccountsScreen(
        onOpenAccount: _openAccount,
      ),
      const OperationsScreen(),
      const ReportsScreen(),
      SettingsScreen(
        themeMode: widget.themeMode,
        useArabicDigits: widget.useArabicDigits,
        onThemeChanged: widget.onThemeChanged,
        onArabicDigitsChanged: widget.onArabicDigitsChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 78,
        selectedIndex: _selectedIndex,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet_rounded,
            ),
            label: 'الحسابات',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
            ),
            label: 'العمليات',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart_rounded,
            ),
            label: 'التقارير',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings_rounded,
            ),
            label: 'التحكم',
          ),
        ],
      ),
    );
  }
}

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({
    super.key,
    required this.account,
  });

  final AccountModel account;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[
                    AppColors.emerald,
                    AppColors.emeraldDark,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'الحساب المفتوح',
                    style: TextStyle(
                      color: Color(0xFFD5F5EA),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    account.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${account.accountType} • ${account.currency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    account.description.isEmpty
                        ? 'لا يوجد وصف لهذا الحساب'
                        : account.description,
                    style: const TextStyle(
                      color: Color(0xFFD5F5EA),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'الأقسام داخل الحساب',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: const <Widget>[
                    Icon(
                      Icons.folder_open_rounded,
                      size: 54,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد أقسام بعد',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'في المرحلة التالية سنضيف الأقسام داخل كل حساب، مثل المبيعات والمصاريف والبضاعة والديون.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BrandFooter(),
          ],
        ),
      ),
    );
  }
}

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.muted,
              ),
              SizedBox(height: 14),
              Text(
                'العمليات المالية',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'هنا ستظهر لاحقًا عمليات الدخل والمصروف والتحويل بين الحسابات.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: AppColors.muted,
              ),
              SizedBox(height: 14),
              Text(
                'التقارير والجداول',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'هنا ستظهر تقارير الدخل والمصروف والأرصدة والتصدير إلى PDF وCSV.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.useArabicDigits,
    required this.onThemeChanged,
    required this.onArabicDigitsChanged,
  });

  final ThemeMode themeMode;
  final bool useArabicDigits;

  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onArabicDigitsChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          110,
        ),
        children: <Widget>[
          const Text(
            'مركز التحكم',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'إعدادات المظهر وطريقة عرض الأرقام.',
            style: TextStyle(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode_rounded,
                  ),
                  title: const Text('الوضع الداكن'),
                  subtitle: const Text(
                    'تفعيل واجهة داكنة مريحة للعين',
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    onThemeChanged(
                      value
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.numbers_rounded,
                  ),
                  title: const Text('الأرقام العربية'),
                  subtitle: const Text(
                    'استخدام ١٢٣ بدلاً من 123',
                  ),
                  value: useArabicDigits,
                  onChanged: onArabicDigitsChanged,
                ),
              ],
            ),
          ),
          const BrandFooter(),
        ],
      ),
    );
  }
}

class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 26,
      ),
      child: Text(
        '© 2026 جميع الحقوق محفوظة لـ محاسبي الشامل | صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان (هاتف: 0967775592894)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.6,
        ),
      ),
    );
  }
}
