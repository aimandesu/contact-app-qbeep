import 'package:cached_network_image/cached_network_image.dart';
import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:contact_app_qbeep/ui/contact/bloc/contact_bloc.dart';
import 'package:contact_app_qbeep/ui/contact/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SlideableContact extends StatelessWidget {
  const SlideableContact({
    super.key,
    required this.userContact,
    required this.contactBloc,
  });

  final UserContact userContact;
  final ContactBloc contactBloc;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<ContactBloc>.value(
              value: contactBloc,
              child: Profile(userContact: userContact),
            ),
          ),
        );
      },
      // contentPadding: const EdgeInsets.all(12),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: CachedNetworkImageProvider(userContact.avatar),
          ),
          userContact.isFavourite
              ? const Positioned(
                  bottom: 0,
                  right: 0,
                  child: Icon(Icons.star, color: Colors.amber, size: 20),
                )
              : const SizedBox.shrink(),
        ],
      ),
      title: Text(
        "${userContact.firstName} ${userContact.lastName}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(userContact.email),
      trailing: const Icon(Icons.send, color: Colors.grey),
    );
  }
}
