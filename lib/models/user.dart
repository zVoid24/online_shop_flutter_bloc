class UserData {
  final String uid;
  final String name;
  final String email;

  UserData({required this.uid, required this.name, required this.email});

  // Convert UserData to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }

  // Create UserData from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}