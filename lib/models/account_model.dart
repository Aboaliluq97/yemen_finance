class AccountModel {
  AccountModel({
    required this.id,
    required this.name,
    required this.accountType,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.openingBalance = 0.0,
    this.imagePath,
    this.isArchived = false,
  });

  // معرف فريد للحساب.
  final String id;

  // مثال: حسابي الشخصي، متجر الملابس، مشروع البناء.
  String name;

  // شخصي، عائلي، تجاري، مشروع، مجموعة، طفل، ادخار.
  String accountType;

  // YER أو SAR أو USD.
  String currency;

  // وصف الحساب.
  String description;

  // الرصيد الافتتاحي للحساب.
  // كل المبالغ المالية تستخدم double.
  double openingBalance;

  // مسار الصورة الشخصية أو شعار الحساب أو النشاط.
  String? imagePath;

  // بدلاً من حذف الحساب، يمكن أرشفته.
  bool isArchived;

  // وقت إنشاء الحساب.
  String createdAt;

  // آخر وقت تم فيه تعديل الحساب.
  String updatedAt;

  AccountModel copyWith({
    String? name,
    String? accountType,
    String? currency,
    String? description,
    double? openingBalance,
    String? imagePath,
    bool? isArchived,
    String? updatedAt,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      openingBalance: openingBalance ?? this.openingBalance,
      imagePath: imagePath ?? this.imagePath,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // تحويل الحساب إلى Map قبل حفظه داخل SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'account_type': accountType,
      'currency': currency,
      'description': description,
      'opening_balance': openingBalance,
      'image_path': imagePath,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // قراءة الحساب من SQLite وتحويله إلى AccountModel.
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      accountType: map['account_type'] as String,
      currency: map['currency'] as String,
      description: map['description'] as String? ?? '',
      openingBalance:
          (map['opening_balance'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['image_path'] as String?,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
