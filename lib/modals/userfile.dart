class UserProfile {
  final String email;
  final String name;
  // Add other necessary fields

  UserProfile({
    required this.email,
    required this.name,
    // Add other necessary fields
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      // Add other necessary fields
    };
  }
}
