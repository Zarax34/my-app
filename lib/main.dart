import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/settings_providers.dart';
import 'presentation/providers/ollama_providers.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/connection_screen.dart';
import 'presentation/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OllamaMobileStudioApp()));
}

class OllamaMobileStudioApp extends ConsumerWidget {
  const OllamaMobileStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final serverUrl = ref.watch(serverUrlProvider);

    return MaterialApp(
      title: 'Ollama Mobile Studio',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: serverUrl != null && serverUrl.isNotEmpty
          ? const ChatScreen()
          : const ConnectionScreen(),
    );
  }
}
