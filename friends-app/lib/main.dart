import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/friends_provider.dart';
import 'providers/posts_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/events_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FriendsApp());
}

class FriendsApp extends StatelessWidget {
  const FriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: MaterialApp(
        title: 'Friends',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
