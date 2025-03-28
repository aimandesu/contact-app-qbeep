import 'dart:developer';
import 'dart:io';

import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:contact_app_qbeep/ui/contact/bloc/contact_bloc.dart';
import 'package:contact_app_qbeep/utils/cubit/generic_cubit.dart';
import 'package:contact_app_qbeep/utils/singleton/app_color.dart';
import 'package:contact_app_qbeep/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Profile extends StatefulWidget {
  final UserContact userContact;
  final bool isEdit;

  const Profile({
    super.key,
    required this.userContact,
    this.isEdit = false,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  late int newId;

  @override
  void initState() {
    firstNameController.text = widget.userContact.firstName;
    lastNameController.text = widget.userContact.lastName;
    emailController.text = widget.userContact.email;
    generateNewId();
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void generateNewId() {
    List<int> excluded = [
      ...context.read<ContactBloc>().state.userContact.map((e) => e.id)
    ];
    newId = getRandomIntExcluding(excluded, min: 1, max: 50);
  }

  void discardProfile() {
    showCustomDialog(
      message: 'This action cannot be undone.',
      context: context,
      title: 'Are you sure you want to discard changes?',
      actions: (dialogContext) => [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<ContactBloc>().add(ResetOriginalContact());
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Discard'),
        ),
      ],
    );
  }

  UserContact getSelectedContact(ContactState state) {
    return state.userContact.firstWhere(
      (e) =>
          e.id == (widget.userContact.id == 0 ? newId : widget.userContact.id),
      orElse: () => UserContact.initial(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GenericCubit<bool>>(
      create: (context) => GenericCubit<bool>(widget.isEdit),
      child: BlocBuilder<GenericCubit<bool>, bool>(
        builder: (context, genericState) {
          return PopScope(
            canPop: !genericState,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                log('Profile screen. Pop out.');
              } else {
                discardProfile();
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: AppDefault.themeColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    if (context
                                .read<ContactBloc>()
                                .state
                                .originalContacts
                                .length !=
                            context
                                .read<ContactBloc>()
                                .state
                                .userContact
                                .length ||
                        genericState) {
                      discardProfile();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                centerTitle: true,
                title: Text(
                  genericState && widget.userContact.id != 0
                      ? 'Update Profile'
                      : 'Profile',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              body: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  final selectedContact = getSelectedContact(state);

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (!genericState) return;

                                  final imagePath = await pickAndSaveImage();
                                  if (imagePath != null && context.mounted) {
                                    context.read<ContactBloc>().add(
                                          UpdateAvatar(
                                            contactId:
                                                widget.userContact.id == 0
                                                    ? newId
                                                    : widget.userContact.id,
                                            avatarPath: imagePath,
                                          ),
                                        );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: selectedContact
                                          .avatar.isEmpty
                                      ? null
                                      : selectedContact.avatar
                                              .startsWith('http')
                                          ? CachedNetworkImageProvider(
                                              selectedContact.avatar)
                                          : FileImage(
                                                  File(selectedContact.avatar))
                                              as ImageProvider,
                                  child: selectedContact.avatar.isEmpty
                                      ? const Icon(Icons.person, size: 80)
                                      : null,
                                ),
                              ),
                              if (widget.userContact.isFavourite &&
                                  !genericState) ...[
                                const Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Icon(Icons.star,
                                      color: Colors.yellow, size: 40),
                                ),
                              ] else if (genericState) ...[
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppDefault.themeColor,
                                    ),
                                    child: const Icon(Icons.edit_outlined,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.userContact.firstName} ${widget.userContact.lastName}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          if (genericState) ...[
                            Form(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('First Name',
                                        style: TextStyle(
                                            color: AppDefault.themeColor)),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: firstNameController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      hintText: 'Enter first name',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            color: AppDefault.themeColor),
                                      ),
                                    ),
                                    validator: (p0) => (p0?.isEmpty ?? false)
                                        ? 'First name not inserted'
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('Last Name',
                                        style: TextStyle(
                                            color: AppDefault.themeColor)),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: lastNameController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      hintText: 'Enter last name',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            color: AppDefault.themeColor),
                                      ),
                                    ),
                                    validator: (p0) => (p0?.isEmpty ?? false)
                                        ? 'Last name not inserted'
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Email',
                                      style: TextStyle(
                                        color: AppDefault.themeColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      hintText: 'Enter email',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            30), // Rounded edges
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            color: AppDefault.themeColor),
                                      ),
                                    ),
                                    validator: (p0) {
                                      if (p0?.isEmpty ?? false) {
                                        return 'Email is not inserted';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                if (firstNameController.text.isEmpty &&
                                    lastNameController.text.isEmpty &&
                                    emailController.text.isEmpty) {
                                  const snackBar = SnackBar(
                                      content: Text(
                                          'At least one of the field must be filled in!'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  return;
                                }

                                String avatar = selectedContact.avatar;

                                context.read<ContactBloc>().add(
                                      SaveUser(
                                        userContact: UserContact(
                                          id: widget.userContact.id == 0
                                              ? newId
                                              : widget.userContact.id,
                                          email: emailController.text,
                                          firstName: firstNameController.text,
                                          lastName: lastNameController.text,
                                          avatar: avatar.isEmpty
                                              ? AppDefault.defaultImage
                                              : avatar,
                                          isFavourite:
                                              widget.userContact.isFavourite,
                                        ),
                                      ),
                                    );

                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ] else ...[
                            OutlinedButton(
                              onPressed: () {
                                context
                                    .read<GenericCubit<bool>>()
                                    .updateValue(true);
                              },
                              child: const Text('Edit Profile'),
                            ),

                            Text(
                              widget.userContact.email,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),

                            const SizedBox(height: 32),

                            // Send Email Button
                            ElevatedButton(
                              onPressed: () {
                                openEmailApp(
                                    emailAddress: widget.userContact.email);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Send Email',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
