import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  bool _arabicDigits = false;
  String _fontMode = 'system';

  @override
  Widget build(BuildContext context) {
    final String? fontFamily = switch (_fontMode) {
      'serif' => 'serif',
      'mono' => 'monospace',
      _ => null,
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محاسبي الشامل',
      themeMode: _themeMode,
      theme: _theme(
        brightness: Brightness.light,
        fontFamily: fontFamily,
      ),
      darkTheme: _theme(
        brightness: Brightness.dark,
        fontFamily: fontFamily,
      ),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MuhasibiDashboard(
        themeMode: _themeMode,
        arabicDigits: _arabicDigits,
        fontMode: _fontMode,
        onThemeChanged: (ThemeMode value) {
          setState(() => _themeMode = value);
        },
        onArabicDigitsChanged: (bool value) {
          setState(() => _arabicDigits = value);
        },
        onFontChanged: (String value) {
          setState(() => _fontMode = value);
        },
      ),
    );
  }

  ThemeData _theme({
    required Brightness brightness,
    required String? fontFamily,
  }) {
    final bool dark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          dark ? const Color(0xFF101716) : const Color(0xFFF5F8F7),
      textTheme: (dark
              ? Typography.material2021().white
              : Typography.material2021().black)
          .apply(fontFamily: fontFamily),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF192523) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: dark ? Colors.white24 : Colors.black12,
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
}

class AppColors {
  static const Color emerald = Color(0xFF00695C);
  static const Color emeraldDark = Color(0xFF004D40);
  static const Color emeraldLight = Color(0xFF1AA78E);
  static const Color danger = Color(0xFFB91C1C);
  static const Color success = Color(0xFF15803D);
  static const Color muted = Color(0xFF68736F);
  static const Color gold = Color(0xFFE2B53C);
}

enum TransactionType {
  income,
  expense,
  transferOut,
  transferIn,
}

enum LedgerType {
  client,
  vendor,
  worker,
}

class FinancialSection {
  FinancialSection({
    required this.id,
    required this.name,
    required this.description,
    required this.currency,
    required this.color,
    required this.icon,
    this.openingBalance = 0.0,
  });

  final String id;
  String name;
  String description;
  String currency;
  Color color;
  IconData icon;
  double openingBalance;
}

class FinancialTransaction {
  FinancialTransaction({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.type,
    required this.amount,
    required this.currency,
    required this.dateLabel,
    required this.category,
    required this.counterparty,
    required this.place,
    required this.reason,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.notes,
    required this.labels,
  });

  final String id;
  final String sectionId;
  final String title;
  final TransactionType type;
  final double amount;
  final String currency;
  final String dateLabel;
  final String category;
  final String counterparty;
  final String place;
  final String reason;
  final String paymentMethod;
  final String referenceNumber;
  final String notes;
  final List<String> labels;
}

class LedgerEntry {
  LedgerEntry({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.credit,
    required this.debit,
    required this.currency,
    required this.notes,
  });

  final String id;
  String name;

  // Nullable safely. WhatsApp processing uses phone ?? ''.
  String? phone;

  LedgerType type;
  double credit;
  double debit;
  String currency;
  String notes;

  double get balance => credit - debit;
}

class ChildGoal {
  ChildGoal({
    required this.id,
    required this.childName,
    required this.goalName,
    required this.target,
    this.saved = 0.0,
    this.rewardPoints = 0.0,
  });

  final String id;
  final String childName;
  final String goalName;
  final double target;
  double saved;
  double rewardPoints;

  double get progress {
    if (target <= 0.0) {
      return 0.0;
    }

    return (saved / target).clamp(0.0, 1.0);
  }
}

class InventoryItem {
  InventoryItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.quantity = 0.0,
    this.minimumQuantity = 0.0,
  });

  final String id;
  final String name;
  final double unitPrice;
  double quantity;
  double minimumQuantity;
}

class MuhasibiDashboard extends StatefulWidget {
  const MuhasibiDashboard({
    super.key,
    required this.themeMode,
    required this.arabicDigits,
    required this.fontMode,
    required this.onThemeChanged,
    required this.onArabicDigitsChanged,
    required this.onFontChanged,
  });

  final ThemeMode themeMode;
  final bool arabicDigits;
  final String fontMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onArabicDigitsChanged;
  final ValueChanged<String> onFontChanged;

  @override
  State<MuhasibiDashboard> createState() =>
      _MuhasibiDashboardState();
}

class _MuhasibiDashboardState extends State<MuhasibiDashboard> {
  int _tabIndex = 0;
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};

  String _profileName = 'أبو علي لقمان';
  String _profilePhone = '967775592894';
  String _profileAvatar = 'AL';

  double _yerPerSar = 140.0;
  double _yerPerUsd = 535.0;
  double _expenseThreshold = 100000.0;

  final List<FinancialSection> _sections = <FinancialSection>[];
  final List<FinancialTransaction> _transactions =
      <FinancialTransaction>[];

  final List<LedgerEntry> _clients = <LedgerEntry>[];
  final List<LedgerEntry> _vendors = <LedgerEntry>[];
  final List<LedgerEntry> _workers = <LedgerEntry>[];

  final List<ChildGoal> _childGoals = <ChildGoal>[];
  final List<InventoryItem> _inventory = <InventoryItem>[];

  double get _totalIncome {
    return _transactions
        .where(
          (FinancialTransaction item) =>
              item.type == TransactionType.income ||
              item.type == TransactionType.transferIn,
        )
        .fold<double>(
          0.0,
          (double sum, FinancialTransaction item) => sum + item.amount,
        );
  }

  double get _totalExpenses {
    return _transactions
        .where(
          (FinancialTransaction item) =>
              item.type == TransactionType.expense ||
              item.type == TransactionType.transferOut,
        )
        .fold<double>(
          0.0,
          (double sum, FinancialTransaction item) => sum + item.amount,
        );
  }

  bool get _hasLeak => _totalExpenses > _expenseThreshold;

  double sectionBalance(FinancialSection section) {
    final double entered = _transactions
        .where(
          (FinancialTransaction item) =>
              item.sectionId == section.id &&
              (item.type == TransactionType.income ||
                  item.type == TransactionType.transferIn),
        )
        .fold<double>(
          0.0,
          (double sum, FinancialTransaction item) => sum + item.amount,
        );

    final double exited = _transactions
        .where(
          (FinancialTransaction item) =>
              item.sectionId == section.id &&
              (item.type == TransactionType.expense ||
                  item.type == TransactionType.transferOut),
        )
        .fold<double>(
          0.0,
          (double sum, FinancialTransaction item) => sum + item.amount,
        );

    return section.openingBalance + entered - exited;
  }

  String money(double amount) {
    return formatMoney(
      amount,
      arabicDigits: widget.arabicDigits,
    );
  }

  List<LedgerEntry> ledgerList(LedgerType type) {
    switch (type) {
      case LedgerType.client:
        return _clients;
      case LedgerType.vendor:
        return _vendors;
      case LedgerType.worker:
        return _workers;
    }
  }

  void snack(String message, {bool error = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.danger : AppColors.emerald,
          content: Text(message),
        ),
      );
  }

  void addSection({
    required String name,
    required String description,
    required String currency,
  }) {
    if (name.trim().isEmpty) {
      snack('اكتب اسم القسم أولاً.', error: true);
      return;
    }

    setState(() {
      _sections.add(
        FinancialSection(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name.trim(),
          description: description.trim(),
          currency: currency.trim().isEmpty ? 'YER' : currency.trim(),
          color: AppColors.emerald,
          icon: Icons.account_balance_wallet_rounded,
          openingBalance: 0.0,
        ),
      );
    });

    snack('تم إنشاء القسم "${name.trim()}" برصيد صفر.');
  }

  void addTransaction(FinancialTransaction transaction) {
    if (!transaction.amount.isFinite || transaction.amount < 0.0) {
      snack('المبلغ غير صالح.', error: true);
      return;
    }

    setState(() {
      _transactions.insert(0, transaction);
    });

    if (transaction.type == TransactionType.expense && _hasLeak) {
      snack(
        'تنبيه تسرب مالي: تجاوزت المصروفات حد الأمان.',
        error: true,
      );
    } else {
      snack('تمت إضافة العملية بنجاح.');
    }
  }

  void transfer({
    required FinancialSection from,
    required FinancialSection to,
    required double amount,
    required String description,
  }) {
    if (amount <= 0.0 || !amount.isFinite) {
      snack('أدخل مبلغ تحويل صالح.', error: true);
      return;
    }

    if (sectionBalance(from) < amount) {
      snack('رصيد القسم المصدر غير كافٍ للتحويل.', error: true);
      return;
    }

    final String transferId =
        DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      _transactions.insertAll(
        0,
        <FinancialTransaction>[
          FinancialTransaction(
            id: '${transferId}_out',
            sectionId: from.id,
            title: 'تحويل إلى ${to.name}',
            type: TransactionType.transferOut,
            amount: amount,
            currency: from.currency,
            dateLabel: DateTime.now().toString(),
            category: 'تحويل داخلي',
            counterparty: to.name,
            place: '',
            reason: description,
            paymentMethod: 'تحويل داخلي',
            referenceNumber: transferId,
            notes: description,
            labels: <String>['تحويل'],
          ),
          FinancialTransaction(
            id: '${transferId}_in',
            sectionId: to.id,
            title: 'تحويل من ${from.name}',
            type: TransactionType.transferIn,
            amount: amount,
            currency: to.currency,
            dateLabel: DateTime.now().toString(),
            category: 'تحويل داخلي',
            counterparty: from.name,
            place: '',
            reason: description,
            paymentMethod: 'تحويل داخلي',
            referenceNumber: transferId,
            notes: description,
            labels: <String>['تحويل'],
          ),
        ],
      );
    });

    snack('تم تحويل ${money(amount)} من ${from.name} إلى ${to.name}.');
  }

  Future<void> sendReminder(LedgerEntry entry) async {
    // Important Codemagic null-safety correction:
    final String normalizedPhone =
        normalizeYemeniPhone(entry.phone ?? '');

    if (normalizedPhone.isEmpty) {
      snack(
        'رقم واتساب غير صالح. اكتب رقمًا يمنيًا يبدأ بـ 967.',
        error: true,
      );
      return;
    }

    final String message = '''
مرحباً ${entry.name}،
تفاصيل الحساب المالي المتبقي لديكم حالياً: ${money(entry.balance.abs())} ${entry.currency}.
صُنع وتم الابتكار بواسطة المطور مالك النظام أبو علي لقمان للتواصل هاتف: 0967775592894
''';

    final Uri url = Uri.https(
      'wa.me',
      '/$normalizedPhone',
      <String, String>{'text': message},
    );

    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) {
      return;
    }

    if (!opened) {
      snack('تعذر فتح WhatsApp.', error: true);
    }
  }

  void exportSelected() {
    final List<FinancialTransaction> records =
        _selectionMode && _selectedIds.isNotEmpty
            ? _transactions
                .where(
                  (FinancialTransaction item) =>
                      _selectedIds.contains(item.id),
                )
                .toList()
            : _transactions;

    final String report = '''
تقرير محاسبي الشامل
المالك: $_profileName
عدد العمليات: ${records.length}
================================================
${records.map((FinancialTransaction item) {
      return '''
العنوان: ${item.title}
النوع: ${transactionTypeName(item.type)}
القسم: ${sectionName(item.sectionId)}
المبلغ: ${money(item.amount)} ${item.currency}
التصنيف: ${item.category}
الطرف المقابل: ${item.counterparty}
المكان: ${item.place}
السبب: ${item.reason}
الطريقة: ${item.paymentMethod}
التاريخ: ${item.dateLabel}
المرجع: ${item.referenceNumber}
الملاحظات: ${item.notes}
------------------------------------------------''';
    }).join('\n')}
© 2026 جميع الحقوق محفوظة لـ محاسبي الشامل
''';

    debugPrint(report);

    snack(
      'تم إنشاء تقرير نصي منظم لـ ${records.length} عملية داخل التطبيق.',
    );
  }

  String sectionName(String id) {
    for (final FinancialSection section in _sections) {
      if (section.id == id) {
        return section.name;
      }
    }

    return 'قسم محذوف';
  }

  String transactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'دخل';
      case TransactionType.expense:
        return 'خرج';
      case TransactionType.transferOut:
        return 'تحويل صادر';
      case TransactionType.transferIn:
        return 'تحويل وارد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      peopleAndMerchantsPage(),
      kidsSavingsPage(),
      expensesAndInventoryPage(),
      controlCenterPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() => _tabIndex = index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'الأفراد والتجار',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'حصالة الأطفال',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'المصاريف والجرد',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings_rounded),
            label: 'التحكم والأمان',
          ),
        ],
      ),
    );
  }

  Widget peopleAndMerchantsPage() {
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: AppHeader(
                title: 'دفتر الأفراد والتجار',
                subtitle: 'أقسامك وعملياتك وحساباتك المرنة',
                icon: Icons.people_rounded,
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabs: <Widget>[
                Tab(text: 'الأقسام'),
                Tab(text: 'العملاء'),
                Tab(text: 'الموردون'),
                Tab(text: 'العمال'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  sectionsPage(),
                  ledgerPage(LedgerType.client),
                  ledgerPage(LedgerType.vendor),
                  ledgerPage(LedgerType.worker),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionsPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: <Widget>[
        FilledButton.icon(
          onPressed: showCreateSectionDialog,
          icon: const Icon(Icons.create_new_folder_rounded),
          label: const Text('إنشاء قسم جديد'),
        ),
        const SizedBox(height: 12),
        if (_sections.isEmpty)
          const EmptyStateBox(
            icon: Icons.folder_open_rounded,
            title: 'لا توجد أقسام بعد',
            subtitle: 'أنشئ قسمك الأول: صندوق البيت، متجر، سفر، بناء أو أي اسم تريده.',
          )
        else
          ..._sections.map(
            (FinancialSection section) => SectionCard(
              section: section,
              balance: money(sectionBalance(section)),
              onAddOperation: () => showAddTransactionDialog(section),
              onTransfer: () => showTransferDialog(section),
            ),
          ),
        const BrandFooter(),
      ],
    );
  }

  Widget ledgerPage(LedgerType type) {
    final List<LedgerEntry> entries = ledgerList(type);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => showAddLedgerDialog(type),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text('إضافة ${ledgerTypeName(type)}'),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const EmptyStateBox(
            icon: Icons.person_off_outlined,
            title: 'لا توجد قيود',
            subtitle: 'أضف سجلًا جديدًا وسيظهر هنا.',
          )
        else
          ...entries.map(
            (LedgerEntry entry) => LedgerCard(
              entry: entry,
              amount: money(entry.balance.abs()),
              onWhatsApp: () => sendReminder(entry),
              onDelete: () {
                setState(() => ledgerList(type).remove(entry));
                snack('تم حذف السجل.');
              },
            ),
          ),
        const BrandFooter(),
      ],
    );
  }

  Widget kidsSavingsPage() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          const AppHeader(
            title: 'حصالة الأطفال والتدقيق',
            subtitle: 'أهداف ادخار ومكافآت ومتابعة تربوية',
            icon: Icons.savings_rounded,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: showAddChildGoalDialog,
            icon: const Icon(Icons.add_reaction_rounded),
            label: const Text('إنشاء هدف ادخار للطفل'),
          ),
          const SizedBox(height: 12),
          if (_childGoals.isEmpty)
            const EmptyStateBox(
              icon: Icons.child_care_rounded,
              title: 'لا توجد حصالات أطفال',
              subtitle: 'أنشئ هدفًا مثل لعبة، رحلة، دراجة أو مصروف مدرسي.',
            )
          else
            ..._childGoals.map(
              (ChildGoal goal) => Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${goal.childName} — ${goal.goalName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: goal.progress),
                      const SizedBox(height: 8),
                      Text(
                        '${money(goal.saved)} من ${money(goal.target)} ريال • نقاط مكافأة: ${money(goal.rewardPoints)}',
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () => showDepositChildDialog(goal),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('إضافة ادخار أو مكافأة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const BrandFooter(),
        ],
      ),
    );
  }

  Widget expensesAndInventoryPage() {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: AppHeader(
                title: 'إدارة المصاريف والجرد',
                subtitle: 'مصروفات، مبيعات، مخزون وتنبيهات أمان',
                icon: Icons.inventory_2_rounded,
              ),
            ),
            const TabBar(
              tabs: <Widget>[
                Tab(text: 'السجلات'),
                Tab(text: 'الجرد'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  transactionsPage(),
                  inventoryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionsPage() {
    final bool allSelected = _transactions.isNotEmpty &&
        _selectedIds.length == _transactions.length;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: _sections.isEmpty
                      ? null
                      : () => showAddTransactionDialog(_sections.first),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة عملية'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  setState(() {
                    _selectionMode = !_selectionMode;
                    if (!_selectionMode) {
                      _selectedIds.clear();
                    }
                  });
                },
                icon: Icon(
                  _selectionMode
                      ? Icons.close_rounded
                      : Icons.checklist_rounded,
                ),
              ),
            ],
          ),
        ),
        if (_hasLeak)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.danger),
              ),
              child: Text(
                'تنبيه تسرب مالي: المصروفات ${money(_totalExpenses)} تجاوزت حد الأمان ${money(_expenseThreshold)}.',
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        if (_selectionMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (allSelected) {
                          _selectedIds.clear();
                        } else {
                          _selectedIds
                            ..clear()
                            ..addAll(
                              _transactions.map(
                                (FinancialTransaction item) => item.id,
                              ),
                            );
                        }
                      });
                    },
                    child: Text(
                      allSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: exportSelected,
                    icon: const Icon(Icons.file_download_rounded),
                    label: const Text('تصدير'),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _transactions.isEmpty
              ? const Center(
                  child: EmptyStateBox(
                    icon: Icons.receipt_long_outlined,
                    title: 'لا توجد عمليات',
                    subtitle: 'أنشئ الأقسام أولًا ثم أضف دخلاً أو خرجًا أو تحويلًا.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: _transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final FinancialTransaction item = _transactions[index];
                    final bool selected = _selectedIds.contains(item.id);

                    return TransactionCard(
                      item: item,
                      amount: money(item.amount),
                      section: sectionName(item.sectionId),
                      selectionMode: _selectionMode,
                      selected: selected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedIds.add(item.id);
                          } else {
                            _selectedIds.remove(item.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget inventoryPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: <Widget>[
        FilledButton.icon(
          onPressed: showAddInventoryDialog,
          icon: const Icon(Icons.add_box_rounded),
          label: const Text('إضافة صنف إلى الجرد'),
        ),
        const SizedBox(height: 12),
        if (_inventory.isEmpty)
          const EmptyStateBox(
            icon: Icons.inventory_2_outlined,
            title: 'المخزون فارغ',
            subtitle: 'أضف منتجات أو مواد أو أصول لمتابعة الكميات.',
          )
        else
          ..._inventory.map(
            (InventoryItem item) => Card(
              elevation: 0,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.inventory_2_rounded),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  'الكمية: ${money(item.quantity)} • سعر الوحدة: ${money(item.unitPrice)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.point_of_sale_rounded),
                  onPressed: () => showInventorySaleDialog(item),
                ),
              ),
            ),
          ),
        const BrandFooter(),
      ],
    );
  }

  Widget controlCenterPage() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          const AppHeader(
            title: 'مركز التحكم الفخم والأمان',
            subtitle: 'المظهر، الأرقام، الأسعار، الهوية والحدود',
            icon: Icons.admin_panel_settings_rounded,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                child: Text(
                  _profileAvatar,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              title: Text(
                _profileName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(_profilePhone),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: showProfileDialog,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('الوضع الداكن'),
                  value: widget.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    widget.onThemeChanged(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.numbers_rounded),
                  title: const Text('الأرقام العربية'),
                  subtitle: const Text('١٢٣ بدلاً من 123'),
                  value: widget.arabicDigits,
                  onChanged: widget.onArabicDigitsChanged,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded),
                  title: const Text('نمط الخط'),
                  trailing: DropdownButton<String>(
                    value: widget.fontMode,
                    underline: const SizedBox.shrink(),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'system',
                        child: Text('النظام'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'serif',
                        child: Text('Serif'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'mono',
                        child: Text('Monospace'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        widget.onFontChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NumberEditor(
            title: 'سعر 1 ريال سعودي بالريال اليمني',
            value: _yerPerSar,
            onSave: (double value) {
              setState(() => _yerPerSar = value);
            },
          ),
          const SizedBox(height: 8),
          NumberEditor(
            title: 'سعر 1 دولار بالريال اليمني',
            value: _yerPerUsd,
            onSave: (double value) {
              setState(() => _yerPerUsd = value);
            },
          ),
          const SizedBox(height: 8),
          NumberEditor(
            title: 'حد تنبيه المصروفات',
            value: _expenseThreshold,
            onSave: (double value) {
              setState(() => _expenseThreshold = value);
            },
          ),
          const SizedBox(height: 18),
          const BrandFooter(),
        ],
      ),
    );
  }

  void showCreateSectionDialog() {
    final TextEditingController name = TextEditingController();
    final TextEditingController description = TextEditingController();
    final TextEditingController currency =
        TextEditingController(text: 'YER');

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إنشاء قسم مالي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  hintText: 'مثل: صندوق البيت أو تجارة الملابس',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'وصف القسم'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: currency,
                decoration: const InputDecoration(
                  labelText: 'العملة',
                  hintText: 'YER أو SAR أو USD',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                addSection(
                  name: name.text,
                  description: description.text,
                  currency: currency.text,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      name.dispose();
      description.dispose();
      currency.dispose();
    });
  }

  void showAddTransactionDialog(FinancialSection defaultSection) {
    if (_sections.isEmpty) {
      snack('أنشئ قسمًا ماليًا أولًا.', error: true);
      return;
    }

    final TextEditingController title = TextEditingController();
    final TextEditingController amount = TextEditingController();
    final TextEditingController date =
        TextEditingController(text: 'تاريخ ميلادي / هجري');
    final TextEditingController category = TextEditingController();
    final TextEditingController counterparty = TextEditingController();
    final TextEditingController place = TextEditingController();
    final TextEditingController reason = TextEditingController();
    final TextEditingController method = TextEditingController(
      text: 'نقدًا',
    );
    final TextEditingController reference = TextEditingController();
    final TextEditingController notes = TextEditingController();
    final TextEditingController labels = TextEditingController();

    FinancialSection selectedSection = defaultSection;
    TransactionType selectedType = TransactionType.expense;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'عملية مالية مفصلة',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<FinancialSection>(
                      value: selectedSection,
                      decoration: const InputDecoration(labelText: 'القسم'),
                      items: _sections.map(
                        (FinancialSection section) {
                          return DropdownMenuItem<FinancialSection>(
                            value: section,
                            child: Text(section.name),
                          );
                        },
                      ).toList(),
                      onChanged: (FinancialSection? value) {
                        if (value != null) {
                          setSheetState(() => selectedSection = value);
                        }
                      },
                    ),
                    const SizedBox(height: 9),
                    DropdownButtonFormField<TransactionType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'نوع الحركة'),
                      items: const <DropdownMenuItem<TransactionType>>[
                        DropdownMenuItem<TransactionType>(
                          value: TransactionType.income,
                          child: Text('دخل'),
                        ),
                        DropdownMenuItem<TransactionType>(
                          value: TransactionType.expense,
                          child: Text('خرج / مصروف'),
                        ),
                      ],
                      onChanged: (TransactionType? value) {
                        if (value != null) {
                          setSheetState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: 'ماذا حدث؟ عنوان العملية',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'المبلغ',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: category,
                      decoration: const InputDecoration(
                        labelText: 'التصنيف',
                        hintText: 'منزل، تجارة، نقل، إيجار، علاج...',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: counterparty,
                      decoration: const InputDecoration(
                        labelText: 'من / إلى من؟',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: place,
                      decoration: const InputDecoration(
                        labelText: 'أين حدثت العملية؟',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: reason,
                      decoration: const InputDecoration(
                        labelText: 'لماذا تمت العملية؟',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: method,
                      decoration: const InputDecoration(
                        labelText: 'كيف تم الدفع أو الاستلام؟',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: date,
                      decoration: const InputDecoration(
                        labelText: 'متى؟ تاريخ هجري أو ميلادي',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: reference,
                      decoration: const InputDecoration(
                        labelText: 'رقم فاتورة أو حوالة أو مرجع',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: labels,
                      decoration: const InputDecoration(
                        labelText: 'وسوم مفصولة بفواصل',
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: notes,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات إضافية',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final double? value = parseDouble(amount.text);

                          if (value == null) {
                            snack('أدخل مبلغًا صحيحًا.', error: true);
                            return;
                          }

                          addTransaction(
                            FinancialTransaction(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              sectionId: selectedSection.id,
                              title: title.text.trim().isEmpty
                                  ? 'عملية مالية'
                                  : title.text.trim(),
                              type: selectedType,
                              amount: value,
                              currency: selectedSection.currency,
                              dateLabel: date.text.trim(),
                              category: category.text.trim(),
                              counterparty: counterparty.text.trim(),
                              place: place.text.trim(),
                              reason: reason.text.trim(),
                              paymentMethod: method.text.trim(),
                              referenceNumber: reference.text.trim(),
                              notes: notes.text.trim(),
                              labels: labels.text
                                  .split(',')
                                  .map((String item) => item.trim())
                                  .where(
                                    (String item) => item.isNotEmpty,
                                  )
                                  .toList(),
                            ),
                          );

                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('حفظ العملية'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      title.dispose();
      amount.dispose();
      date.dispose();
      category.dispose();
      counterparty.dispose();
      place.dispose();
      reason.dispose();
      method.dispose();
      reference.dispose();
      notes.dispose();
      labels.dispose();
    });
  }

  void showTransferDialog(FinancialSection from) {
    if (_sections.length < 2) {
      snack('أنشئ قسمًا ثانيًا لإجراء تحويل.', error: true);
      return;
    }

    final TextEditingController amount = TextEditingController();
    final TextEditingController notes = TextEditingController();
    FinancialSection target =
        _sections.firstWhere((FinancialSection item) => item.id != from.id);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('تحويل من ${from.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<FinancialSection>(
                value: target,
                decoration: const InputDecoration(labelText: 'القسم المستهدف'),
                items: _sections
                    .where(
                      (FinancialSection item) => item.id != from.id,
                    )
                    .map(
                      (FinancialSection item) =>
                          DropdownMenuItem<FinancialSection>(
                        value: item,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (FinancialSection? value) {
                  if (value != null) {
                    target = value;
                  }
                },
              ),
              const SizedBox(height: 9),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'المبلغ'),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'سبب التحويل'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final double? value = parseDouble(amount.text);

                if (value == null) {
                  snack('أدخل مبلغًا صالحًا.', error: true);
                  return;
                }

                transfer(
                  from: from,
                  to: target,
                  amount: value,
                  description: notes.text,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('تنفيذ التحويل'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      amount.dispose();
      notes.dispose();
    });
  }

  void showAddLedgerDialog(LedgerType type) {
    final TextEditingController name = TextEditingController();
    final TextEditingController phone = TextEditingController();
    final TextEditingController credit = TextEditingController();
    final TextEditingController debit = TextEditingController();
    final TextEditingController notes = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('إضافة ${ledgerTypeName(type)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم واتساب اليمني 967',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: credit,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'له'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: debit,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'عليه'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
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
                final double creditValue = parseDouble(credit.text) ?? 0.0;
                final double debitValue = parseDouble(debit.text) ?? 0.0;

                setState(() {
                  ledgerList(type).add(
                    LedgerEntry(
                      id: DateTime.now()
                          .microsecondsSinceEpoch
                          .toString(),
                      name: name.text.trim().isEmpty
                          ? 'بدون اسم'
                          : name.text.trim(),
                      phone: phone.text.trim(),
                      type: type,
                      credit: creditValue,
                      debit: debitValue,
                      currency: 'YER',
                      notes: notes.text.trim(),
                    ),
                  );
                });

                Navigator.pop(dialogContext);
                snack('تمت إضافة السجل.');
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      name.dispose();
      phone.dispose();
      credit.dispose();
      debit.dispose();
      notes.dispose();
    });
  }

  void showAddChildGoalDialog() {
    final TextEditingController child = TextEditingController();
    final TextEditingController goal = TextEditingController();
    final TextEditingController target = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('هدف ادخار جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: child,
                decoration: const InputDecoration(labelText: 'اسم الطفل'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: goal,
                decoration: const InputDecoration(labelText: 'الهدف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: target,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'المبلغ المستهدف',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final double? value = parseDouble(target.text);

                if (value == null || value <= 0.0) {
                  snack('أدخل هدفًا ماليًا صحيحًا.', error: true);
                  return;
                }

                setState(() {
                  _childGoals.add(
                    ChildGoal(
                      id: DateTime.now()
                          .microsecondsSinceEpoch
                          .toString(),
                      childName: child.text.trim(),
                      goalName: goal.text.trim(),
                      target: value,
                    ),
                  );
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      child.dispose();
      goal.dispose();
      target.dispose();
    });
  }

  void showDepositChildDialog(ChildGoal goal) {
    final TextEditingController amount = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('إيداع في حصالة ${goal.childName}'),
          content: TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(labelText: 'المبلغ'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final double? value = parseDouble(amount.text);

                if (value == null || value <= 0.0) {
                  snack('أدخل مبلغًا صحيحًا.', error: true);
                  return;
                }

                setState(() {
                  goal.saved += value;
                  goal.rewardPoints += value / 1000.0;
                });

                Navigator.pop(dialogContext);
                snack('تمت إضافة الادخار والمكافأة.');
              },
              child: const Text('إيداع'),
            ),
          ],
        );
      },
    ).whenComplete(amount.dispose);
  }

  void showAddInventoryDialog() {
    final TextEditingController name = TextEditingController();
    final TextEditingController quantity = TextEditingController();
    final TextEditingController price = TextEditingController();
    final TextEditingController minimum = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إضافة صنف للجرد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'اسم الصنف'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'سعر الوحدة'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minimum,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'حد التنبيه'),
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
                setState(() {
                  _inventory.add(
                    InventoryItem(
                      id: DateTime.now()
                          .microsecondsSinceEpoch
                          .toString(),
                      name: name.text.trim().isEmpty
                          ? 'صنف بدون اسم'
                          : name.text.trim(),
                      quantity: parseDouble(quantity.text) ?? 0.0,
                      unitPrice: parseDouble(price.text) ?? 0.0,
                      minimumQuantity: parseDouble(minimum.text) ?? 0.0,
                    ),
                  );
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      name.dispose();
      quantity.dispose();
      price.dispose();
      minimum.dispose();
    });
  }

  void showInventorySaleDialog(InventoryItem item) {
    final TextEditingController quantity = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('بيع من ${item.name}'),
          content: TextField(
            controller: quantity,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(labelText: 'الكمية المباعة'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final double? sold = parseDouble(quantity.text);

                if (sold == null || sold <= 0.0 || sold > item.quantity) {
                  snack('الكمية غير صالحة أو أكبر من المخزون.', error: true);
                  return;
                }

                setState(() {
                  item.quantity -= sold;
                });

                Navigator.pop(dialogContext);
                snack('تم خصم ${money(sold)} وحدة من الجرد.');
              },
              child: const Text('تأكيد البيع'),
            ),
          ],
        );
      },
    ).whenComplete(quantity.dispose);
  }

  void showProfileDialog() {
    final TextEditingController name =
        TextEditingController(text: _profileName);
    final TextEditingController phone =
        TextEditingController(text: _profilePhone);
    final TextEditingController avatar =
        TextEditingController(text: _profileAvatar);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'الهاتف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: avatar,
                maxLength: 3,
                decoration: const InputDecoration(
                  labelText: 'أحرف الصورة',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _profileName = name.text.trim().isEmpty
                      ? _profileName
                      : name.text.trim();

                  _profilePhone = phone.text.trim().isEmpty
                      ? _profilePhone
                      : phone.text.trim();

                  _profileAvatar = avatar.text.trim().isEmpty
                      ? _profileAvatar
                      : avatar.text.trim().toUpperCase();
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      name.dispose();
      phone.dispose();
      avatar.dispose();
    });
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
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
          backgroundColor: AppColors.emerald.withOpacity(0.13),
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

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.balance,
    required this.onAddOperation,
    required this.onTransfer,
  });

  final FinancialSection section;
  final String balance;
  final VoidCallback onAddOperation;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: section.color.withOpacity(0.15),
                  foregroundColor: section.color,
                  child: Icon(section.icon),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        section.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        section.description,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$balance ${section.currency}',
                  style: TextStyle(
                    color: section.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddOperation,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('عملية'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onTransfer,
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('تحويل'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerCard extends StatelessWidget {
  const LedgerCard({
    super.key,
    required this.entry,
    required this.amount,
    required this.onWhatsApp,
    required this.onDelete,
  });

  final LedgerEntry entry;
  final String amount;
  final VoidCallback onWhatsApp;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool positive = entry.balance >= 0.0;
    final Color color =
        positive ? AppColors.success : AppColors.danger;

    return Card(
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          child: Icon(
            entry.type == LedgerType.client
                ? Icons.person_outline_rounded
                : entry.type == LedgerType.vendor
                    ? Icons.storefront_outlined
                    : Icons.badge_outlined,
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          'له: ${entry.credit.toStringAsFixed(0)} • عليه: ${entry.debit.toStringAsFixed(0)}',
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(entry.currency),
              ],
            ),
            IconButton(
              tooltip: 'مطالبة واتساب',
              onPressed: onWhatsApp,
              icon: const Icon(
                Icons.chat_rounded,
                color: Color(0xFF25D366),
              ),
            ),
            IconButton(
              tooltip: 'حذف',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.item,
    required this.amount,
    required this.section,
    required this.selectionMode,
    required this.selected,
    required this.onChanged,
  });

  final FinancialTransaction item;
  final String amount;
  final String section;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool entered = item.type == TransactionType.income ||
        item.type == TransactionType.transferIn;

    final Color color =
        entered ? AppColors.success : AppColors.danger;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (selectionMode)
              Checkbox(
                value: selected,
                onChanged: onChanged,
              ),
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              foregroundColor: color,
              child: Icon(
                entered
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$section • ${item.category} • ${item.dateLabel}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إلى/من: ${item.counterparty} • ${item.paymentMethod}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${entered ? '+' : '-'}$amount',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberEditor extends StatefulWidget {
  const NumberEditor({
    super.key,
    required this.title,
    required this.value,
    required this.onSave,
  });

  final String title;
  final double value;
  final ValueChanged<double> onSave;

  @override
  State<NumberEditor> createState() => _NumberEditorState();
}

class _NumberEditorState extends State<NumberEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant NumberEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: widget.title,
        suffixIcon: IconButton(
          icon: const Icon(Icons.check_rounded),
          onPressed: () {
            final double? value = parseDouble(_controller.text);

            if (value != null && value > 0.0) {
              widget.onSave(value);
            }
          },
        ),
      ),
    );
  }
}

class EmptyStateBox extends StatelessWidget {
  const EmptyStateBox({
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
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
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

class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Text(
        '© 2026 جميع الحقوق محفوظة لـ محاسبي الشامل | صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان (هاتف: 0967775592894)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}

double? parseDouble(String value) {
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

String formatMoney(
  double amount, {
  required bool arabicDigits,
}) {
  final bool negative = amount.isNegative;
  final String source = amount.abs().toStringAsFixed(0);
  final StringBuffer output = StringBuffer();

  for (int index = 0; index < source.length; index++) {
    final int remaining = source.length - index;

    output.write(source[index]);

    if (remaining > 1 && remaining % 3 == 1) {
      output.write(',');
    }
  }

  final String formatted =
      negative ? '-${output.toString()}' : output.toString();

  return arabicDigits ? toArabicDigits(formatted) : formatted;
}

String toArabicDigits(String value) {
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
      .map((String item) => digits[item] ?? item)
      .join();
}

// Strict String input: null handling occurs before calling this function.
String normalizeYemeniPhone(String value) {
  String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleaned.startsWith('00')) {
    cleaned = cleaned.substring(2);
  }

  if (cleaned.startsWith('0')) {
    cleaned = '967${cleaned.substring(1)}';
  }

  if (!cleaned.startsWith('967') || cleaned.length != 12) {
    return '';
  }

  return cleaned;
}

String ledgerTypeName(LedgerType type) {
  switch (type) {
    case LedgerType.client:
      return 'عميل';
    case LedgerType.vendor:
      return 'مورد';
    case LedgerType.worker:
      return 'عامل';
  }
}
