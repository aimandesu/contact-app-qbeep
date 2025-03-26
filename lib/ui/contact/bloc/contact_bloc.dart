import 'dart:developer';

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
    on<SaveUser>(_saveUser);
    on<UpdateAvatar>(_updateAvatar);
    on<SearchContact>(_searchContact);
  }

  Future<void> _onFetchContacts(
    FetchContacts event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(contactStatus: ContactStatus.loading));

    try {
      final contacts = await contactRepository.getUserContact();

      emit(
        state.copyWith(
          contactStatus: ContactStatus.completed,
          userContact: contacts,
          originalContacts: contacts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          contactStatus: ContactStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onFavouriteContact(
    FavouriteContact event,
    Emitter<ContactState> emit,
  ) {
    // Find and update the contact in the list
    final List<UserContact> contact = state.originalContacts.map((contact) {
      if (contact.id == event.contactId) {
        return contact.copyWith(isFavourite: !contact.isFavourite);
      }
      return contact;
    }).toList();

    emit(
      state.copyWith(
        userContact: contact,
        originalContacts: contact,
      ),
    );
  }

  void _deleteContact(
    DeleteContact event,
    Emitter<ContactState> emit,
  ) {
    final int contactId = event.contactId;

    final updatedContacts = state.originalContacts
        .where(
          (contact) => contact.id != contactId,
        )
        .toList();

    emit(
      state.copyWith(
        userContact: updatedContacts,
        originalContacts: updatedContacts,
      ),
    );
  }

  void _saveUser(SaveUser event, Emitter<ContactState> emit) {
    final updatedList = state.originalContacts.map((contact) {
      return contact.id == event.userContact.id ? event.userContact : contact;
    }).toList();

    // If the contact was not found and replaced, we add it as a new contact.
    if (!updatedList.any((contact) => contact.id == event.userContact.id)) {
      updatedList.add(event.userContact);
    }

    emit(
      state.copyWith(
        userContact: updatedList,
        originalContacts: updatedList,
      ),
    );
  }

  void _updateAvatar(UpdateAvatar event, Emitter<ContactState> emit) {
    final updatedContacts = state.originalContacts.map((contact) {
      if (contact.id == event.contactId) {
        return contact.copyWith(avatar: event.avatarPath);
      }
      return contact;
    }).toList();

    emit(
      state.copyWith(
        userContact: updatedContacts,
        originalContacts: updatedContacts,
      ),
    );
  }

  void _searchContact(
    SearchContact event,
    Emitter<ContactState> emit,
  ) {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(state.copyWith(userContact: state.originalContacts));
      return;
    }

    final filteredContacts = state.originalContacts.where((contact) {
      return contact.firstName.toLowerCase().contains(query) ||
          contact.lastName.toLowerCase().contains(query) ||
          contact.email.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(userContact: filteredContacts));
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
