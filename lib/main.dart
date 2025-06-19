import 'package:book_mate_kim/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'screens/launch_screen.dart';
import 'screens/signup_screen.dart'; // 명시적 import 추가
import 'screens/home_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const BookmateApp());
}

class BookmateApp extends StatelessWidget {
  const BookmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookmate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LaunchScreen(),
        '/Login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/book-detail') {
          final bookId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookId: bookId),
          );
        }
        return null;
      },
    );
  }
}
