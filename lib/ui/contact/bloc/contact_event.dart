part of 'contact_bloc.dart';

@immutable
sealed class ContactEvent {}

class FetchContacts extends ContactEvent {}

class FavouriteContact extends ContactEvent {
  FavouriteContact({required this.contactId});
  final int contactId;
}

class DeleteContact extends ContactEvent {
  DeleteContact({required this.contactId});
  final int contactId;
}

class SaveUser extends ContactEvent {
  SaveUser({required this.userContact});
  final UserContact userContact;
}

class UpdateAvatar extends ContactEvent {
  UpdateAvatar({
    required this.contactId,
    required this.avatarPath,
  });
  final int contactId;
  final String avatarPath;
}
