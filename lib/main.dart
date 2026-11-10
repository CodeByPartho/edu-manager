import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_shell.dart';
import 'state/edu_state.dart';

const Color _accent = Color(0xFF39FF88);

void main() {
  runApp(const EduManagerApp());
}

class EduManagerApp extends StatelessWidget {
  const EduManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EduState()..load(),
      child: MaterialApp(
        title: 'EduManager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _accent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const _LoadingGate(),
      ),
    );
  }
}

class _LoadingGate extends StatelessWidget {
  const _LoadingGate();

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<EduState, bool>((s) => s.loaded);
    if (!loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const MainShell();
  }
}
