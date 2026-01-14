class WalletModel {
  final String id;
  final UserModel user;
  final double balance;
  final double totalEarned;
  final double totalSpent;
  final List<TransactionModel> transactions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.user,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.transactions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['_id'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      balance: (json['balance'] ?? 0).toDouble(),
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      transactions: (json['transactions'] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

class TransactionModel {
  final String user;
  final String type; // 'credit' or 'debit'
  final double amount;
  final double balanceAfter;
  final String status;
  final String description;
  final String referenceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.user,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.status,
    required this.description,
    required this.referenceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      user: json['user'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      referenceId: json['referenceId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
