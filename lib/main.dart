import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuhasibiApp());
}

class MuhasibiApp extends StatefulWidget {
  const MuhasibiApp({super.key});

  @override
  State<MuhasibiApp> createState() => _MuhasibiAppState();
}

class _MuhasibiAppState extends State<MuhasibiApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useArabicNumerals = false;
  FontHierarchy _fontHierarchy = FontHierarchy.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محاسبي',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MuhasibiHome(
        themeMode: _themeMode,
        fontHierarchy: _fontHierarchy,
        useArabicNumerals: _useArabicNumerals,
        onThemeModeChanged: (ThemeMode value) {
          setState(() {
            _themeMode = value;
          });
        },
        onFontHierarchyChanged: (FontHierarchy value) {
          setState(() {
            _fontHierarchy = value;
          });
        },
        onArabicNumeralsChanged: (bool value) {
          setState(() {
            _useArabicNumerals = value;
          });
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF101716) : const Color(0xFFF4F8F6),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.ink,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF192523) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
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
    );
  }

  TextTheme _buildTextTheme() {
    String? family;

    switch (_fontHierarchy) {
      case FontHierarchy.system:
        family = null;
      case FontHierarchy.serif:
        family = 'serif';
      case FontHierarchy.monospace:
        family = 'monospace';
    }

    return Typography.material2021().black.apply(
          fontFamily: family,
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        );
  }
}

enum FontHierarchy {
  system,
  serif,
  monospace,
}

class AppColors {
  static const Color emerald = Color(0xFF00695C);
  static const Color emeraldDark = Color(0xFF004D40);
  static const Color emeraldLight = Color(0xFF15A38A);
  static const Color gold = Color(0xFFE2B333);
  static const Color ink = Color(0xFF17201E);
  static const Color muted = Color(0xFF66706D);
  static const Color danger = Color(0xFFC62828);
  static const Color income = Color(0xFF15803D);
  static const Color expense = Color(0xFFB91C1C);
}

class MuhasibiHome extends StatefulWidget {
  const MuhasibiHome({
    super.key,
    required this.themeMode,
    required this.fontHierarchy,
    required this.useArabicNumerals,
    required this.onThemeModeChanged,
    required this.onFontHierarchyChanged,
    required this.onArabicNumeralsChanged,
  });

  final ThemeMode themeMode;
  final FontHierarchy fontHierarchy;
  final bool useArabicNumerals;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<FontHierarchy> onFontHierarchyChanged;
  final ValueChanged<bool> onArabicNumeralsChanged;

  @override
  State<MuhasibiHome> createState() => _MuhasibiHomeState();
}

class _MuhasibiHomeState extends State<MuhasibiHome> {
  int _currentIndex = 0;

  final FinancialController _controller = FinancialController.demo();

  final UserProfile _profile = UserProfile(
    fullName: 'أبو علي لقمان',
    avatarLetters: 'AL',
    phone: '967777123456',
  );

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      WalletDashboardTab(
        controller: _controller,
        useArabicNumerals: widget.useArabicNumerals,
        onChanged: _refresh,
      ),
      TransactionsTab(
        controller: _controller,
        useArabicNumerals: widget.useArabicNumerals,
        onChanged: _refresh,
      ),
      DebtLedgerTab(
        controller: _controller,
        useArabicNumerals: widget.useArabicNumerals,
      ),
      ProfileTab(
        profile: _profile,
        themeMode: widget.themeMode,
        fontHierarchy: widget.fontHierarchy,
        useArabicNumerals: widget.useArabicNumerals,
        onThemeModeChanged: widget.onThemeModeChanged,
        onFontHierarchyChanged: widget.onFontHierarchyChanged,
        onArabicNumeralsChanged: widget.onArabicNumeralsChanged,
        onProfileChanged: _refresh,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'المحافظ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'العمليات',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake_rounded),
            label: 'الديون',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}

class FinancialController {
  FinancialController({
    required List<WalletFolder> wallets,
    required List<TransactionRecord> transactions,
    required List<DebtRecord> debts,
  })  : _wallets = wallets,
        _transactions = transactions,
        _debts = debts;

  factory FinancialController.demo() {
    return FinancialController(
      wallets: <WalletFolder>[
        WalletFolder(
          id: 'daily',
          title: 'المصروفات اليومية',
          subtitle: 'احتياجات المنزل والتنقل',
          balance: 50000.0,
          icon: Icons.shopping_basket_rounded,
          color: const Color(0xFF0284C7),
        ),
        WalletFolder(
          id: 'jamiya',
          title: 'الجمعية والادخار',
          subtitle: 'التزام شهري محفوظ',
          balance: 20000.0,
          icon: Icons.savings_rounded,
          color: const Color(0xFF7C3AED),
        ),
        WalletFolder(
          id: 'strategic',
          title: 'الادخار الاستراتيجي',
          subtitle: 'أهداف طويلة المدى',
          balance: 30000.0,
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF0F766E),
        ),
      ],
      transactions: <TransactionRecord>[
        TransactionRecord(
          id: 't1',
          title: 'راتب شهر يونيو',
          category: 'دخل',
          dateLabel: '24 يونيو 2026 م | 8 محرم 1448 هـ',
          notes: 'تم استلام الراتب وتحويله تلقائياً إلى المحافظ.',
          label: 'Received salary',
          amount: 100000.0,
          type: TransactionType.income,
          createdAt: DateTime(2026, 6, 24),
        ),
        TransactionRecord(
          id: 't2',
          title: 'قسط دين عائلي',
          category: 'التزامات',
          dateLabel: '23 يونيو 2026 م | 7 محرم 1448 هـ',
          notes: 'سداد جزء من التزام سابق.',
          label: 'Paid off debt',
          amount: 12500.0,
          type: TransactionType.expense,
          createdAt: DateTime(2026, 6, 23),
        ),
        TransactionRecord(
          id: 't3',
          title: 'تحويل للأسرة',
          category: 'تحويلات',
          dateLabel: '21 يونيو 2026 م | 5 محرم 1448 هـ',
          notes: 'مساعدة مالية شهرية للأسرة.',
          label: 'Sent to family',
          amount: 8200.0,
          type: TransactionType.expense,
          createdAt: DateTime(2026, 6, 21),
        ),
      ],
      debts: <DebtRecord>[
        DebtRecord(
          id: 'd1',
          name: 'أحمد محمد',
          phone: '967771234567',
          category: 'عميل',
          amount: 85000.0,
          note: 'قيمة بضاعة مستحقة',
          dueDateLabel: 'مستحق في 30 يونيو 2026',
          isReceivable: true,
        ),
        DebtRecord(
          id: 'd2',
          name: 'متجر النور',
          phone: '967739876543',
          category: 'مورد',
          amount: 46000.0,
          note: 'رصيد توريد مواد',
          dueDateLabel: 'مستحق في 5 يوليو 2026',
          isReceivable: false,
        ),
      ],
    );
  }

  final List<WalletFolder> _wallets;
  final List<TransactionRecord> _transactions;
  final List<DebtRecord> _debts;

  List<WalletFolder> get wallets => List<WalletFolder>.unmodifiable(_wallets);

  List<TransactionRecord> get transactions =>
      List<TransactionRecord>.unmodifiable(_transactions);

  List<DebtRecord> get debts => List<DebtRecord>.unmodifiable(_debts);

  double get totalWalletBalance {
    return _wallets.fold<double>(
      0.0,
      (double sum, WalletFolder wallet) => sum + wallet.balance,
    );
  }

  double get totalIncome {
    return _transactions
        .where(
          (TransactionRecord item) => item.type == TransactionType.income,
        )
        .fold<double>(
          0.0,
          (double sum, TransactionRecord item) => sum + item.amount,
        );
  }

  double get totalExpenses {
    return _transactions
        .where(
          (TransactionRecord item) => item.type == TransactionType.expense,
        )
        .fold<double>(
          0.0,
          (double sum, TransactionRecord item) => sum + item.amount,
        );
  }

  double get netBalance => totalWalletBalance;

  double get totalReceivables {
    return _debts
        .where((DebtRecord item) => item.isReceivable)
        .fold<double>(
          0.0,
          (double sum, DebtRecord item) => sum + item.amount,
        );
  }

  double get totalPayables {
    return _debts
        .where((DebtRecord item) => !item.isReceivable)
        .fold<double>(
          0.0,
          (double sum, DebtRecord item) => sum + item.amount,
        );
  }

  SalaryAllocation allocateSalary({
    required double salaryAmount,
    required String title,
    required String dateLabel,
    required String notes,
  }) {
    final double cleanAmount =
        salaryAmount.isFinite && salaryAmount > 0.0 ? salaryAmount : 0.0;

    final double jamiyaAmount =
        cleanAmount >= 20000.0 ? 20000.0 : cleanAmount;

    final double afterJamiya = cleanAmount - jamiyaAmount;

    final double dailyAmount =
        afterJamiya >= 50000.0 ? 50000.0 : afterJamiya;

    final double strategicAmount = afterJamiya - dailyAmount;

    _walletById('jamiya').balance += jamiyaAmount;
    _walletById('daily').balance += dailyAmount;
    _walletById('strategic').balance += strategicAmount;

    _transactions.insert(
      0,
      TransactionRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim().isEmpty ? 'راتب وارد' : title.trim(),
        category: 'دخل',
        dateLabel:
            dateLabel.trim().isEmpty ? 'تاريخ مُدخل يدوياً' : dateLabel.trim(),
        notes: notes.trim().isEmpty
            ? 'تم التوزيع التلقائي بين المحافظ.'
            : notes.trim(),
        label: 'Received salary',
        amount: cleanAmount,
        type: TransactionType.income,
        createdAt: DateTime.now(),
      ),
    );

    return SalaryAllocation(
      originalAmount: cleanAmount,
      jamiyaAmount: jamiyaAmount,
      dailyAmount: dailyAmount,
      strategicAmount: strategicAmount,
    );
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere(
      (TransactionRecord item) => item.id == id,
    );
  }

  void updateTransaction(TransactionRecord updatedRecord) {
    final int index = _transactions.indexWhere(
      (TransactionRecord item) => item.id == updatedRecord.id,
    );

    if (index >= 0) {
      _transactions[index] = updatedRecord;
    }
  }

  WalletFolder _walletById(String id) {
    return _wallets.firstWhere(
      (WalletFolder wallet) => wallet.id == id,
    );
  }

  String buildTransactionReport(Iterable<TransactionRecord> records) {
    final List<TransactionRecord> data = records.toList();
    final StringBuffer report = StringBuffer();

    report.writeln('تقرير محاسبي المالي');
    report.writeln('صُنع بواسطة نظام أبو علي لقمان — ABOALILUQMAN');
    report.writeln('عدد السجلات: ${data.length}');
    report.writeln('----------------------------------------');

    for (final TransactionRecord item in data) {
      final String direction =
          item.type == TransactionType.income ? 'دخل' : 'مصروف';

      report.writeln('العنوان: ${item.title}');
      report.writeln('النوع: $direction');
      report.writeln('التصنيف: ${item.category}');
      report.writeln('المبلغ: ${formatYemeniAmount(item.amount)} ريال يمني');
      report.writeln('التاريخ: ${item.dateLabel}');
      report.writeln('الوسم: ${item.label}');
      report.writeln('ملاحظات: ${item.notes}');
      report.writeln('----------------------------------------');
    }

    return report.toString();
  }
}

class WalletFolder {
  WalletFolder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.balance,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  double balance;
  final IconData icon;
  final Color color;
}

enum TransactionType {
  income,
  expense,
}

class TransactionRecord {
  TransactionRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.notes,
    required this.label,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String category;
  final String dateLabel;
  final String notes;
  final String label;
  final double amount;
  final TransactionType type;
  final DateTime createdAt;

  TransactionRecord copyWith({
    String? title,
    String? category,
    String? dateLabel,
    String? notes,
    String? label,
    double? amount,
    TransactionType? type,
  }) {
    return TransactionRecord(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateLabel: dateLabel ?? this.dateLabel,
      notes: notes ?? this.notes,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt,
    );
  }
}

class DebtRecord {
  DebtRecord({
    required this.id,
    this.name,
    this.phone,
    this.category,
    required this.amount,
    this.note,
    this.dueDateLabel,
    required this.isReceivable,
  });

  final String id;
  final String? name;
  final String? phone;
  final String? category;
  final double amount;
  final String? note;
  final String? dueDateLabel;
  final bool isReceivable;
}

class SalaryAllocation {
  const SalaryAllocation({
    required this.originalAmount,
    required this.jamiyaAmount,
    required this.dailyAmount,
    required this.strategicAmount,
  });

  final double originalAmount;
  final double jamiyaAmount;
  final double dailyAmount;
  final double strategicAmount;
}

class UserProfile {
  UserProfile({
    required this.fullName,
    required this.avatarLetters,
    required this.phone,
  });

  String fullName;
  String avatarLetters;
  String phone;
}

class WalletDashboardTab extends StatelessWidget {
  const WalletDashboardTab({
    super.key,
    required this.controller,
    required this.useArabicNumerals,
    required this.onChanged,
  });

  final FinancialController controller;
  final bool useArabicNumerals;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        children: <Widget>[
          const PageHeading(
            title: 'الموازنة والمحفظة',
            subtitle: 'ملخص مالي ذكي وتنظيم تلقائي للأموال',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 22),
          _NetBalanceCard(
            amount: controller.netBalance,
            useArabicNumerals: useArabicNumerals,
          ),
          const SizedBox(height: 20),
          _SalaryAllocationCard(
            controller: controller,
            useArabicNumerals: useArabicNumerals,
            onChanged: onChanged,
          ),
          const SizedBox(height: 24),
          Text(
            'المحافظ الفرعية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          ...controller.wallets.map(
            (WalletFolder wallet) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WalletFolderCard(
                wallet: wallet,
                useArabicNumerals: useArabicNumerals,
              ),
            ),
          ),
          const BrandFooter(),
        ],
      ),
    );
  }
}

class _NetBalanceCard extends StatelessWidget {
  const _NetBalanceCard({
    required this.amount,
    required this.useArabicNumerals,
  });

  final double amount;
  final bool useArabicNumerals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            AppColors.emerald,
            AppColors.emeraldDark,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.emerald.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.auto_graph_rounded,
                color: Color(0xFFFFE9A5),
              ),
              SizedBox(width: 8),
              Text(
                'صافي الرصيد التراكمي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${formatYemeniAmount(amount, useArabicNumerals: useArabicNumerals)} ي.ر',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'إجمالي المحافظ بعد التوزيع الذكي',
            style: TextStyle(
              color: Color(0xFFD2F4E9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryAllocationCard extends StatefulWidget {
  const _SalaryAllocationCard({
    required this.controller,
    required this.useArabicNumerals,
    required this.onChanged,
  });

  final FinancialController controller;
  final bool useArabicNumerals;
  final VoidCallback onChanged;

  @override
  State<_SalaryAllocationCard> createState() => _SalaryAllocationCardState();
}

class _SalaryAllocationCardState extends State<_SalaryAllocationCard> {
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _titleController =
      TextEditingController(text: 'راتب وارد');
  final TextEditingController _dateController =
      TextEditingController(text: 'تاريخ مُدخل يدوياً');
  final TextEditingController _notesController =
      TextEditingController(text: 'توزيع تلقائي إلى المحافظ');

  @override
  void dispose() {
    _salaryController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _allocate() {
    final double? amount = parseFlexibleDouble(_salaryController.text);

    if (amount == null || !amount.isFinite || amount <= 0.0) {
      showAppSnackBar(
        context,
        'أدخل مبلغ راتب صحيحًا أكبر من صفر.',
        isError: true,
      );
      return;
    }

    final SalaryAllocation allocation = widget.controller.allocateSalary(
      salaryAmount: amount,
      title: _titleController.text,
      dateLabel: _dateController.text,
      notes: _notesController.text,
    );

    widget.onChanged();
    _salaryController.clear();

    showAppSnackBar(
      context,
      'تم التوزيع: جمعية ${formatYemeniAmount(allocation.jamiyaAmount, useArabicNumerals: widget.useArabicNumerals)}، يومي ${formatYemeniAmount(allocation.dailyAmount, useArabicNumerals: widget.useArabicNumerals)}، استراتيجي ${formatYemeniAmount(allocation.strategicAmount, useArabicNumerals: widget.useArabicNumerals)} ريال.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF192523) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: AppColors.emerald.withOpacity(0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Color(0xFFE0F2EE),
                  foregroundColor: AppColors.emerald,
                  child: Icon(Icons.account_tree_rounded),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'توزيع الراتب التلقائي',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'يُحوّل أول 20,000 ريال إلى الجمعية، ثم 50,000 ريال إلى المصروفات اليومية، وما تبقى إلى الادخار الاستراتيجي.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _salaryController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'مبلغ الراتب الوارد',
                suffixText: 'ريال يمني',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان العملية',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'التاريخ الوصفي (ميلادي أو هجري)',
                hintText: 'مثال: 24 يونيو 2026 م | 8 محرم 1448 هـ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _allocate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('تنفيذ التوزيع الذكي'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletFolderCard extends StatelessWidget {
  const WalletFolderCard({
    super.key,
    required this.wallet,
    required this.useArabicNumerals,
  });

  final WalletFolder wallet;
  final bool useArabicNumerals;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF192523) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: wallet.color.withOpacity(0.14),
          foregroundColor: wallet.color,
          child: Icon(wallet.icon),
        ),
        title: Text(
          wallet.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(wallet.subtitle),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              formatYemeniAmount(
                wallet.balance,
                useArabicNumerals: useArabicNumerals,
              ),
              style: TextStyle(
                color: wallet.color,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const Text(
              'ريال يمني',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({
    super.key,
    required this.controller,
    required this.useArabicNumerals,
    required this.onChanged,
  });

  final FinancialController controller;
  final bool useArabicNumerals;
  final VoidCallback onChanged;

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};

  List<TransactionRecord> get _selectedTransactions {
    return widget.controller.transactions
        .where(
          (TransactionRecord item) => _selectedIds.contains(item.id),
        )
        .toList();
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;

      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleAll() {
    final List<TransactionRecord> all = widget.controller.transactions;

    setState(() {
      if (_selectedIds.length == all.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(
            all.map((TransactionRecord item) => item.id),
          );
      }
    });
  }

  void _exportTextReport() {
    final List<TransactionRecord> records =
        _selectionMode && _selectedIds.isNotEmpty
            ? _selectedTransactions
            : widget.controller.transactions;

    final String report = widget.controller.buildTransactionReport(records);

    debugPrint(report);

    showAppSnackBar(
      context,
      'تم تجهيز تقرير TXT شامل لـ ${records.length} عملية. تم إنشاء النص بنجاح داخل سجل التطبيق.',
    );
  }

  Future<void> _showTransactionActions(TransactionRecord record) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.visibility_rounded),
                  title: const Text('عرض التفاصيل'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDetails(record);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('تعديل'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditDialog(record);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('مشاركة'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showShareText(record);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.print_rounded),
                  title: const Text('طباعة'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showAppSnackBar(
                      context,
                      'تم تجهيز العملية للطباعة. الطباعة الأصلية تحتاج حزمة مخصصة.',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'حذف',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(record);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetails(TransactionRecord record) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(record.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DetailLine(
                  label: 'التصنيف',
                  value: record.category,
                ),
                _DetailLine(
                  label: 'المبلغ',
                  value:
                      '${formatYemeniAmount(record.amount, useArabicNumerals: widget.useArabicNumerals)} ريال يمني',
                ),
                _DetailLine(
                  label: 'التاريخ',
                  value: record.dateLabel,
                ),
                _DetailLine(
                  label: 'الوسم',
                  value: record.label,
                ),
                _DetailLine(
                  label: 'الملاحظات',
                  value: record.notes,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showShareText(TransactionRecord record) {
    final String message = '''
عملية مالية من تطبيق محاسبي:
العنوان: ${record.title}
التصنيف: ${record.category}
المبلغ: ${formatYemeniAmount(record.amount, useArabicNumerals: widget.useArabicNumerals)} ريال يمني
التاريخ: ${record.dateLabel}
الوسم: ${record.label}
الملاحظات: ${record.notes}
''';

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('نص المشاركة'),
          content: SelectableText(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(TransactionRecord record) {
    final TextEditingController titleController =
        TextEditingController(text: record.title);
    final TextEditingController categoryController =
        TextEditingController(text: record.category);
    final TextEditingController amountController =
        TextEditingController(text: record.amount.toString());
    final TextEditingController dateController =
        TextEditingController(text: record.dateLabel);
    final TextEditingController notesController =
        TextEditingController(text: record.notes);
    final TextEditingController labelController =
        TextEditingController(text: record.label);

    TransactionType selectedType = record.type;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('تعديل العملية'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                      ),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'التصنيف',
                      ),
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'المبلغ',
                      ),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'التاريخ الوصفي',
                      ),
                    ),
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'الوسم',
                      ),
                    ),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'الملاحظات',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<TransactionType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع العملية',
                      ),
                      items: const <DropdownMenuItem<TransactionType>>[
                        DropdownMenuItem<TransactionType>(
                          value: TransactionType.income,
                          child: Text('دخل'),
                        ),
                        DropdownMenuItem<TransactionType>(
                          value: TransactionType.expense,
                          child: Text('مصروف'),
                        ),
                      ],
                      onChanged: (TransactionType? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final double? amount =
                        parseFlexibleDouble(amountController.text);

                    if (amount == null || !amount.isFinite || amount < 0.0) {
                      showAppSnackBar(
                        context,
                        'أدخل مبلغًا صالحًا.',
                        isError: true,
                      );
                      return;
                    }

                    widget.controller.updateTransaction(
                      record.copyWith(
                        title: titleController.text.trim(),
                        category: categoryController.text.trim(),
                        amount: amount,
                        dateLabel: dateController.text.trim(),
                        notes: notesController.text.trim(),
                        label: labelController.text.trim(),
                        type: selectedType,
                      ),
                    );

                    widget.onChanged();
                    Navigator.pop(dialogContext);

                    showAppSnackBar(
                      context,
                      'تم تعديل العملية بنجاح.',
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      categoryController.dispose();
      amountController.dispose();
      dateController.dispose();
      notesController.dispose();
      labelController.dispose();
    });
  }

  void _confirmDelete(TransactionRecord record) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('حذف العملية'),
          content: Text('هل تريد حذف "${record.title}" نهائيًا؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () {
                widget.controller.deleteTransaction(record.id);
                _selectedIds.remove(record.id);
                widget.onChanged();
                Navigator.pop(dialogContext);

                showAppSnackBar(
                  context,
                  'تم حذف العملية.',
                );
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TransactionRecord> transactions = widget.controller.transactions;

    final bool allSelected =
        transactions.isNotEmpty && _selectedIds.length == transactions.length;

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PageHeading(
                    title: _selectionMode
                        ? 'تم تحديد ${_selectedIds.length} عملية'
                        : 'سجل العمليات',
                    subtitle: _selectionMode
                        ? 'اختر العمليات ثم صدّر التقرير النصي'
                        : 'عمليات مفصلة مع تاريخ وملاحظات ووسوم',
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: _selectionMode
                      ? 'إلغاء وضع التحديد'
                      : 'تفعيل وضع التحديد',
                  onPressed: _toggleSelectionMode,
                  icon: Icon(
                    _selectionMode
                        ? Icons.close_rounded
                        : Icons.checklist_rounded,
                  ),
                ),
              ],
            ),
          ),
          if (_selectionMode)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: transactions.isEmpty ? null : _toggleAll,
                      icon: Icon(
                        allSelected
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                      ),
                      label: Text(
                        allSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          transactions.isEmpty ? null : _exportTextReport,
                      icon: const Icon(Icons.file_download_rounded),
                      label: const Text('تصدير TXT'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد عمليات حالياً',
                      subtitle: 'ستظهر هنا العمليات التي تضيفها أو توزّعها.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                    itemCount: transactions.length + 1,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (index == transactions.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: BrandFooter(),
                        );
                      }

                      final TransactionRecord item = transactions[index];

                      return TransactionTile(
                        record: item,
                        useArabicNumerals: widget.useArabicNumerals,
                        selectionMode: _selectionMode,
                        isSelected: _selectedIds.contains(item.id),
                        onSelected: (bool? selected) {
                          setState(() {
                            if (selected ?? false) {
                              _selectedIds.add(item.id);
                            } else {
                              _selectedIds.remove(item.id);
                            }
                          });
                        },
                        onLongPress: () => _showTransactionActions(item),
                        onTap: () {
                          if (_selectionMode) {
                            setState(() {
                              if (_selectedIds.contains(item.id)) {
                                _selectedIds.remove(item.id);
                              } else {
                                _selectedIds.add(item.id);
                              }
                            });
                          } else {
                            _showDetails(item);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.record,
    required this.useArabicNumerals,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelected,
    required this.onLongPress,
    required this.onTap,
  });

  final TransactionRecord record;
  final bool useArabicNumerals;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool income = record.type == TransactionType.income;
    final Color color = income ? AppColors.income : AppColors.expense;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF192523) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? AppColors.emerald : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: onSelected,
                ),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                foregroundColor: color,
                child: Icon(
                  income
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.category} • ${record.dateLabel}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      record.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      padding: EdgeInsets.zero,
                      label: Text(
                        record.label,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${income ? '+' : '-'}${formatYemeniAmount(record.amount, useArabicNumerals: useArabicNumerals)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ريال يمني',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DebtLedgerTab extends StatelessWidget {
  const DebtLedgerTab({
    super.key,
    required this.controller,
    required this.useArabicNumerals,
  });

  final FinancialController controller;
  final bool useArabicNumerals;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        children: <Widget>[
          const PageHeading(
            title: 'دفتر الديون',
            subtitle: 'متابعة الذمم، العملاء، الموردين والتذكيرات الذكية',
            icon: Icons.handshake_rounded,
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: DebtSummaryCard(
                  title: 'لك عند الآخرين',
                  amount: controller.totalReceivables,
                  color: AppColors.income,
                  icon: Icons.call_received_rounded,
                  useArabicNumerals: useArabicNumerals,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DebtSummaryCard(
                  title: 'عليك للموردين',
                  amount: controller.totalPayables,
                  color: AppColors.expense,
                  icon: Icons.call_made_rounded,
                  useArabicNumerals: useArabicNumerals,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'الديون النشطة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          if (controller.debts.isEmpty)
            const EmptyState(
              icon: Icons.handshake_outlined,
              title: 'لا توجد ديون نشطة',
              subtitle: 'أضف الديون لاحقاً من نظامك المالي.',
            )
          else
            ...controller.debts.map(
              (DebtRecord debt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DebtCard(
                  debt: debt,
                  useArabicNumerals: useArabicNumerals,
                ),
              ),
            ),
          const BrandFooter(),
        ],
      ),
    );
  }
}

class DebtSummaryCard extends StatelessWidget {
  const DebtSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.useArabicNumerals,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool useArabicNumerals;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192523) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatYemeniAmount(
              amount,
              useArabicNumerals: useArabicNumerals,
            ),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const Text(
            'ريال يمني',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class DebtCard extends StatelessWidget {
  const DebtCard({
    super.key,
    required this.debt,
    required this.useArabicNumerals,
  });

  final DebtRecord debt;
  final bool useArabicNumerals;

  Future<void> _sendDemand(BuildContext context) async {
    final String? normalizedPhone = normalizeYemeniPhone(debt.phone ?? '');

    if (normalizedPhone == null) {
      showAppSnackBar(
        context,
        'رقم هاتف الدين غير صالح. أدخل رقمًا يمنيًا صحيحًا يبدأ بـ 967.',
        isError: true,
      );
      return;
    }

    final String customerName = (debt.name ?? '').trim().isEmpty
        ? 'العميل'
        : debt.name!.trim();

    final String debtNote = debt.note ?? '';

    final String message = '''
مرحباً $customerName،
يرجى مراجعة الحساب المتبقي لديكم وهو ${formatYemeniAmount(
  debt.amount,
  useArabicNumerals: useArabicNumerals,
)} ريال يمني.
$debtNote
صُنع بواسطة نظام أبو علي لقمان — ABOALILUQMAN
''';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$normalizedPhone?text=${Uri.encodeComponent(message)}',
    );

    final bool opened = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) {
      return;
    }

    if (!opened) {
      showAppSnackBar(
        context,
        'تعذر فتح WhatsApp. تأكد من تثبيت التطبيق وصحة الرقم.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color typeColor =
        debt.isReceivable ? AppColors.income : AppColors.expense;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String displayName = (debt.name ?? '').trim().isEmpty
        ? 'بدون اسم'
        : debt.name!.trim();

    final String displayCategory = (debt.category ?? '').trim().isEmpty
        ? 'دين'
        : debt.category!.trim();

    final String displayDueDate = (debt.dueDateLabel ?? '').trim().isEmpty
        ? 'لا يوجد تاريخ استحقاق'
        : debt.dueDateLabel!.trim();

    final String displayNote = debt.note ?? '';

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF192523) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: typeColor.withOpacity(0.12),
                  foregroundColor: typeColor,
                  child: Icon(
                    debt.isReceivable
                        ? Icons.person_outline_rounded
                        : Icons.storefront_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$displayCategory • $displayDueDate',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatYemeniAmount(
                    debt.amount,
                    useArabicNumerals: useArabicNumerals,
                  ),
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (displayNote.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  displayNote,
                  style: const TextStyle(
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _sendDemand(context),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('مطالبة ذكية عبر واتساب'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.themeMode,
    required this.fontHierarchy,
    required this.useArabicNumerals,
    required this.onThemeModeChanged,
    required this.onFontHierarchyChanged,
    required this.onArabicNumeralsChanged,
    required this.onProfileChanged,
  });

  final UserProfile profile;
  final ThemeMode themeMode;
  final FontHierarchy fontHierarchy;
  final bool useArabicNumerals;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<FontHierarchy> onFontHierarchyChanged;
  final ValueChanged<bool> onArabicNumeralsChanged;
  final VoidCallback onProfileChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  void _editProfile() {
    final TextEditingController nameController =
        TextEditingController(text: widget.profile.fullName);

    final TextEditingController initialsController =
        TextEditingController(text: widget.profile.avatarLetters);

    final TextEditingController phoneController =
        TextEditingController(text: widget.profile.phone);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                  ),
                ),
                TextField(
                  controller: initialsController,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'حروف الصورة الشخصية',
                  ),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف بصيغة +967 أو 967',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String letters = initialsController.text.trim();
                final String phone = phoneController.text.trim();

                if (name.isEmpty || letters.isEmpty || phone.isEmpty) {
                  showAppSnackBar(
                    context,
                    'أكمل الاسم والحروف ورقم الهاتف.',
                    isError: true,
                  );
                  return;
                }

                setState(() {
                  widget.profile.fullName = name;
                  widget.profile.avatarLetters = letters.toUpperCase();
                  widget.profile.phone = phone;
                });

                widget.onProfileChanged();
                Navigator.pop(dialogContext);

                showAppSnackBar(
                  context,
                  'تم تحديث الملف الشخصي.',
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      initialsController.dispose();
      phoneController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        children: <Widget>[
          const PageHeading(
            title: 'الملف والإعدادات',
            subtitle: 'هوية المستخدم والتحكم بالشكل واللغة الرقمية',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF192523) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                child: Text(
                  widget.profile.avatarLetters,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              title: Text(
                widget.profile.fullName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(widget.profile.phone),
              trailing: IconButton(
                tooltip: 'تعديل الملف',
                icon: const Icon(Icons.edit_rounded),
                onPressed: _editProfile,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'التحكم بالمظهر',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF192523) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('الوضع الداكن'),
                  subtitle: const Text('تفعيل واجهة داكنة مريحة للعين'),
                  value: widget.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    widget.onThemeModeChanged(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded),
                  title: const Text('هرمية الخط'),
                  subtitle: Text(
                    fontHierarchyLabel(widget.fontHierarchy),
                  ),
                  trailing: DropdownButton<FontHierarchy>(
                    value: widget.fontHierarchy,
                    underline: const SizedBox.shrink(),
                    items: const <DropdownMenuItem<FontHierarchy>>[
                      DropdownMenuItem<FontHierarchy>(
                        value: FontHierarchy.system,
                        child: Text('النظام'),
                      ),
                      DropdownMenuItem<FontHierarchy>(
                        value: FontHierarchy.serif,
                        child: Text('Serif'),
                      ),
                      DropdownMenuItem<FontHierarchy>(
                        value: FontHierarchy.monospace,
                        child: Text('Monospace'),
                      ),
                    ],
                    onChanged: (FontHierarchy? value) {
                      if (value != null) {
                        widget.onFontHierarchyChanged(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.numbers_rounded),
                  title: const Text('الأرقام العربية'),
                  subtitle: const Text(
                    'عرض المبالغ بالأرقام ١٢٣ بدلاً من 123',
                  ),
                  value: widget.useArabicNumerals,
                  onChanged: widget.onArabicNumeralsChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.32),
              ),
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFF9A7000),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'هوية محاسبي محفوظة ضمن واجهة التطبيق ولا يمكن إزالة تذييل الملكية الفكرية.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const BrandFooter(),
        ],
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.emerald.withOpacity(0.12),
          foregroundColor: AppColors.emerald,
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Text(
        '© 2026 جميع الحقوق محفوظة | صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 48,
            color: AppColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

String formatYemeniAmount(
  double amount, {
  bool useArabicNumerals = false,
}) {
  final bool isNegative = amount.isNegative;
  final String raw = amount.abs().toStringAsFixed(0);
  final StringBuffer formatted = StringBuffer();

  for (int index = 0; index < raw.length; index++) {
    final int remaining = raw.length - index;
    formatted.write(raw[index]);

    if (remaining > 1 && remaining % 3 == 1) {
      formatted.write(',');
    }
  }

  final String result = isNegative ? '-$formatted' : formatted.toString();

  return useArabicNumerals ? toArabicNumerals(result) : result;
}

String toArabicNumerals(String value) {
  const Map<String, String> digits = <String, String>{
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  return value
      .split('')
      .map((String char) => digits[char] ?? char)
      .join();
}

double? parseFlexibleDouble(String value) {
  final String normalized = value
      .trim()
      .replaceAll(',', '')
      .replaceAll('٬', '')
      .replaceAll('٫', '.');

  if (normalized.isEmpty) {
    return null;
  }

  return double.tryParse(normalized);
}

String? normalizeYemeniPhone(String? value) {
  String cleaned = (value ?? '').replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );

  if (cleaned.startsWith('00')) {
    cleaned = cleaned.substring(2);
  }

  if (cleaned.startsWith('0')) {
    cleaned = '967${cleaned.substring(1)}';
  }

  if (!cleaned.startsWith('967') || cleaned.length != 12) {
    return null;
  }

  return cleaned;
}

String fontHierarchyLabel(FontHierarchy hierarchy) {
  switch (hierarchy) {
    case FontHierarchy.system:
      return 'خط النظام الافتراضي';
    case FontHierarchy.serif:
      return 'خط Serif مريح للقراءة';
    case FontHierarchy.monospace:
      return 'خط Monospace متساوي العرض';
  }
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.danger : AppColors.emerald,
        content: Text(message),
      ),
    );
}
