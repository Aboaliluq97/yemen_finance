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

  ThemeMode _themeMode = ThemeMode.light;
  bool _useArabicDigits = false;

  bool _isLoadingLockStatus = true;
  bool _isApplicationUnlocked = false;
  bool _mustLockOnResume = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _prepareApplicationLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _prepareApplicationLock() async {
    final bool isLockEnabled =
        await _lockService.isLockEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingLockStatus = false;
      _isApplicationUnlocked = !isLockEnabled;
    });
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _mustLockOnResume = true;
    }

    if (state == AppLifecycleState.resumed &&
        _mustLockOnResume) {
      _lockApplicationWhenNeeded();
    }
  }

  Future<void> _lockApplicationWhenNeeded() async {
    _mustLockOnResume = false;

    final bool isLockEnabled =
        await _lockService.isLockEnabled();

    if (!mounted || !isLockEnabled) {
      return;
    }

    setState(() {
      _isApplicationUnlocked = false;
    });
  }

  void _unlockApplication() {
    setState(() {
      _isApplicationUnlocked = true;
    });
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
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark
            ? Colors.white
            : AppColors.ink,
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
      home: _isLoadingLockStatus
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isApplicationUnlocked
              ? MuhasibiHomeScreen(
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
                )
              : AppLockScreen(
                  onUnlocked: _unlockApplication,
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
            useArabicDigits: widget.useArabicDigits,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardScreen(
        useArabicDigits: widget.useArabicDigits,
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
        useArabicDigits: widget.useArabicDigits,
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
    required this.useArabicDigits,
    required this.onOpenAccounts,
  });

  final bool useArabicDigits;
  final VoidCallback onOpenAccounts;

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AccountRepository _accountRepository =
      AccountRepository.instance;

  bool _isLoading = true;
  List<AccountModel> _accounts = <AccountModel>[];

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final List<AccountModel> accounts =
        await _accountRepository.getAllAccounts();

    if (!mounted) {
      return;
    }

    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  double get _totalOpeningBalance {
    return _accounts.fold<double>(
      0.0,
      (
        double total,
        AccountModel account,
      ) {
        return total + account.openingBalance;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
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
                          'إجمالي الرصيد الافتتاحي',
                          style: TextStyle(
                            color: Color(0xFFD5F5EA),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatAmount(
                            _totalOpeningBalance,
                            arabicDigits:
                                widget.useArabicDigits,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'سيتم تحديث الرصيد تلقائيًا عند إضافة الدخل والمصروف والتحويلات.',
                          style: TextStyle(
                            color: Color(0xFFD5F5EA),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'الحسابات',
                          value: _accounts.length.toString(),
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _SummaryCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'العمليات',
                          value: '0',
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                        child: const Text(
                          'عرض الحسابات',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_accounts.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: <Widget>[
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 48,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد حسابات بعد',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'أنشئ حسابك الأول من تبويب الحسابات.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: widget.onOpenAccounts,
                              child: const Text(
                                'الذهاب إلى الحسابات',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._accounts.take(5).map(
                      (AccountModel account) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.emerald.withValues(
                                  alpha: 0.14,
                                ),
                                foregroundColor:
                                    AppColors.emerald,
                                child: const Icon(
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
                                      widget.useArabicDigits,
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
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({
    super.key,
    required this.account,
    required this.useArabicDigits,
  });

  final AccountModel account;
  final bool useArabicDigits;

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
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'الرصيد الافتتاحي: ${formatAmount(
                      account.openingBalance,
                      arabicDigits: useArabicDigits,
                    )}',
                    style: const TextStyle(
                      color: Color(0xFFD5F5EA),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'الأقسام والعمليات',
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
                      size: 52,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'إدارة الأقسام ستضاف في التحديث التالي',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'المرحلة التالية ستضيف إنشاء الأقسام وإضافة عمليات الدخل والمصروف والتحويل داخل كل حساب.',
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
                'سيتم هنا تسجيل الدخل والمصروف والتحويلات وربطها بالأقسام.',
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
                'سيتم هنا عرض التقارير وتصدير PDF وCSV ومشاركة الملفات.',
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

class SettingsScreen extends StatefulWidget {
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
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppLockService _lockService =
      AppLockService.instance;

  bool _isLoadingSecurity = true;
  bool _isLockEnabled = false;
  bool _isBiometricsEnabled = false;
  bool _isBiometricsAvailable = false;

  @override
  void initState() {
    super.initState();

    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    final bool isLockEnabled =
        await _lockService.isLockEnabled();

    final bool isBiometricsEnabled =
        await _lockService.isBiometricsEnabled();

    final bool isBiometricsAvailable =
        await _lockService.canUseBiometrics();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLockEnabled = isLockEnabled;
      _isBiometricsEnabled = isBiometricsEnabled;
      _isBiometricsAvailable =
          isBiometricsAvailable;
      _isLoadingSecurity = false;
    });
  }

  Future<void> _showEnableLockDialog() async {
    final TextEditingController pinController =
        TextEditingController();

    final TextEditingController confirmPinController =
        TextEditingController();

    bool enableBiometrics =
        _isBiometricsAvailable;

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
                      'أنشئ رمزًا سريًا من 4 إلى 6 أرقام. ستستخدمه عند عدم توفر البصمة.',
                      style: TextStyle(
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الرمز السري',
                        hintText: '4 إلى 6 أرقام',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPinController,
                      obscureText: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'تأكيد الرمز السري',
                        counterText: '',
                      ),
                    ),
                    if (_isBiometricsAvailable)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'السماح بالفتح بالبصمة',
                        ),
                        subtitle: const Text(
                          'يمكنك دائمًا استخدام الرمز السري',
                        ),
                        value: enableBiometrics,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            enableBiometrics =
                                value ?? false;
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

                    final String confirmPin =
                        confirmPinController.text.trim();

                    final bool isValidPin =
                        RegExp(r'^\d{4,6}$').hasMatch(
                      pin,
                    );

                    if (!isValidPin) {
                      _showMessage(
                        'الرمز السري يجب أن يكون من 4 إلى 6 أرقام.',
                        isError: true,
                      );
                      return;
                    }

                    if (pin != confirmPin) {
                      _showMessage(
                        'الرمزان السريان غير متطابقين.',
                        isError: true,
                      );
                      return;
                    }

                    await _lockService.enableLock(
                      pinCode: pin,
                      enableBiometrics:
                          enableBiometrics,
                    );

                    if (!mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _loadSecurityStatus();

                    _showMessage(
                      'تم تفعيل قفل التطبيق بنجاح.',
                    );
                  },
                  child: const Text('تفعيل القفل'),
                ),
              ],
            );
          },
        );
      },
    );

    pinController.dispose();
    confirmPinController.dispose();
  }

  Future<void> _disableLock() async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إيقاف قفل التطبيق'),
          content: const Text(
            'سيصبح التطبيق متاحًا دون بصمة أو رمز سري. هل تريد المتابعة؟',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('إيقاف القفل'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _lockService.disableLock();

    await _loadSecurityStatus();

    _showMessage(
      'تم إيقاف قفل التطبيق.',
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? AppColors.danger : AppColors.emerald,
          content: Text(message),
        ),
      );
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
