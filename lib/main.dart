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
      title: 'محاسبي',
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
      home: MuhasibiHome(
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
          dark ? const Color(0xFF101716) : const Color(0xFFF4F8F6),
      textTheme: (dark ? Typography.material2021().white : Typography.material2021().black)
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
  static const Color emeraldLight = Color(0xFF19A78C);
  static const Color danger = Color(0xFFB91C1C);
  static const Color success = Color(0xFF15803D);
  static const Color muted = Color(0xFF68736F);
  static const Color gold = Color(0xFFE4B63C);
}

enum TransactionType {
  income,
  expense,
}

enum LedgerType {
  client,
  vendor,
  worker,
}

class WalletFolder {
  WalletFolder({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.balance = 0.0,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  double balance;
}

class TransactionRecord {
  TransactionRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.notes,
    required this.amount,
    required this.type,
  });

  final String id;
  final String title;
  final String category;
  final String dateLabel;
  final String notes;
  final double amount;
  final TransactionType type;
}

class LedgerEntry {
  LedgerEntry({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.balance,
    required this.notes,
    required this.dateLabel,
  });

  final String id;
  String name;

  // Nullable intentionally; every usage is protected with ?? ''.
  String? phone;

  LedgerType type;
  double balance;
  String notes;
  String dateLabel;
}

class MuhasibiHome extends StatefulWidget {
  const MuhasibiHome({
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
  State<MuhasibiHome> createState() => _MuhasibiHomeState();
}

class _MuhasibiHomeState extends State<MuhasibiHome> {
  int _tabIndex = 0;
  bool _selectMode = false;
  final Set<String> _selectedTransactions = <String>{};

  final String _ownerWhatsApp = '967775592894';
  String _profileName = 'أبو علي لقمان';
  String _profilePhone = '967775592894';
  String _avatarLetters = 'AL';

  double _yerPerSar = 140.0;
  double _yerPerUsd = 535.0;
  double _expenseThreshold = 100000.0;

  // Clean-slate wallet folders: all balances start at absolute zero.
  final List<WalletFolder> _wallets = <WalletFolder>[
    WalletFolder(
      id: 'daily',
      title: 'المصروفات اليومية',
      icon: Icons.shopping_basket_rounded,
      color: const Color(0xFF0284C7),
      balance: 0.0,
    ),
    WalletFolder(
      id: 'jamiya',
      title: 'الجمعية والادخار',
      icon: Icons.savings_rounded,
      color: const Color(0xFF7C3AED),
      balance: 0.0,
    ),
    WalletFolder(
      id: 'strategic',
      title: 'الادخار الاستراتيجي',
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF0F766E),
      balance: 0.0,
    ),
  ];

  // Clean-slate dynamic arrays: absolutely empty on first launch.
  final List<LedgerEntry> _clients = <LedgerEntry>[];
  final List<LedgerEntry> _vendors = <LedgerEntry>[];
  final List<LedgerEntry> _workers = <LedgerEntry>[];
  final List<TransactionRecord> _transactions = <TransactionRecord>[];

  double get _netBalance {
    return _wallets.fold<double>(
      0.0,
      (double total, WalletFolder wallet) => total + wallet.balance,
    );
  }

  double get _totalIncome {
    return _transactions
        .where((TransactionRecord item) => item.type == TransactionType.income)
        .fold<double>(
          0.0,
          (double total, TransactionRecord item) => total + item.amount,
        );
  }

  double get _totalExpenses {
    return _transactions
        .where((TransactionRecord item) => item.type == TransactionType.expense)
        .fold<double>(
          0.0,
          (double total, TransactionRecord item) => total + item.amount,
        );
  }

  bool get _financialLeak => _totalExpenses > _expenseThreshold;

  List<LedgerEntry> _ledgerFor(LedgerType type) {
    switch (type) {
      case LedgerType.client:
        return _clients;
      case LedgerType.vendor:
        return _vendors;
      case LedgerType.worker:
        return _workers;
    }
  }

  WalletFolder _walletById(String id) {
    return _wallets.firstWhere((WalletFolder item) => item.id == id);
  }

  String _money(double value) {
    return formatAmount(
      value,
      arabicDigits: widget.arabicDigits,
    );
  }

  void _snack(String message, {bool error = false}) {
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

  void _allocateSalary({
    required double amount,
    required String title,
    required String dateLabel,
    required String notes,
  }) {
    if (!amount.isFinite || amount <= 0.0) {
      _snack('أدخل مبلغ دخل صالح أكبر من صفر.', error: true);
      return;
    }

    final double jamiyaAmount = amount >= 20000.0 ? 20000.0 : amount;
    final double afterJamiya = amount - jamiyaAmount;
    final double dailyAmount = afterJamiya >= 50000.0 ? 50000.0 : afterJamiya;
    final double strategicAmount = afterJamiya - dailyAmount;

    setState(() {
      _walletById('jamiya').balance += jamiyaAmount;
      _walletById('daily').balance += dailyAmount;
      _walletById('strategic').balance += strategicAmount;

      _transactions.insert(
        0,
        TransactionRecord(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title.trim().isEmpty ? 'دخل وارد' : title.trim(),
          category: 'دخل وتوزيع تلقائي',
          dateLabel:
              dateLabel.trim().isEmpty ? 'تاريخ مُدخل يدوياً' : dateLabel.trim(),
          notes: notes.trim().isEmpty
              ? 'الجمعية: ${_money(jamiyaAmount)}، اليومي: ${_money(dailyAmount)}، الاستراتيجي: ${_money(strategicAmount)}.'
              : notes.trim(),
          amount: amount,
          type: TransactionType.income,
        ),
      );
    });

    _snack(
      'تم التوزيع الذكي: جمعية ${_money(jamiyaAmount)}، يومي ${_money(dailyAmount)}، استراتيجي ${_money(strategicAmount)} ريال.',
    );
  }

  void _addTransaction({
    required String title,
    required String category,
    required String dateLabel,
    required String notes,
    required double amount,
    required TransactionType type,
  }) {
    if (!amount.isFinite || amount < 0.0) {
      _snack('المبلغ المدخل غير صالح.', error: true);
      return;
    }

    setState(() {
      _transactions.insert(
        0,
        TransactionRecord(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title.trim().isEmpty ? 'عملية مالية' : title.trim(),
          category: category.trim().isEmpty ? 'عام' : category.trim(),
          dateLabel:
              dateLabel.trim().isEmpty ? 'تاريخ مُدخل يدوياً' : dateLabel.trim(),
          notes: notes.trim(),
          amount: amount,
          type: type,
        ),
      );
    });

    if (type == TransactionType.expense && _financialLeak) {
      _snack(
        'تنبيه تسرب مالي: المصروفات تجاوزت الحد المالي المحدد.',
        error: true,
      );
    } else {
      _snack('تمت إضافة العملية بنجاح.');
    }
  }

  Future<void> _sendDebtReminder(LedgerEntry entry) async {
    // ─────────────────────────────────────────────────────────────
    // The Codemagic null-safety fix:
    // entry.phone is String?, but normalizeYemeniPhone requires String.
    // Therefore null becomes an empty strict String before evaluation.
    // ─────────────────────────────────────────────────────────────
    final String normalizedPhone = normalizeYemeniPhone(entry.phone ?? '');

    if (normalizedPhone.isEmpty) {
      _snack(
        'رقم واتساب غير صالح. أدخل رقمًا يمنيًا صحيحًا يبدأ بـ 967.',
        error: true,
      );
      return;
    }

    final String contactName = entry.name.trim().isEmpty
        ? 'العميل'
        : entry.name.trim();

    final String message = '''
مرحباً $contactName،
تفاصيل الحساب المالي المتبقي لديكم: ${_money(entry.balance)} ريال يمني.
الوصف: ${entry.notes}
التاريخ: ${entry.dateLabel}
صُنع وتم الابتكار بواسطة المطور مالك النظام أبو علي لقمان للتواصل هاتف: 0967775592894
''';

    final Uri whatsappUri = Uri.https(
      'wa.me',
      '/$normalizedPhone',
      <String, String>{'text': message},
    );

    final bool opened = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) {
      return;
    }

    if (!opened) {
      _snack(
        'تعذر فتح WhatsApp. تأكد من تثبيت التطبيق وصحة الرقم.',
        error: true,
      );
    }
  }

  Future<void> _sendCloudBackup() async {
    final String normalizedPhone = normalizeYemeniPhone(_ownerWhatsApp);

    if (normalizedPhone.isEmpty) {
      _snack('رقم النسخة الاحتياطية غير صالح.', error: true);
      return;
    }

    final String backup = '''
نسخة احتياطية من محاسبي
المالك: $_profileName
الهاتف: $_profilePhone
================================
صافي الرصيد: ${_money(_netBalance)} ريال يمني
إجمالي الدخل: ${_money(_totalIncome)} ريال يمني
إجمالي المصروفات: ${_money(_totalExpenses)} ريال يمني
================================
المحافظ:
${_wallets.map((WalletFolder item) => '- ${item.title}: ${_money(item.balance)} ريال').join('\n')}
================================
العملاء: ${_clients.length}
الموردون: ${_vendors.length}
العمال: ${_workers.length}
السجلات: ${_transactions.length}
================================
© 2026 جميع الحقوق محفوظة لـ محاسبي
صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان
''';

    final Uri whatsappUri = Uri.https(
      'wa.me',
      '/$normalizedPhone',
      <String, String>{'text': backup},
    );

    final bool opened = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) {
      return;
    }

    if (!opened) {
      _snack('تعذر فتح WhatsApp لإرسال النسخة الاحتياطية.', error: true);
    }
  }

  void _exportTransactions() {
    final List<TransactionRecord> records =
        _selectMode && _selectedTransactions.isNotEmpty
            ? _transactions
                .where(
                  (TransactionRecord item) =>
                      _selectedTransactions.contains(item.id),
                )
                .toList()
            : _transactions;

    final String report = '''
تقرير محاسبي المالي
المالك: $_profileName
عدد السجلات: ${records.length}
================================================
${records.map((TransactionRecord item) {
      final String type =
          item.type == TransactionType.income ? 'دخل' : 'مصروف';

      return '''
العنوان: ${item.title}
النوع: $type
التصنيف: ${item.category}
المبلغ: ${_money(item.amount)} ريال يمني
التاريخ: ${item.dateLabel}
الملاحظات: ${item.notes}
------------------------------------------------''';
    }).join('\n')}
© 2026 جميع الحقوق محفوظة لـ محاسبي
صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان
''';

    debugPrint(report);

    _snack(
      'تم تجهيز تقرير نصي منظم لـ ${records.length} سجل. تم إنشاء النص بنجاح.',
    );
  }

  void _showSalaryDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController titleController =
        TextEditingController(text: 'راتب أو دخل وارد');
    final TextEditingController dateController =
        TextEditingController(text: 'ميلادي / هجري: يُدخل يدوياً');
    final TextEditingController notesController =
        TextEditingController(text: 'توزيع تلقائي للمحافظ');

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('توزيع الدخل التلقائي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'القاعدة: 20,000 ريال للجمعية، 50,000 ريال للمصروفات اليومية، والباقي للادخار الاستراتيجي.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'مبلغ الدخل بالريال اليمني',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان العملية'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'التاريخ الميلادي أو الهجري',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
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
                final double? amount = parseDouble(amountController.text);

                if (amount == null) {
                  _snack('أدخل مبلغًا صحيحًا.', error: true);
                  return;
                }

                _allocateSalary(
                  amount: amount,
                  title: titleController.text,
                  dateLabel: dateController.text,
                  notes: notesController.text,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('تنفيذ التوزيع'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      amountController.dispose();
      titleController.dispose();
      dateController.dispose();
      notesController.dispose();
    });
  }

  void _showTransactionDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController =
        TextEditingController(text: 'ميلادي / هجري: يُدخل يدوياً');
    final TextEditingController notesController = TextEditingController();

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
                      'إضافة عملية مالية',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'العنوان'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'المبلغ بالريال اليمني',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'التاريخ الهجري أو الميلادي',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات المستلم أو تفاصيل العملية',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<TransactionType>(
                      segments: const <ButtonSegment<TransactionType>>[
                        ButtonSegment<TransactionType>(
                          value: TransactionType.income,
                          icon: Icon(Icons.add_circle_outline),
                          label: Text('دخل'),
                        ),
                        ButtonSegment<TransactionType>(
                          value: TransactionType.expense,
                          icon: Icon(Icons.remove_circle_outline),
                          label: Text('مصروف'),
                        ),
                      ],
                      selected: <TransactionType>{selectedType},
                      onSelectionChanged: (Set<TransactionType> value) {
                        setSheetState(() => selectedType = value.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final double? amount =
                              parseDouble(amountController.text);

                          if (amount == null) {
                            _snack('أدخل مبلغًا صالحًا.', error: true);
                            return;
                          }

                          _addTransaction(
                            title: titleController.text,
                            category: categoryController.text,
                            dateLabel: dateController.text,
                            notes: notesController.text,
                            amount: amount,
                            type: selectedType,
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
      titleController.dispose();
      categoryController.dispose();
      amountController.dispose();
      dateController.dispose();
      notesController.dispose();
    });
  }

  void _showAddLedgerDialog(LedgerType type) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController dateController =
        TextEditingController(text: 'تاريخ مُدخل يدوياً');

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('إضافة ${ledgerTypeTitle(type)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم واتساب اليمني 967',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'الرصيد'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'تاريخ الاستحقاق'),
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
                final double? balance = parseDouble(balanceController.text);

                if (balance == null || balance < 0.0) {
                  _snack('أدخل رصيدًا صالحًا.', error: true);
                  return;
                }

                setState(() {
                  _ledgerFor(type).add(
                    LedgerEntry(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: nameController.text.trim().isEmpty
                          ? 'بدون اسم'
                          : nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      type: type,
                      balance: balance,
                      notes: notesController.text.trim(),
                      dateLabel: dateController.text.trim().isEmpty
                          ? 'غير محدد'
                          : dateController.text.trim(),
                    ),
                  );
                });

                Navigator.pop(dialogContext);
                _snack('تمت إضافة ${ledgerTypeTitle(type)}.');
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      balanceController.dispose();
      notesController.dispose();
      dateController.dispose();
    });
  }

  void _showLedgerMenu(LedgerEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.visibility_rounded),
                title: const Text('عرض الملف'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showLedgerDetails(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('تعديل السجل'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editLedgerEntry(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text('مشاركة تأكيد الرصيد'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _sendDebtReminder(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.print_rounded),
                title: const Text('طباعة التأكيد'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _snack(
                    'تم تجهيز نص تأكيد الرصيد. الطباعة الفعلية تحتاج حزمة إضافية.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'حذف السجل',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() {
                    _ledgerFor(entry.type).removeWhere(
                      (LedgerEntry item) => item.id == entry.id,
                    );
                  });
                  _snack('تم حذف السجل.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLedgerDetails(LedgerEntry entry) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(entry.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              detailLine('النوع', ledgerTypeTitle(entry.type)),
              detailLine('الرصيد', '${_money(entry.balance)} ريال يمني'),
              detailLine('الهاتف', entry.phone ?? 'غير مسجل'),
              detailLine('الوصف', entry.notes),
              detailLine('التاريخ', entry.dateLabel),
            ],
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

  void _editLedgerEntry(LedgerEntry entry) {
    final TextEditingController nameController =
        TextEditingController(text: entry.name);
    final TextEditingController phoneController =
        TextEditingController(text: entry.phone ?? '');
    final TextEditingController balanceController =
        TextEditingController(text: entry.balance.toString());
    final TextEditingController notesController =
        TextEditingController(text: entry.notes);
    final TextEditingController dateController =
        TextEditingController(text: entry.dateLabel);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تعديل السجل'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم واتساب'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'الرصيد'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'التاريخ'),
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
                final double? balance = parseDouble(balanceController.text);

                if (balance == null || balance < 0.0) {
                  _snack('أدخل مبلغًا صالحًا.', error: true);
                  return;
                }

                setState(() {
                  entry.name = nameController.text.trim().isEmpty
                      ? 'بدون اسم'
                      : nameController.text.trim();
                  entry.phone = phoneController.text.trim();
                  entry.balance = balance;
                  entry.notes = notesController.text.trim();
                  entry.dateLabel = dateController.text.trim();
                });

                Navigator.pop(dialogContext);
                _snack('تم تعديل السجل.');
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      balanceController.dispose();
      notesController.dispose();
      dateController.dispose();
    });
  }

  void _editProfile() {
    final TextEditingController nameController =
        TextEditingController(text: _profileName);
    final TextEditingController phoneController =
        TextEditingController(text: _profilePhone);
    final TextEditingController avatarController =
        TextEditingController(text: _avatarLetters);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'الهاتف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: avatarController,
                maxLength: 3,
                decoration: const InputDecoration(labelText: 'حروف الصورة'),
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
                  _profileName = nameController.text.trim().isEmpty
                      ? _profileName
                      : nameController.text.trim();

                  _profilePhone = phoneController.text.trim().isEmpty
                      ? _profilePhone
                      : phoneController.text.trim();

                  _avatarLetters = avatarController.text.trim().isEmpty
                      ? _avatarLetters
                      : avatarController.text.trim().toUpperCase();
                });

                Navigator.pop(dialogContext);
                _snack('تم حفظ بيانات الملف الشخصي.');
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      avatarController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _walletsPage(),
      _ledgerPage(),
      _recordsPage(),
      _controlPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: pages,
      ),
      floatingActionButton: _tabIndex == 2
          ? FloatingActionButton.extended(
              onPressed: _showTransactionDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة عملية'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        height: 78,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int value) {
          setState(() => _tabIndex = value);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'المحافظ والصندوق',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'دفتر الحسابات',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'السجلات والتقارير',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'مركز التحكم',
          ),
        ],
      ),
    );
  }

  Widget _walletsPage() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: <Widget>[
          const PageHeader(
            title: 'المحافظ والصندوق',
            subtitle: 'إدارة سيولة ذكية من رصيد صفر',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 20),
          Container(
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'صافي الرصيد التراكمي',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${_money(_netBalance)} ي.ر',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الدخل: ${_money(_totalIncome)} • المصروفات: ${_money(_totalExpenses)}',
                  style: const TextStyle(
                    color: Color(0xFFD2F4EA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_financialLeak)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.danger),
              ),
              child: Text(
                'تنبيه تسرب مالي: إجمالي المصروفات ${_money(_totalExpenses)} تجاوز حد الميزانية ${_money(_expenseThreshold)}.',
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: _showSalaryDialog,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('توزيع دخل'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sendCloudBackup,
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('نسخة واتساب'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'المحافظ الفرعية',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ..._wallets.map(
            (WalletFolder wallet) => Card(
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: CircleAvatar(
                  backgroundColor: wallet.color.withOpacity(0.14),
                  foregroundColor: wallet.color,
                  child: Icon(wallet.icon),
                ),
                title: Text(
                  wallet.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('الرصيد يبدأ من صفر ويتراكم ديناميكياً'),
                trailing: Text(
                  '${_money(wallet.balance)} ي.ر',
                  style: TextStyle(
                    color: wallet.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          CurrencyConverter(
            arabicDigits: widget.arabicDigits,
            yerPerSar: _yerPerSar,
            yerPerUsd: _yerPerUsd,
          ),
          const BrandFooter(),
        ],
      ),
    );
  }

  Widget _ledgerPage() {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: PageHeader(
                title: 'دفتر الحسابات',
                subtitle: 'العملاء والموردون والعمال',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const TabBar(
              tabs: <Widget>[
                Tab(text: 'العملاء'),
                Tab(text: 'الموردون'),
                Tab(text: 'العمال'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _ledgerList(LedgerType.client),
                  _ledgerList(LedgerType.vendor),
                  _ledgerList(LedgerType.worker),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ledgerList(LedgerType type) {
    final List<LedgerEntry> entries = _ledgerFor(type);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => _showAddLedgerDialog(type),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text('إضافة ${ledgerTypeTitle(type)}'),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const EmptyBox(
            icon: Icons.folder_open_rounded,
            title: 'لا توجد بيانات بعد',
            subtitle: 'ابدأ بإضافة قيد جديد إلى دفتر الحسابات.',
          )
        else
          ...entries.map(
            (LedgerEntry entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LedgerCard(
                entry: entry,
                amount: _money(entry.balance),
                onReminder: () => _sendDebtReminder(entry),
                onLongPress: () => _showLedgerMenu(entry),
                onTap: () => _showLedgerDetails(entry),
              ),
            ),
          ),
        const BrandFooter(),
      ],
    );
  }

  Widget _recordsPage() {
    final bool allSelected = _transactions.isNotEmpty &&
        _selectedTransactions.length == _transactions.length;

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PageHeader(
                    title: _selectMode
                        ? 'تم تحديد ${_selectedTransactions.length} سجل'
                        : 'السجلات والتقارير',
                    subtitle: 'تحديد متعدد وتصدير نصي منسق',
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _selectMode = !_selectMode;
                      if (!_selectMode) {
                        _selectedTransactions.clear();
                      }
                    });
                  },
                  icon: Icon(
                    _selectMode
                        ? Icons.close_rounded
                        : Icons.checklist_rounded,
                  ),
                ),
              ],
            ),
          ),
          if (_selectMode)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _transactions.isEmpty
                          ? null
                          : () {
                              setState(() {
                                if (allSelected) {
                                  _selectedTransactions.clear();
                                } else {
                                  _selectedTransactions
                                    ..clear()
                                    ..addAll(
                                      _transactions.map(
                                        (TransactionRecord item) => item.id,
                                      ),
                                    );
                                }
                              });
                            },
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
                          _transactions.isEmpty ? null : _exportTransactions,
                      icon: const Icon(Icons.file_download_rounded),
                      label: const Text('تصدير TXT'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: EmptyBox(
                      icon: Icons.receipt_long_outlined,
                      title: 'السجل فارغ',
                      subtitle: 'لا توجد عمليات مالية منذ تشغيل التطبيق.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                    itemCount: _transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final TransactionRecord item = _transactions[index];
                      final bool selected =
                          _selectedTransactions.contains(item.id);

                      return TransactionCard(
                        item: item,
                        amount: _money(item.amount),
                        selectionMode: _selectMode,
                        selected: selected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              _selectedTransactions.add(item.id);
                            } else {
                              _selectedTransactions.remove(item.id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _controlPage() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: <Widget>[
          const PageHeader(
            title: 'مركز التحكم الفخم',
            subtitle: 'الهوية والمظهر والأرقام والحدود المالية',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                child: Text(
                  _avatarLetters,
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
                onPressed: _editProfile,
              ),
            ),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          NumberSetting(
            label: 'سعر 1 ريال سعودي بالريال اليمني',
            value: _yerPerSar,
            onSave: (double value) {
              setState(() => _yerPerSar = value);
            },
          ),
          const SizedBox(height: 10),
          NumberSetting(
            label: 'سعر 1 دولار بالريال اليمني',
            value: _yerPerUsd,
            onSave: (double value) {
              setState(() => _yerPerUsd = value);
            },
          ),
          const SizedBox(height: 10),
          NumberSetting(
            label: 'حد تنبيه التسرب المالي',
            value: _expenseThreshold,
            onSave: (double value) {
              setState(() => _expenseThreshold = value);
            },
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFF451313),
                  Color(0xFF111111),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.6),
              ),
            ),
            child: const Column(
              children: <Widget>[
                Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.gold,
                  size: 34,
                ),
                SizedBox(height: 8),
                Text(
                  'لوحة الملكية الفكرية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'هوية محاسبي وعلامتها التجارية جزء ثابت من واجهة النظام.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF4E8E8),
                  ),
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

class PageHeader extends StatelessWidget {
  const PageHeader({
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

class LedgerCard extends StatelessWidget {
  const LedgerCard({
    super.key,
    required this.entry,
    required this.amount,
    required this.onReminder,
    required this.onLongPress,
    required this.onTap,
  });

  final LedgerEntry entry;
  final String amount;
  final VoidCallback onReminder;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool client = entry.type == LedgerType.client;
    final Color color = client ? AppColors.success : AppColors.danger;

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              CircleAvatar(
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.notes} • ${entry.dateLabel}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Text(
                    amount,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    tooltip: 'واتساب',
                    onPressed: onReminder,
                    icon: const Icon(
                      Icons.chat_rounded,
                      color: Color(0xFF25D366),
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

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.item,
    required this.amount,
    required this.selectionMode,
    required this.selected,
    required this.onChanged,
  });

  final TransactionRecord item;
  final String amount;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool income = item.type == TransactionType.income;
    final Color color = income ? AppColors.success : AppColors.danger;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.emerald : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                income
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
                  const SizedBox(height: 4),
                  Text(
                    '${item.category} • ${item.dateLabel}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${income ? '+' : '-'}$amount',
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

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({
    super.key,
    required this.arabicDigits,
    required this.yerPerSar,
    required this.yerPerUsd,
  });

  final bool arabicDigits;
  final double yerPerSar;
  final double yerPerUsd;

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _controller = TextEditingController();
  double _yer = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String sar = formatAmount(
      _yer / widget.yerPerSar,
      arabicDigits: widget.arabicDigits,
    );

    final String usd = formatAmount(
      _yer / widget.yerPerUsd,
      arabicDigits: widget.arabicDigits,
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(
                  Icons.currency_exchange_rounded,
                  color: AppColors.emerald,
                ),
                SizedBox(width: 8),
                Text(
                  'محول العملات الذكي',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'المبلغ بالريال اليمني',
                suffixText: 'YER',
              ),
              onChanged: (String value) {
                setState(() {
                  _yer = parseDouble(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 12),
            Text('ريال سعودي: $sar SAR'),
            const SizedBox(height: 6),
            Text('دولار أمريكي: $usd USD'),
          ],
        ),
      ),
    );
  }
}

class NumberSetting extends StatefulWidget {
  const NumberSetting({
    super.key,
    required this.label,
    required this.value,
    required this.onSave,
  });

  final String label;
  final double value;
  final ValueChanged<double> onSave;

  @override
  State<NumberSetting> createState() => _NumberSettingState();
}

class _NumberSettingState extends State<NumberSetting> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant NumberSetting oldWidget) {
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
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

class EmptyBox extends StatelessWidget {
  const EmptyBox({
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
          Icon(icon, size: 48, color: AppColors.muted),
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
        '© 2026 جميع الحقوق محفوظة لـ محاسبي | صُنع وتم الابتكار بواسطة ABOALILUQMAN — أبو علي لقمان (هاتف: 0967775592894)',
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

Widget detailLine(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: <TextSpan>[
          TextSpan(
            text: '$title: ',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

String ledgerTypeTitle(LedgerType type) {
  switch (type) {
    case LedgerType.client:
      return 'عميل';
    case LedgerType.vendor:
      return 'مورد';
    case LedgerType.worker:
      return 'عامل';
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

String formatAmount(
  double amount, {
  required bool arabicDigits,
}) {
  final bool negative = amount.isNegative;
  final String source = amount.abs().toStringAsFixed(0);
  final StringBuffer result = StringBuffer();

  for (int index = 0; index < source.length; index++) {
    final int remaining = source.length - index;

    result.write(source[index]);

    if (remaining > 1 && remaining % 3 == 1) {
      result.write(',');
    }
  }

  final String formatted = negative ? '-$result' : result.toString();

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

  return value.split('').map((String char) => digits[char] ?? char).join();
}

// This function requires a strict, non-null String.
// The caller always uses: entry.phone ?? ''.
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
