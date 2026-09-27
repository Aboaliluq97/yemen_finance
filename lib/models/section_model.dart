class SectionModel {
  SectionModel({
    required this.id,
    required this.accountId,
    required this.name,
    required this.currency,
    required this.colorValue,
    required this.iconCodePoint,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.openingBalance = 0.0,
    this.isArchived = false,
  });

  // معرف فريد للقسم.
  final String id;

  // القسم مرتبط بحساب معين.
  // مثال: القسم "المبيعات" تابع لحساب "متجر الملابس".
  final String accountId;

  // اسم القسم كما يكتبه المستخدم.
  // مثال: صندوق البيت، السيارة، المبيعات، الإيجار.
  String name;

  // عملة القسم: YER أو SAR أو USD.
  String currency;

  // وصف القسم أو الهدف منه.
  String description;

  // لون بطاقة القسم.
  // نخزنه كرقم لأن SQLite لا تحفظ Color مباشرة.
  int colorValue;

  // أيقونة القسم.
  // نخزن codePoint لأن SQLite لا تحفظ IconData مباشرة.
  int iconCodePoint;

  // الرصيد الافتتاحي للقسم.
  // كل المبالغ المالية تستخدم double.
  double openingBalance;

  // أرشفة القسم بدل حذفه.
  bool isArchived;

  // وقت إنشاء القسم.
  String createdAt;

  // آخر وقت تعديل للقسم.
  String updatedAt;

  SectionModel copyWith({
    String? name,
    String? currency,
    String? description,
    int? colorValue,
    int? iconCodePoint,
    double? openingBalance,
    bool? isArchived,
    String? updatedAt,
  }) {
    return SectionModel(
      id: id,
      accountId: accountId,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      openingBalance: openingBalance ?? this.openingBalance,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // تحويل القسم إلى Map قبل حفظه في SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'account_id': accountId,
      'name': name,
      'currency': currency,
      'description': description,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
      'opening_balance': openingBalance,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // قراءة القسم من SQLite وتحويله إلى SectionModel.
  factory SectionModel.fromMap(Map<String, dynamic> map) {
    return SectionModel(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      name: map['name'] as String,
      currency: map['currency'] as String? ?? 'YER',
      description: map['description'] as String? ?? '',
      colorValue:
          (map['color_value'] as num?)?.toInt() ?? 0xFF00695C,
      iconCodePoint:
          (map['icon_code_point'] as num?)?.toInt() ?? 0xe8b6,
      openingBalance:
          (map['opening_balance'] as num?)?.toDouble() ?? 0.0,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
