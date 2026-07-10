import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';

/// Bridges auth/business state changes into GoRouter's `refreshListenable`.
///
/// Without this, the router provider would need to `ref.watch` the auth
/// providers directly and rebuild a brand new `GoRouter` instance on every
/// change — losing the navigation stack. Instead, `redirect` reads the
/// current values with `ref.read` and this notifier just tells the
/// existing `GoRouter` "something changed, re-run redirect".
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
    ref.listen(currentBusinessProvider, (_, __) => notifyListeners());
  }
}
