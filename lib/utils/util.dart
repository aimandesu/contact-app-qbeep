import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

Future<bool?> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  String subTitle = '',
  Object? image,
  bool dismissible = false,
  required List<Widget> Function(BuildContext dialogContext) actions,
}) {
  Widget? buildImage(Object? image) {
    if (image is Image) {
      return image;
    } else if (image is String) {
      return Image.network(image);
    }
    return null;
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: dismissible,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              if (image != null) buildImage(image) ?? const SizedBox.shrink(),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
              if (subTitle != '')
                Text(
                  title,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...actions(
                    dialogContext,
                  )
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}

Route slideFromRightRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

int getRandomIntExcluding(List<int> excludedNumbers,
    {int min = 1, int max = 100}) {
  Random random = Random();
  int randomNumber;

  do {
    randomNumber = random.nextInt(max - min + 1) + min;
  } while (excludedNumbers.contains(randomNumber));

  return randomNumber;
}

Future<String?> pickAndSaveImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final directory = await getApplicationDocumentsDirectory();
  final newPath = '${directory.path}/${pickedFile.name}';

  final File newImage = File(pickedFile.path);
  await newImage.copy(newPath);

  return newPath; // Return the saved file path
}
