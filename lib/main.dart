import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/theme/tato_theme.dart';

void main() {
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
