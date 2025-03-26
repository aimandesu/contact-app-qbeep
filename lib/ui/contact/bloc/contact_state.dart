part of 'contact_bloc.dart';

enum ContactStatus {
  initial,
  loading,
  completed,
  error,
}

@freezed
class ContactState with _$ContactState {
  factory ContactState({
    required ContactStatus contactStatus,
    required List<UserContact> userContact,
    required List<UserContact> originalContacts,
    required String errorMessage,
  }) = _ContactState;

  factory ContactState.initial() => ContactState(
        contactStatus: ContactStatus.initial,
        userContact: [],
        originalContacts: [],
        errorMessage: '',
      );

  factory ContactState.fromJson(Map<String, dynamic> json) =>
      _$ContactStateFromJson(json);
}
