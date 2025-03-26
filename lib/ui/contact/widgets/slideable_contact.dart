import 'package:cached_network_image/cached_network_image.dart';
import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:flutter/material.dart';

class SlideableContact extends StatelessWidget {
  const SlideableContact({
    super.key,
    required this.userContact,
  });

  final UserContact userContact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        userContact.firstName + userContact.lastName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(userContact.email),
      trailing: const Icon(Icons.send, color: Colors.grey),
    );
  }
}
