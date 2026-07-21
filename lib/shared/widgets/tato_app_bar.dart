import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

/// App-wide top bar with a consistent back affordance and title style.
/// Pass [onBack] to override the default `context.pop()`, or set
/// [showBack] to false for top-level screens.
class TatoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const TatoAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: onBack ?? () => context.pop(),
            )
          : null,
      title: Text(title, overflow: TextOverflow.ellipsis),
      actions: actions,
    );
  }
}
