import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'models/photo.dart';
import 'services/photo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplishSplash',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
            home: Scaffold(
        body: Center(
          child: FutureBuilder<List<Photo>>(
            future: PhotoService().fetch(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              if (snap.hasError) return Text('Error: ${snap.error}');
              final photos = snap.data!;
              return Text(
                '${photos.length} photos, first by ${photos.first.photographer}',
              );
            },
          ),
        ),
      ),
    );
  }
}