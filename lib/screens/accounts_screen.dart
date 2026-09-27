import 'package:flutter/material.dart';

import '../models/account_model.dart';
import '../repositories/account_repository.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({
    super.key,
    required this.onOpenAccount,
  });

  final ValueChanged<AccountModel> onOpenAccount;

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountRepository _repository = AccountRepository.instance;

  bool _isLoading = true;

  List<AccountModel> _accounts = <AccountModel>[];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<AccountModel> accounts =
          await _repository.getAllAccounts();

      if (!mounted) {
        return;
      }

      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'تعذر تحميل الحسابات: $error',
        isError: true,
      );
    }
  }

  Future<void> _showCreateAccountDialog() async {
    final TextEditingController nameController =
        TextEditingController();

    final TextEditingController descriptionController =
        TextEditingController();

    final TextEditingController openingBalanceController =
        TextEditingController(text: '0');

    String selectedType = 'شخصي';
    String selectedCurrency = 'YER';

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title: const Text('إنشاء حساب جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحساب',
                        hintText: 'مثال: متجر الملابس أو حسابي الشخصي',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الحساب',
                      ),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'شخصي',
                          child: Text('شخصي'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'عائلي',
                          child: Text('عائلي'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'تجاري',
                          child: Text('تجاري'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'مشروع',
                          child: Text('مشروع'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'مجموعة',
                          child: Text('مجموعة أو جمعية'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'طفل',
                          child: Text('حساب طفل'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'ادخار',
                          child: Text('ادخار'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'العملة الرئيسية',
                      ),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'YER',
                          child: Text('ريال يمني — YER'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'SAR',
                          child: Text('ريال سعودي — SAR'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'USD',
                          child: Text('دولار أمريكي — USD'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCurrency = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: openingBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'الرصيد الافتتاحي',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'وصف الحساب',
                        hintText: 'مثال: حساب خاص بإدارة متجر الملابس',
                      ),
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
                    final String name = nameController.text.trim();

                    final double? openingBalance = double.tryParse(
                      openingBalanceController.text
                          .trim()
                          .replaceAll(',', '')
                          .replaceAll('٬', '')
                          .replaceAll('٫', '.'),
                    );

                    if (name.isEmpty) {
                      _showMessage(
                        'اكتب اسم الحساب.',
                        isError: true,
                      );
                      return;
                    }

                    if (openingBalance == null ||
                        !openingBalance.isFinite ||
                        openingBalance < 0.0) {
                      _showMessage(
                        'أدخل رصيدًا افتتاحيًا صالحًا.',
                        isError: true,
                      );
                      return;
                    }

                    final DateTime now = DateTime.now();

                    final AccountModel account = AccountModel(
                      id: now.microsecondsSinceEpoch.toString(),
                      name: name,
                      accountType: selectedType,
                      currency: selectedCurrency,
                      description: descriptionController.text.trim(),
                      openingBalance: openingBalance,
                      createdAt: now.toIso8601String(),
                      updatedAt: now.toIso8601String(),
                    );

                    try {
                      await _repository.createAccount(account);

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(dialogContext);

                      await _loadAccounts();

                      _showMessage(
                        'تم إنشاء الحساب وحفظه بنجاح.',
                      );
                    } catch (error) {
                      _showMessage(
                        'تعذر حفظ الحساب: $error',
                        isError: true,
                      );
                    }
                  },
                  child: const Text('إنشاء الحساب'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    openingBalanceController.dispose();
  }

  Future<void> _showEditAccountDialog(
    AccountModel account,
  ) async {
    final TextEditingController nameController =
        TextEditingController(text: account.name);

    final TextEditingController descriptionController =
        TextEditingController(text: account.description);

    final TextEditingController openingBalanceController =
        TextEditingController(
      text: account.openingBalance.toString(),
    );

    String selectedType = account.accountType;
    String selectedCurrency = account.currency;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title: const Text('تعديل الحساب'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحساب',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الحساب',
                      ),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'شخصي',
                          child: Text('شخصي'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'عائلي',
                          child: Text('عائلي'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'تجاري',
                          child: Text('تجاري'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'مشروع',
                          child: Text('مشروع'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'مجموعة',
                          child: Text('مجموعة أو جمعية'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'طفل',
                          child: Text('حساب طفل'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'ادخار',
                          child: Text('ادخار'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'العملة الرئيسية',
                      ),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'YER',
                          child: Text('ريال يمني — YER'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'SAR',
                          child: Text('ريال سعودي — SAR'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'USD',
                          child: Text('دولار أمريكي — USD'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCurrency = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: openingBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'الرصيد الافتتاحي',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'الوصف',
                      ),
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
                    final String name = nameController.text.trim();

                    final double? openingBalance = double.tryParse(
                      openingBalanceController.text
                          .trim()
                          .replaceAll(',', '')
                          .replaceAll('٬', '')
                          .replaceAll('٫', '.'),
                    );

                    if (name.isEmpty) {
                      _showMessage(
                        'اكتب اسم الحساب.',
                        isError: true,
                      );
                      return;
                    }

                    if (openingBalance == null ||
                        !openingBalance.isFinite ||
                        openingBalance < 0.0) {
                      _showMessage(
                        'الرصيد الافتتاحي غير صالح.',
                        isError: true,
                      );
                      return;
                    }

                    final AccountModel updatedAccount =
                        account.copyWith(
                      name: name,
                      accountType: selectedType,
                      currency: selectedCurrency,
                      description: descriptionController.text.trim(),
                      openingBalance: openingBalance,
                      updatedAt:
                          DateTime.now().toIso8601String(),
                    );

                    try {
                      await _repository.updateAccount(
                        updatedAccount,
                      );

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(dialogContext);

                      await _loadAccounts();

                      _showMessage(
                        'تم تحديث الحساب بنجاح.',
                      );
                    } catch (error) {
                      _showMessage(
                        'تعذر تعديل الحساب: $error',
                        isError: true,
                      );
                    }
                  },
                  child: const Text('حفظ التعديل'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    openingBalanceController.dispose();
  }

  Future<void> _archiveAccount(
    AccountModel account,
  ) async {
    try {
      await _repository.archiveAccount(
        accountId: account.id,
        isArchived: true,
      );

      await _loadAccounts();

      _showMessage(
        'تمت أرشفة الحساب. يمكنك إعادته لاحقًا.',
      );
    } catch (error) {
      _showMessage(
        'تعذر أرشفة الحساب: $error',
        isError: true,
      );
    }
  }

  void _showAccountMenu(AccountModel account) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded),
                title: const Text('فتح الحساب'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.onOpenAccount(account);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('تعديل الحساب'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditAccountDialog(account);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.archive_rounded,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'أرشفة الحساب',
                  style: TextStyle(
                    color: AppColors.danger,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _archiveAccount(account);
                },
              ),
            ],
          ),
        );
      },
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAccountDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('حساب جديد'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAccounts,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _accounts.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: const <Widget>[
                        SizedBox(height: 110),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 72,
                          color: AppColors.muted,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'لا توجد حسابات بعد',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'أنشئ حسابًا شخصيًا أو تجاريًا أو عائليًا، ثم أضف داخله أقسامك وعملياتك المالية.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        110,
                      ),
                      itemCount: _accounts.length + 1,
                      itemBuilder: (
                        BuildContext context,
                        int index,
                      ) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'حساباتي',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'اختر حسابًا لإدارة الأقسام والعمليات.',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final AccountModel account =
                            _accounts[index - 1];

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: Card(
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                widget.onOpenAccount(account);
                              },
                              onLongPress: () {
                                _showAccountMenu(account);
                              },
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppColors.emerald
                                      .withValues(alpha: 0.14),
                                  foregroundColor:
                                      AppColors.emerald,
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                  ),
                                ),
                                title: Text(
                                  account.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                  ),
                                  child: Text(
                                    '${account.accountType} • ${account.currency}\n${account.description.isEmpty ? 'بدون وصف' : account.description}',
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      formatAmount(
                                        account.openingBalance,
                                        arabicDigits: false,
                                      ),
                                      style: const TextStyle(
                                        color: AppColors.emerald,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Text(
                                      'رصيد افتتاحي',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
