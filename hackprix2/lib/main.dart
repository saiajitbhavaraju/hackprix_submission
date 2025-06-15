import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import the provider package
import 'package:ecosnap_1/screens/home_page_screen.dart';
import 'package:ecosnap_1/services/snap_state_service.dart'; // Import the service

// Make main asynchronous
Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the service to load the score from storage.
  await SnapStateService.instance.init();

  // 2. Wrap your app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => SnapStateService.instance,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapchat Clone App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePageScreen(),
    );
  }
}