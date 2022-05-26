import 'package:conqur_backend_test/utils/emitter.dart';
import 'package:conqur_backend_test/view/cli.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ConqurCLIApp());
}

class ConqurCLIApp extends StatelessWidget {
  const ConqurCLIApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conqur Backend Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        textTheme: GoogleFonts.ubuntuMonoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: ChangeNotifierProvider(
        create: (context) => Emitter(),
        child: CLI(),
      ),
    );
  }
}
