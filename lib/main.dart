import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BudgetWalletApp());
}

class BudgetWalletApp extends StatelessWidget {
  const BudgetWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00695C);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الموازنة والمحفظة',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: DashboardPage(),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String whatsappNumber = '967777123456';

  final List<TransactionData> _transactions = [
    const TransactionData(
      title: 'إيداع راتب',
      category: 'دخل',
      date: '24 يونيو 2023',
      amount: 150000,
      isIncome: true,
      icon: Icons.work_rounded,
    ),
    const TransactionData(
      title: 'سوبر ماركت السعيدة',
      category: 'تسوق',
      date: '23 يونيو 2023',
      amount: 12500,
      isIncome: false,
      icon: Icons.shopping_cart_rounded,
    ),
    const TransactionData(
      title: 'فاتورة الكهرباء',
      category: 'خدمات',
      date: '22 يونيو 2023',
      amount: 8200,
      isIncome: false,
      icon: Icons.electric_bolt_rounded,
    ),
    const TransactionData(
      title: 'تحويل مالي',
      category: 'إضافي',
      date: '20 يونيو 2023',
      amount: 45000,
      isIncome: true,
      icon: Icons.swap_horiz_rounded,
    ),
  ];

  double get _totalIncome {
    return _transactions
        .where((transaction) => transaction.isIncome)
        .fold(655000, (sum, transaction) => sum + transaction.amount);
  }

  double get _totalExpenses {
    return _transactions
        .where((transaction) => !transaction.isIncome)
        .fold(378550, (sum, transaction) => sum + transaction.amount);
  }

  double get _balance => _totalIncome - _totalExpenses;

  String _formatAmount(num amount) {
    final String value = amount.toStringAsFixed(0);
    final StringBuffer formatted = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      final int remaining = value.length - index;

      formatted.write(value[index]);

      if (remaining > 1 && remaining % 3 == 1) {
        formatted.write(',');
      }
    }

    return formatted.toString();
  }

  String _amountInWords() {
    return 'رصيدك الحالي بعد احتساب الإيرادات والمصروفات';
  }

  Future<void> _shareOnWhatsApp() async {
    final String message = '''
ملخص الموازنة والمحفظة:

الرصيد المتبقي: ${_formatAmount(_balance)} ريال يمني
إجمالي الدخل: ${_formatAmount(_totalIncome)} ريال يمني
إجمالي المصروفات: ${_formatAmount(_totalExpenses)} ريال يمني

صُنع بواسطة ABOALILUQMAN — أبو علي لقمان
''';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}',
    );

    final bool opened = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح واتساب. تأكد من تثبيت التطبيق وصحة رقم الهاتف.',
          ),
        ),
      );
    }
  }

  Future<void> _showAddTransactionDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    bool isIncome = true;
    IconData selectedIcon = Icons.account_balance_wallet_rounded;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('إضافة عملية جديدة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'اسم العملية',
                        hintText: 'مثال: راتب أو فاتورة مياه',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: amountController,
                      textDirection: TextDirection.rtl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'المبلغ بالريال اليمني',
                        hintText: 'مثال: 50000',
                        suffixText: 'ر.ي',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isIncome ? 'نوع العملية: دخل' : 'نوع العملية: مصروف',
                      ),
                      secondary: Icon(
                        isIncome
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      value: isIncome,
                      onChanged: (bool value) {
                        setDialogState(() {
                          isIncome = value;
                          selectedIcon = value
                              ? Icons.account_balance_wallet_rounded
                              : Icons.shopping_bag_rounded;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String title = titleController.text.trim();
                    final String enteredAmount = amountController.text
                        .replaceAll(',', '')
                        .replaceAll('٬', '')
                        .trim();

                    final double? amount = double.tryParse(enteredAmount);

                    if (title.isEmpty || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'يرجى إدخال اسم العملية ومبلغ صحيح أكبر من صفر.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _transactions.insert(
                        0,
                        TransactionData(
                          title: title,
                          category: isIncome ? 'دخل' : 'مصروفات',
                          date: 'اليوم',
                          amount: amount,
                          isIncome: isIncome,
                          icon: selectedIcon,
                        ),
                      );
                    });

                    Navigator.of(dialogContext).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تمت إضافة العملية بنجاح.'),
                      ),
                    );
                  },
                  child: const Text('حفظ العملية'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
  }

  void _showAllTransactions() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (BuildContext context, ScrollController controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'كل العمليات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _transactions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int index) {
                          return TransactionTile(
                            transaction: _transactions[index],
                            formatAmount: _formatAmount,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00695C);
    const Color darkPrimaryColor = Color(0xFF004D40);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        backgroundColor: const Color(0xFFE6B800),
        foregroundColor: Colors.black87,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'إضافة عملية',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, darkPrimaryColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -20,
                      bottom: -28,
                      child: Transform.rotate(
                        angle: -0.25,
                        child: const Icon(
                          Icons.payments_rounded,
                          size: 165,
                          color: Color(0x22FFFFFF),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الرصيد المتبقي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '${_formatAmount(_balance)} ر.ي',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _amountInWords(),
                          style: const TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x26FFFFFF),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '+2.5% هذا الشهر',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'إجمالي الدخل',
                      amount: _formatAmount(_totalIncome),
                      color: Colors.green.shade700,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MetricCard(
                      label: 'إجمالي المصروفات',
                      amount: _formatAmount(_totalExpenses),
                      color: Colors.red.shade700,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              RevenueChart(
                primaryColor: primaryColor,
                formatAmount: _formatAmount,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'آخر العمليات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _showAllTransactions,
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ..._transactions.take(4).map(
                    (TransactionData transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionTile(
                        transaction: transaction,
                        formatAmount: _formatAmount,
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _shareOnWhatsApp,
                icon: const Icon(Icons.share_rounded),
                label: const Text('مشاركة عبر واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                '© ${DateTime.now().year} جميع الحقوق محفوظة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'صُنع بواسطة ABOALILUQMAN — أبو علي لقمان',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الموازنة والمحفظة',
              style: TextStyle(
                color: Color(0xFF00695C),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'لوحة التحكم المالية',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFF00695C),
          child: Text(
            'MA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$amount ر.ي',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueChart extends StatelessWidget {
  const RevenueChart({
    super.key,
    required this.primaryColor,
    required this.formatAmount,
  });

  final Color primaryColor;
  final String Function(num) formatAmount;

  @override
  Widget build(BuildContext context) {
    const List<double> values = [120, 150, 110, 180, 210, 190];
    const List<String> months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
    ];

    const double maximumValue = 220;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإيرادات vs المصروفات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  avatar: Icon(Icons.check_rounded, size: 16),
                  label: Text('آخر 6 أشهر'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(values.length, (int index) {
                  final double barHeight = (values[index] / maximumValue) * 125;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${values[index].toInt()}K',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            months[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تمثيل مبسط للإيرادات الشهرية بالآلاف.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.formatAmount,
  });

  final TransactionData transaction;
  final String Function(num) formatAmount;

  @override
  Widget build(BuildContext context) {
    final Color amountColor =
        transaction.isIncome ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE6F2F0),
          child: Icon(
            transaction.icon,
            color: const Color(0xFF00695C),
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${transaction.category} • ${transaction.date}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}${formatAmount(transaction.amount)}',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ر.ي',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionData {
  const TransactionData({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });

  final String title;
  final String category;
  final String date;
  final double amount;
  final bool isIncome;
  final IconData icon;
}
