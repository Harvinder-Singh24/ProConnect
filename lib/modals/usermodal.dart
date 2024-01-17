import 'package:proconnect/modals/userfile.dart';

class UserModel {
  final String email;
  final String name;
  final String address;
  final String birthdate;
  final Map<String, dynamic> customClaims;
  final String familyName;
  final String gender;
  final String givenName;
  final bool isEmailVerified;
  final bool isPhoneNumberVerified;
  final String locale;
  final String pictureUrl;
  final String profileUrl;
  final String websiteUrl;

  UserModel({
    required this.email,
    required this.name,
    required this.address,
    required this.birthdate,
    required this.customClaims,
    required this.familyName,
    required this.gender,
    required this.givenName,
    required this.isEmailVerified,
    required this.isPhoneNumberVerified,
    required this.locale,
    required this.pictureUrl,
    required this.profileUrl,
    required this.websiteUrl,
  });

  factory UserModel.fromDynamic(dynamic data) {
    if (data is Map<String, dynamic>) {
      return UserModel(
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        birthdate: data['birthdate'] ?? '',
        customClaims: data['customClaims'] ?? {},
        familyName: data['familyName'] ?? '',
        gender: data['gender'] ?? '',
        givenName: data['givenName'] ?? '',
        isEmailVerified: data['isEmailVerified'] ?? false,
        isPhoneNumberVerified: data['isPhoneNumberVerified'] ?? false,
        locale: data['locale'] ?? '',
        pictureUrl: data['pictureUrl'] ?? '',
        profileUrl: data['profileUrl'] ?? '',
        websiteUrl: data['websiteUrl'] ?? '',
      );
    } else if (data is UserProfile) {
      // Convert UserProfile to Map<String, dynamic>
      return UserModel.fromDynamic(data.toMap());
    }

    // Handle other cases or return default UserModel
    return UserModel(
      email: '',
      name: '',
      address: '',
      birthdate: '',
      customClaims: {},
      familyName: '',
      gender: '',
      givenName: '',
      isEmailVerified: false,
      isPhoneNumberVerified: false,
      locale: '',
      pictureUrl: '',
      profileUrl: '',
      websiteUrl: '',
    );
  }
  @override
  String toString() {
    return 'UserModel{email: $email, name: $name}';
    // Add other fields if needed
  }
}
