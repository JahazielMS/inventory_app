import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'products.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventarios App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF043f79),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF043f79),
          titleTextStyle: TextStyle(color: Color(0xFF043f79), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        colorScheme: const ColorScheme.light(primary: Color(0xFF043f79), onPrimary: Colors.white),
        dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
        dividerTheme: const DividerThemeData(color: Colors.transparent, space: 16),
        cardTheme: const CardThemeData(surfaceTintColor: Colors.white, elevation: 6),
        inputDecorationTheme: const InputDecorationTheme(hintStyle: TextStyle(fontSize: 12)),
        useMaterial3: true,
      ),
      home: const ProductsPage(),
    );
  }
}
