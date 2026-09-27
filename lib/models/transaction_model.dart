class TransactionModel {
  TransactionModel({
    required this.id,
    required this.accountId,
    required this.sectionId,
    required this.title,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    required this.createdAt,
    this.category = '',
    this.counterparty = '',
    this.location = '',
    this.reason = '',
    this.paymentMethod = '',
    this.referenceNumber = '',
    this.notes = '',
    this.labels = '',
    this.linkedTransactionId,
    this.attachmentPath,
  });

  // معرف فريد للعملية.
  final String id;

  // الحساب الرئيسي الذي تتبع له العملية.
  // مثال: حسابي الشخصي، متجر الملابس، مشروع البناء.
  final String accountId;

  // القسم الذي تمت العملية داخله.
  // مثال: صندوق البيت، السيارة، شراء البضاعة.
  final String sectionId;

  // عنوان العملية.
  // مثال: شراء مواد غذائية، راتب شهر سبتمبر، بيع بضاعة.
  String title;

  // income / expense / transfer_out / transfer_in /
  // debt_payment / salary_payment / inventory_sale / inventory_purchase.
  String transactionType;

  // كل المبالغ المالية double.
  double amount;

  // YER أو SAR أو USD.
  String currency;

  // تصنيف العملية.
  // مثال: غذاء، إيجار، علاج، تجارة، مواصلات، رواتب.
  String category;

  // الشخص أو الجهة المقابلة.
  // مثال: أحمد محمد، سوبرماركت السعيدة، شركة الكهرباء.
  String counterparty;

  // مكان حدوث العملية.
  // مثال: صنعاء - شارع الزبيري.
  String location;

  // سبب العملية.
  // مثال: احتياجات منزلية أسبوعية.
  String reason;

  // طريقة الدفع أو الاستلام.
  // نقدًا، تحويل بنكي، حوالة، آجل، بطاقة، واتساب.
  String paymentMethod;

  // رقم فاتورة، حوالة، أو مرجع داخلي.
  String referenceNumber;

  // ملاحظات مفصلة.
  String notes;

  // وسوم مفصولة بفاصلة.
  // مثال: منزل,ضروري,شهري
  String labels;

  // يستخدم في التحويلات الداخلية.
  // يربط عملية التحويل الصادر بعملية التحويل الوارد.
  String? linkedTransactionId;

  // مسار صورة فاتورة أو إيصال، يضاف لاحقًا.
  String? attachmentPath;

  // التاريخ الذي حدثت فيه العملية.
  // نخزنه كنص ISO ليسهل حفظه في SQLite.
  String transactionDate;

  // وقت إنشاء السجل داخل التطبيق.
  String createdAt;

  TransactionModel copyWith({
    String? title,
    String? transactionType,
    double? amount,
    String? currency,
    String? category,
    String? counterparty,
    String? location,
    String? reason,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    String? labels,
    String? linkedTransactionId,
    String? attachmentPath,
    String? transactionDate,
  }) {
    return TransactionModel(
      id: id,
      accountId: accountId,
      sectionId: sectionId,
      title: title ?? this.title,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      counterparty: counterparty ?? this.counterparty,
      location: location ?? this.location,
      reason: reason ?? this.reason,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      labels: labels ?? this.labels,
      linkedTransactionId:
          linkedTransactionId ?? this.linkedTransactionId,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'account_id': accountId,
      'section_id': sectionId,
      'title': title,
      'transaction_type': transactionType,
      'amount': amount,
      'currency': currency,
      'category': category,
      'counterparty': counterparty,
      'location': location,
      'reason': reason,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'notes': notes,
      'labels': labels,
      'transaction_date': transactionDate,
      'created_at': createdAt,
      'linked_transaction_id': linkedTransactionId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      sectionId: map['section_id'] as String,
      title: map['title'] as String,
      transactionType: map['transaction_type'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'YER',
      category: map['category'] as String? ?? '',
      counterparty: map['counterparty'] as String? ?? '',
      location: map['location'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      paymentMethod: map['payment_method'] as String? ?? '',
      referenceNumber: map['reference_number'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      labels: map['labels'] as String? ?? '',
      transactionDate: map['transaction_date'] as String,
      createdAt: map['created_at'] as String,
      linkedTransactionId: map['linked_transaction_id'] as String?,
    );
  }

  bool get isIncome {
    return transactionType == 'income' ||
        transactionType == 'transfer_in' ||
        transactionType == 'inventory_sale';
  }

  bool get isExpense {
    return transactionType == 'expense' ||
        transactionType == 'transfer_out' ||
        transactionType == 'inventory_purchase' ||
        transactionType == 'salary_payment';
  }
}
