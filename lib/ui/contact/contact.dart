import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:contact_app_qbeep/ui/contact/bloc/contact_bloc.dart';
import 'package:contact_app_qbeep/ui/contact/widgets/slideable_contact.dart';
import 'package:contact_app_qbeep/utils/cubit/generic_cubit.dart';
import 'package:contact_app_qbeep/utils/enum/selection_enum.dart';
import 'package:contact_app_qbeep/utils/singleton/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.themeColor,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (light background)
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: MultiBlocListener(
          listeners: [
            BlocListener<ContactBloc, ContactState>(
              listener: (context, state) {
                // User contact gets deleted
              },
              listenWhen: (previous, current) =>
                  previous.userContact.length > current.userContact.length,
            ),
            BlocListener<ContactBloc, ContactState>(
              listener: (context, state) {
                // User contact gets added
              },
              listenWhen: (previous, current) =>
                  previous.userContact.length < current.userContact.length,
            ),
          ],
          child: SafeArea(
            child: BlocProvider(
              create: (_) => GenericCubit<SelectionEnum>(SelectionEnum.all),
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  if (state.contactStatus == ContactStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else if (state.contactStatus == ContactStatus.completed) {
                    return BlocBuilder<GenericCubit<SelectionEnum>,
                        SelectionEnum>(
                      builder: (context, genericState) {
                        List<UserContact> filteredContacts =
                            genericState == SelectionEnum.all
                                ? state.userContact
                                : state.userContact
                                    .where((e) => e.isFavourite)
                                    .toList();

                        return NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return [
                              SliverAppBar(
                                backgroundColor: AppColor.themeColor,
                                title: const Text(
                                  'My Contacts',
                                  style: TextStyle(color: Colors.white),
                                ),
                                floating: true,
                                pinned: true,
                                bottom: PreferredSize(
                                  preferredSize: const Size.fromHeight(40),
                                  child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 10),
                                        TextButton(
                                          onPressed: () => context
                                              .read<
                                                  GenericCubit<SelectionEnum>>()
                                              .updateValue(SelectionEnum.all),
                                          style: TextButton.styleFrom(
                                            visualDensity:
                                                VisualDensity.compact,
                                            foregroundColor: genericState ==
                                                    SelectionEnum.all
                                                ? Colors.white
                                                : Colors.black,
                                            backgroundColor: genericState ==
                                                    SelectionEnum.all
                                                ? AppColor.themeColor
                                                : Colors.transparent,
                                          ),
                                          child: const Text('All'),
                                        ),
                                        const SizedBox(width: 10),
                                        TextButton(
                                          onPressed: () => context
                                              .read<
                                                  GenericCubit<SelectionEnum>>()
                                              .updateValue(
                                                  SelectionEnum.favourite),
                                          style: TextButton.styleFrom(
                                            visualDensity:
                                                VisualDensity.compact,
                                            foregroundColor: genericState ==
                                                    SelectionEnum.favourite
                                                ? Colors.white
                                                : Colors.black,
                                            backgroundColor: genericState ==
                                                    SelectionEnum.favourite
                                                ? AppColor.themeColor
                                                : Colors.transparent,
                                          ),
                                          child: const Text('Favourite'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          },
                          body: filteredContacts.isEmpty
                              ? Center(
                                  child: Text(
                                      'No ${genericState == SelectionEnum.favourite ? 'Favourited' : ''} Contact'),
                                )
                              : ListView.builder(
                                  itemCount: filteredContacts.length,
                                  itemBuilder: (context, index) {
                                    return Slidable(
                                      key: ValueKey(filteredContacts[index].id),
                                      startActionPane: ActionPane(
                                        extentRatio: 0.3,
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              context.read<ContactBloc>().add(
                                                    FavouriteContact(
                                                        contactId:
                                                            filteredContacts[
                                                                    index]
                                                                .id),
                                                  );
                                            },
                                            backgroundColor:
                                                AppColor.themeColor,
                                            foregroundColor: Colors.white,
                                            icon: Icons.star,
                                            label: 'Favourite',
                                          ),
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          const SlidableAction(
                                            onPressed: null,
                                            backgroundColor:
                                                AppColor.themeColor,
                                            foregroundColor: Colors.white,
                                            icon: Icons.edit_outlined,
                                            label: 'Edit',
                                          ),
                                          SlidableAction(
                                            onPressed: (context) {
                                              context.read<ContactBloc>().add(
                                                    DeleteContact(
                                                        contactId:
                                                            filteredContacts[
                                                                    index]
                                                                .id),
                                                  );
                                            },
                                            backgroundColor:
                                                AppColor.themeColor,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete_outline,
                                            label: 'Delete',
                                          ),
                                        ],
                                      ),
                                      child: SlideableContact(
                                          userContact: filteredContacts[index]),
                                    );
                                  },
                                ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: Text(state.errorMessage),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
