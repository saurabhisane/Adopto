import 'package:adopto/constants.dart';
import 'package:adopto/providers/auth_provider.dart';
import 'package:adopto/screens/home.dart';
// import 'package:adopto/screens/pets_list.dart';
import 'package:adopto/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadFromStorage(),
      child: Consumer<AuthProvider>(builder: (context, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Adopto',
          theme: ThemeData(
            scaffoldBackgroundColor: kBackgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: kBackgroundColor,
              iconTheme: IconThemeData(color: kBrownColor),
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: kBrownColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            useMaterial3: true,
          ),
          home: auth.isAuthenticated ? const Home() : const LoginScreen(),
          routes: {
            
          },
        );
      }),
    );
  }
}