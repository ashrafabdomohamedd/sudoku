import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state/game_store.dart';
import 'state/game_state.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SudokuApp());
}

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  final GameStore _store = GameStore();
  final GameState _gameState = GameState();
  bool _showSplash = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      setState(() => _loaded = true);
    });
    _store.addListener(() => setState(() {}));
  }

  void _toggleTheme() {
    _store.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Segoe UI'),
      home: _showSplash
          ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
          : !_loaded
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : HomeScreen(store: _store, gameState: _gameState, onToggleTheme: _toggleTheme),
    );
  }
}
