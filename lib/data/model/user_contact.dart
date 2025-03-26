import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_contact.freezed.dart';
part 'user_contact.g.dart';

@freezed
class UserContact with _$UserContact {
  factory UserContact({
    required int id,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String avatar,
    @Default(false) bool isFavourite,
  }) = _UserContact;

  factory UserContact.initial() => UserContact(
        id: 0,
        email: '',
        firstName: '',
        lastName: '',
        avatar: '',
      );

  factory UserContact.fromJson(Map<String, dynamic> json) =>
      _$UserContactFromJson(json);
}
