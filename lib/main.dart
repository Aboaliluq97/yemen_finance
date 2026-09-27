import 'package:flutter/material.dart';

import 'app/app_colors.dart';
import 'core/formatters.dart';
import 'database/app_database.dart';
import 'models/account_model.dart';
import 'repositories/account_repository.dart';
import 'screens/accounts_screen.dart';
import 'screens/app_lock_screen.dart';
import 'services/app_lock_service.dart';

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
    extends State<MuhasibiUniversalApp>
    with WidgetsBindingObserver {
  final AppLockService _lockService =
      AppLockService.instance;

  bool _loading = true;
  bool _unlocked = false;
  bool _shouldLockOnResume = false;

  ThemeMode _themeMode = ThemeMode.light;
  bool _arabicDigits = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _checkLockStatus() async {
    final bool enabled =
        await _lockService.isLockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      _unlocked = !enabled;
    });
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _shouldLockOnResume = true;
    }

    if (state == AppLifecycleState.resumed &&
        _shouldLockOnResume) {
      _lockWhenNeeded();
    }
  }

  Future<void> _lockWhenNeeded() async {
    _shouldLockOnResume = false;

    final bool enabled =
        await _lockService.isLockEnabled();

    if (!mounted || !enabled) {
      return;
    }

    setState(() {
      _unlocked = false;
    });
  }

  void _unlock() {
    setState(() {
      _unlocked = true;
    });
  }

  ThemeData _theme(Brightness brightness) {
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
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? const Color(0xFF192523)
            : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محاسبي الشامل',
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _loading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _unlocked
              ? HomeScreen(
                  themeMode: _themeMode,
                  arabicDigits: _arabicDigits,
                  onThemeChanged: (ThemeMode value) {
                    setState(() {
                      _themeMode = value;
                    });
                  },
                  onArabicDigitsChanged: (
                    bool value,
                  ) {
                    setState(() {
                      _arabicDigits = value;
                    });
                  },
                )
              : AppLockScreen(
                  onUnlocked: _unlock,
                ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.arabicDigits,
    required this.onThemeChanged,
    required this.onArabicDigitsChanged,
  });

  final ThemeMode themeMode;
  final bool arabicDigits;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onArabicDigitsChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _openAccount(AccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AccountDetailsScreen(
            account: account,
            arabicDigits: widget.arabicDigits,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardScreen(
        arabicDigits: widget.arabicDigits,
        onOpenAccounts: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      AccountsScreen(
        onOpenAccount: _openAccount,
      ),
      const OperationsScreen(),
      const ReportsScreen(),
      SettingsScreen(
        themeMode: widget.themeMode,
        arabicDigits: widget.arabicDigits,
        onThemeChanged: widget.onThemeChanged,
        onArabicDigitsChanged:
            widget.onArabicDigitsChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 78,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
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
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'العمليات',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'التقارير',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'التحكم',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.arabicDigits,
    required this.onOpenAccounts,
  });

  final bool arabicDigits;
  final VoidCallback onOpenAccounts;

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AccountRepository _repository =
      AccountRepository.instance;

  late Future<List<AccountModel>> _accountsFuture;

  @override
  void initState() {
    super.initState();

    _accountsFuture = _repository.getAllAccounts();
  }

  Future<void> _refresh() async {
    setState(() {
      _accountsFuture = _repository.getAllAccounts();
    });

    await _accountsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<AccountModel>>(
        future: _accountsFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<AccountModel>> snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<AccountModel> accounts =
              snapshot.data ?? <AccountModel>[];

          final double total = accounts.fold<double>(
            0.0,
            (
              double currentTotal,
              AccountModel account,
            ) {
              return currentTotal +
                  account.openingBalance;
            },
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                110,
              ),
              children: <Widget>[
                const Text(
                  'الرئيسية',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'نظرة سريعة على حساباتك وأرصدتك.',
                  style: TextStyle(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
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
                        'إجمالي الرصيد الافتتاحي',
                        style: TextStyle(
                          color: Color(0xFFD5F5EA),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatAmount(
                          total,
                          arabicDigits: widget.arabicDigits,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'عدد الحسابات: ${accounts.length}',
                        style: const TextStyle(
                          color: Color(0xFFD5F5EA),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'أحدث الحسابات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onOpenAccounts,
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (accounts.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons
                                .account_balance_wallet_outlined,
                            size: 52,
                            color: AppColors.muted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'لا توجد حسابات بعد',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: widget.onOpenAccounts,
                            child: const Text(
                              'إنشاء حساب',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...accounts.take(5).map(
                    (AccountModel account) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor:
                                  AppColors.emerald,
                              foregroundColor: Colors.white,
                              child: Icon(
                                Icons
                                    .account_balance_wallet_rounded,
                              ),
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(
                              '${account.accountType} • ${account.currency}',
                            ),
                            trailing: Text(
                              formatAmount(
                                account.openingBalance,
                                arabicDigits:
                                    widget.arabicDigits,
                              ),
                              style: const TextStyle(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const BrandFooter(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({
    super.key,
    required this.account,
    required this.arabicDigits,
  });

  final AccountModel account;
  final bool arabicDigits;

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
                  Text(
                    account.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${account.accountType} • ${account.currency}',
                    style: const TextStyle(
                      color: Color(0xFFD5F5EA),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'الرصيد الافتتاحي: ${formatAmount(
                      account.openingBalance,
                      arabicDigits: arabicDigits,
                    )}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.folder_open_rounded,
                      size: 52,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'الأقسام والعمليات',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'سيتم في المرحلة التالية إضافة الأقسام وعمليات الدخل والمصروف والتحويل داخل هذا الحساب.',
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
        child: Text(
          'العمليات المالية ستظهر هنا بعد إضافة الأقسام.',
          textAlign: TextAlign.center,
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
        child: Text(
          'التقارير ستظهر هنا بعد إضافة العمليات المالية.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.arabicDigits,
    required this.onThemeChanged,
    required this.onArabicDigitsChanged,
  });

  final ThemeMode themeMode;
  final bool arabicDigits;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onArabicDigitsChanged;

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final AppLockService _lockService =
      AppLockService.instance;

  bool _loadingSecurity = true;
  bool _lockEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();

    _loadSecurity();
  }

  Future<void> _loadSecurity() async {
    final bool enabled =
        await _lockService.isLockEnabled();

    final bool biometricAvailable =
        await _lockService.canUseBiometrics();

    if (!mounted) {
      return;
    }

    setState(() {
      _lockEnabled = enabled;
      _biometricAvailable = biometricAvailable;
      _loadingSecurity = false;
    });
  }

  Future<void> _enableLock() async {
    final TextEditingController pinController =
        TextEditingController();

    final TextEditingController confirmController =
        TextEditingController();

    bool useBiometrics = _biometricAvailable;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'تفعيل قفل التطبيق',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'أنشئ رمزًا سريًا من 4 إلى 6 أرقام.',
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'الرمز السري',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'تأكيد الرمز',
                        counterText: '',
                      ),
                    ),
                    if (_biometricAvailable)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'تفعيل البصمة',
                        ),
                        value: useBiometrics,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            useBiometrics = value ?? false;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () async {
                    final String pin =
                        pinController.text.trim();

                    final String confirm =
                        confirmController.text.trim();

                    if (!RegExp(r'^\d{4,6}$')
                        .hasMatch(pin)) {
                      return;
                    }

                    if (pin != confirm) {
                      return;
                    }

                    await _lockService.enableLock(
                      pinCode: pin,
                      enableBiometrics: useBiometrics,
                    );

                    if (!mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _loadSecurity();
                  },
                  child: const Text('تفعيل'),
                ),
              ],
            );
          },
        );
      },
    );

    pinController.dispose();
    confirmController.dispose();
  }

  Future<void> _disableLock() async {
    await _lockService.disableLock();

    await _loadSecurity();
  }

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
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode_rounded,
                  ),
                  title: const Text('الوضع الداكن'),
                  value:
                      widget.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    widget.onThemeChanged(
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
                  value: widget.arabicDigits,
                  onChanged:
                      widget.onArabicDigitsChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'الأمان وقفل التطبيق',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: _loadingSecurity
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ListTile(
                    leading: Icon(
                      _lockEnabled
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      color: _lockEnabled
                          ? AppColors.emerald
                          : AppColors.muted,
                    ),
                    title: Text(
                      _lockEnabled
                          ? 'قفل التطبيق مفعّل'
                          : 'قفل التطبيق غير مفعّل',
                    ),
                    subtitle: Text(
                      _lockEnabled
                          ? 'سيتم طلب البصمة أو الرمز عند العودة للتطبيق.'
                          : 'فعّل القفل لحماية بياناتك المالية.',
                    ),
                    trailing: const Icon(
                      Icons.chevron_left_rounded,
                    ),
                    onTap: _lockEnabled
                        ? _disableLock
                        : _enableLock,
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
        vertical: 28,
      ),
      child: Text(
        '© 2026 جميع الحقوق محفوظة لـ محاسبي الشامل | صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان',
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
