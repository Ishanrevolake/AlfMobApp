class ClientProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String goal;
  final String avatarUrl;
  final int streak;
  final int daysLeft;

  const ClientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    required this.role,
    this.status = 'active',
    this.goal = '',
    this.avatarUrl = '',
    this.streak = 0,
    this.daysLeft = 0,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    final firstName = (json['first_name'] ?? '').toString().trim();
    final lastName = (json['last_name'] ?? '').toString().trim();
    final combinedName = '$firstName $lastName'.trim();
    final fullName = (json['full_name'] ?? json['name'] ?? combinedName)
        .toString()
        .trim();

    return ClientProfile(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      fullName: fullName.isEmpty ? 'Client' : fullName,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      role: (json['role'] ?? 'client').toString().toLowerCase(),
      status: (json['status'] ?? 'active').toString().toLowerCase(),
      goal: (json['goal'] ?? json['fitness_goal'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatar'] ?? '').toString(),
      streak: _asInt(json['streak']),
      daysLeft: _asInt(json['days_left'] ?? json['daysLeft']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
