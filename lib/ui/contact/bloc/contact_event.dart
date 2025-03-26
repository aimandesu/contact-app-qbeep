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
