import 'dart:developer';

import 'package:contact_app_qbeep/data/repositories/contact_repository.dart';
import 'package:contact_app_qbeep/ui/contact/bloc/contact_bloc.dart';
import 'package:contact_app_qbeep/ui/contact/contact.dart';
import 'package:contact_app_qbeep/utils/singleton/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDirectory = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      appDirectory.path,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppDefault.themeColor),
        useMaterial3: true,
      ),
      home: BlocProvider<ContactBloc>(
        create: (context) {
          final bloc = ContactBloc(contactRepository: ContactRepositoryImpl());

          if (bloc.state.userContact.isEmpty) {
            bloc.add(FetchContacts());
            log('gets called');
          }

          return bloc;
        },
        child: const Contact(),
      ),
    );
  }
}
