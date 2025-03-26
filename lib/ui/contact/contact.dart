import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:contact_app_qbeep/ui/contact/bloc/contact_bloc.dart';
import 'package:contact_app_qbeep/ui/contact/profile.dart';
import 'package:contact_app_qbeep/ui/contact/widgets/slideable_contact.dart';
import 'package:contact_app_qbeep/utils/cubit/generic_cubit.dart';
import 'package:contact_app_qbeep/utils/enum/selection_enum.dart';
import 'package:contact_app_qbeep/utils/singleton/app_color.dart';
import 'package:contact_app_qbeep/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppDefault.themeColor,
    );
  }

  @override
  Size get preferredSize => const Size(0.0, 0.0);
}

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            slideFromRightRoute(
              BlocProvider<ContactBloc>.value(
                value: context.read<ContactBloc>(),
                child: Profile(
                  userContact: UserContact.initial(),
                  isEdit: true,
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: AppDefault.themeColor,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ContactBloc, ContactState>(
            listener: (context, state) {
              const snackBar = SnackBar(content: Text('Contact Deleted'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            listenWhen: (previous, current) =>
                previous.userContact.length > current.userContact.length,
          ),
          BlocListener<ContactBloc, ContactState>(
            listener: (context, state) {
              const snackBar = SnackBar(content: Text('Contact Added'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            listenWhen: (previous, current) =>
                previous.userContact.length < current.userContact.length,
          ),
        ],
        child: SafeArea(
          child: BlocProvider<GenericCubit<SelectionEnum>>(
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
                              centerTitle: true,
                              backgroundColor: AppDefault.themeColor,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () => context
                                            .read<GenericCubit<SelectionEnum>>()
                                            .updateValue(SelectionEnum.all),
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // Adjust the radius as needed
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          foregroundColor:
                                              genericState == SelectionEnum.all
                                                  ? Colors.white
                                                  : Colors.black,
                                          backgroundColor:
                                              genericState == SelectionEnum.all
                                                  ? AppDefault.themeColor
                                                  : Colors.transparent,
                                        ),
                                        child: const Text('All'),
                                      ),
                                      const SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () => context
                                            .read<GenericCubit<SelectionEnum>>()
                                            .updateValue(
                                                SelectionEnum.favourite),
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // Adjust the radius as needed
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          foregroundColor: genericState ==
                                                  SelectionEnum.favourite
                                              ? Colors.white
                                              : Colors.black,
                                          backgroundColor: genericState ==
                                                  SelectionEnum.favourite
                                              ? AppDefault.themeColor
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
                                              AppDefault.themeColor,
                                          foregroundColor: Colors.white,
                                          icon: filteredContacts[index]
                                                  .isFavourite
                                              ? Icons.star
                                              : Icons.star_border,
                                          label: 'Favourite',
                                        ),
                                      ],
                                    ),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (_) {
                                            Navigator.of(context).push(
                                              slideFromRightRoute(
                                                BlocProvider<ContactBloc>.value(
                                                  value: context
                                                      .read<ContactBloc>(),
                                                  child: Profile(
                                                    userContact:
                                                        filteredContacts[index],
                                                    isEdit: true,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          backgroundColor:
                                              AppDefault.themeColor,
                                          foregroundColor: Colors.white,
                                          icon: Icons.edit_outlined,
                                          label: 'Edit',
                                        ),
                                        SlidableAction(
                                          onPressed: (_) => showCustomDialog(
                                            message:
                                                'This action cannot be undone.',
                                            context: context,
                                            title:
                                                'Are you sure you want to delete “${filteredContacts[index].firstName} ${filteredContacts[index].lastName} ” from your contact?',
                                            actions: (dialogContext) => [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  context
                                                      .read<ContactBloc>()
                                                      .add(
                                                        DeleteContact(
                                                            contactId:
                                                                filteredContacts[
                                                                        index]
                                                                    .id),
                                                      );
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                          backgroundColor:
                                              AppDefault.themeColor,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete_outline,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: SlideableContact(
                                      userContact: filteredContacts[index],
                                      contactBloc: context.read<ContactBloc>(),
                                    ),
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
    );
  }
}
