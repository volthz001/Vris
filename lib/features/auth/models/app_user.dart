class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? department; // field "wok" dari backend
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['nama'] ?? json['username'] ?? '',
      email: json['email'] ?? json['username'] ?? '',
      role: json['role'] ?? json['jabatan'] ?? 'SF',
      department: json['wok'] ?? json['area'] ?? json['divisi'],
      avatarUrl: json['avatar_url'],
    );
  }

  // Role sesuai RBAC MCP-HRIS
  String get roleLabel {
    switch (role) {
      case 'VP':
        return 'Vice President';
      case 'GML':
        return 'General Manager';
      case 'Manager WOK':
        return 'Manager WOK';
      case 'TL':
        return 'Team Leader';
      case 'SF':
        return 'Sales Force';
      default:
        return role; // fallback tampilkan apa adanya
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
