import 'package:contact_app_qbeep/utils/singleton/app_color.dart';
import 'package:flutter/material.dart';

class ContactSearchBar extends StatefulWidget {
  const ContactSearchBar({
    super.key,
    required this.onDebounceRun,
  });

  final Function(String) onDebounceRun;

  @override
  State<ContactSearchBar> createState() => _ContactSearchBarState();
}

class _ContactSearchBarState extends State<ContactSearchBar> {
  final debounce = Debounce(milliseconds: 800);
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: searchController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Enter first name',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded edges
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppDefault.themeColor),
        ),
      ),
      onChanged: (String val) {
        debounce.run(() {
          widget.onDebounceRun(val);
        });
      },
    );
  }
}
