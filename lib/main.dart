import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes/app_router.dart';
import 'core/theme/tato_theme.dart';

// Read from --dart-define / --dart-define-from-file, never hardcoded here.
// Run with, e.g.:
//   flutter run --dart-define-from-file=dart_define.json
// using your own untracked dart_define.json (see dart_define.example.json).
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty,
    'Faltan SUPABASE_URL / SUPABASE_ANON_KEY. Pasa '
    '--dart-define-from-file=dart_define.json al ejecutar/compilar.',
  );

  await Supabase.initialize(
    url: _supabaseUrl,
    // SDK 2.16+ renamed anonKey -> publishableKey (same anon/public JWT).
    publishableKey: _supabaseAnonKey,
  );

  runApp(const ProviderScope(child: TatoApp()));
}

class TatoApp extends ConsumerWidget {
  const TatoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TÁTO',
      debugShowCheckedModeBanner: false,
      theme: TatoTheme.lightTheme,
      routerConfig: router,
    );
  }
}
