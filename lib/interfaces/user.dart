class User {
  String? id;
  String email;
  String userName;
  String role;
  String bio;
  String profilPicture;
  String? stripeCustomerId;
  BigInt subscriptionPrice;
  DateTime? emailVerifiedAt;
  String firstName;
  String lastName;
  DateTime birthDayDate;
  String sexe;

  User({
    required this.email,
    required this.userName,
    required this.role,
    required this.bio,
    required this.profilPicture,
    required this.subscriptionPrice,
    required this.firstName,
    required this.lastName,
    required this.birthDayDate,
    required this.sexe,
    this.stripeCustomerId,
    this.emailVerifiedAt,
    this.id
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      userName: json['userName'],
      role: json['role'],
      bio: json['bio'],
      profilPicture: json['profilPicture'] ?? "",
      stripeCustomerId: json['stripeCustomerId'],
      subscriptionPrice: BigInt.parse(json["subscriptionPrice"].toString()),
      firstName: json['firstName'],
      lastName: json['lastName'],
      birthDayDate: DateTime.parse(json["birthDayDate"]),
      sexe: json['sexe'],
    );
  }
}
