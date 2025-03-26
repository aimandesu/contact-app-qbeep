import 'package:bloc/bloc.dart';
import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:contact_app_qbeep/data/repositories/contact_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'contact_bloc.freezed.dart';
part 'contact_bloc.g.dart';
part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends HydratedBloc<ContactEvent, ContactState> {
  final ContactRepository contactRepository;

  ContactBloc({required this.contactRepository})
      : super(ContactState.initial()) {
    on<FetchContacts>(_onFetchContacts);
    on<FavouriteContact>(_onFavouriteContact);
    on<DeleteContact>(_deleteContact);
  }

  Future<void> _onFetchContacts(
    FetchContacts event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(contactStatus: ContactStatus.loading));

    try {
      final contacts = await contactRepository.getUserContact();

      emit(state.copyWith(
        contactStatus: ContactStatus.completed,
        userContact: contacts,
      ));
    } catch (e) {
      emit(state.copyWith(
        contactStatus: ContactStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFavouriteContact(
    FavouriteContact event,
    Emitter<ContactState> emit,
  ) {
    // Find and update the contact in the list
    final List<UserContact> contact = state.userContact.map((contact) {
      if (contact.id == event.contactId) {
        return contact.copyWith(isFavourite: !contact.isFavourite);
      }
      return contact;
    }).toList();

    emit(state.copyWith(userContact: contact));
  }

  void _deleteContact(
    DeleteContact event,
    Emitter<ContactState> emit,
  ) {
    final int contactId = event.contactId;

    final updatedContacts = state.userContact
        .where(
          (contact) => contact.id != contactId,
        )
        .toList();

    emit(
      state.copyWith(
        userContact: updatedContacts,
      ),
    );
  }

  @override
  ContactState? fromJson(Map<String, dynamic> json) {
    try {
      return ContactState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ContactState state) {
    return state.toJson();
  }
}
