import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';
import 'package:tato_app/shared/widgets/tato_app_bar.dart';

enum _ScanState { idle, capturing, analyzing, suggested }

/// UI-only mock of the Edge AI classification flow described in the
/// product spec: Cámara → Imagen capturada → Categoría sugerida →
/// Confirmación. No camera plugin or ML Kit inference is wired up yet —
/// this simulates the timing and result so the flow can be designed and
/// reviewed before the real on-device model is integrated.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  _ScanState _state = _ScanState.idle;
  String? _suggestedCategory;
  int _confidence = 0;
  bool _editingCategory = false;

  Future<void> _capture() async {
    setState(() => _state = _ScanState.capturing);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _state = _ScanState.analyzing);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final candidates = TatoCategories.businessTypes
        .where((c) => c != 'Otro')
        .toList();
    final random = Random();
    setState(() {
      _suggestedCategory = candidates[random.nextInt(candidates.length)];
      _confidence = 82 + random.nextInt(16); // 82–97%
      _state = _ScanState.suggested;
    });
  }

  void _retake() {
    setState(() {
      _state = _ScanState.idle;
      _suggestedCategory = null;
      _editingCategory = false;
    });
  }

  void _confirm() {
    // Pushed as a picker (from the product form): hand the category back.
    // Opened as the standalone Scan tab: there's nothing to pop to, so
    // hand off to product creation instead.
    if (Navigator.canPop(context)) {
      context.pop(_suggestedCategory);
    } else {
      context.push('/inventory/new', extra: _suggestedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      appBar: TatoAppBar(
        title: 'Escanear producto',
        showBack: Navigator.canPop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TatoSpacing.containerPadding),
        child: Column(
          children: [
            Expanded(child: _buildViewfinder()),
            const SizedBox(height: TatoSpacing.lg),
            _buildBottomArea(),
            const SizedBox(height: TatoSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    final captured = _state == _ScanState.analyzing || _state == _ScanState.suggested;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TatoColors.primary,
        borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (captured)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, color: Colors.white24, size: 96),
              ),
            )
          else
            CustomPaint(
              size: Size.infinite,
              painter: _ViewfinderPainter(),
            ),
          if (!captured)
            const Icon(Icons.center_focus_strong_outlined,
                color: Colors.white54, size: 64),
          if (_state == _ScanState.capturing)
            Container(
              color: Colors.white.withOpacity(0.85),
            ),
          if (_state == _ScanState.analyzing)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: TatoSpacing.md),
                    Text(
                      'TÁTO está analizando la imagen...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    switch (_state) {
      case _ScanState.idle:
      case _ScanState.capturing:
        return Column(
          children: [
            const Text(
              'Centra el producto dentro del marco y captura la foto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TatoColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: TatoSpacing.md),
            CustomButton(
              label: 'Capturar foto',
              icon: Icons.camera_alt_outlined,
              onPressed: _state == _ScanState.capturing ? null : _capture,
              loading: _state == _ScanState.capturing,
            ),
          ],
        );
      case _ScanState.analyzing:
        return const SizedBox(height: TatoSizes.minTouchTarget);
      case _ScanState.suggested:
        final color = TatoCategories.colorFor(_suggestedCategory);
        return Container(
          padding: const EdgeInsets.fromLTRB(
              TatoSpacing.md, TatoSpacing.sm, TatoSpacing.md, TatoSpacing.md),
          decoration: const BoxDecoration(
            color: TatoColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(TatoSizes.radiusXl),
            ),
            boxShadow: TatoShadows.level2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: TatoSpacing.sm),
                  decoration: BoxDecoration(
                    color: TatoColors.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(TatoSpacing.md),
                decoration: BoxDecoration(
                  color: TatoColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                      ),
                      child: Icon(TatoCategories.iconFor(_suggestedCategory),
                          color: color),
                    ),
                    const SizedBox(width: TatoSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Categoría sugerida',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: TatoColors.onSurfaceVariant)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '$_confidence% confianza',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(_suggestedCategory ?? '',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: TatoColors.onSurfaceVariant,
                      onPressed: () =>
                          setState(() => _editingCategory = !_editingCategory),
                    ),
                  ],
                ),
              ),
              if (_editingCategory) ...[
                const SizedBox(height: TatoSpacing.sm),
                Wrap(
                  spacing: TatoSpacing.xs,
                  runSpacing: TatoSpacing.xs,
                  children: TatoCategories.businessTypes
                      .where((c) => c != 'Otro')
                      .map((c) {
                    final selected = c == _suggestedCategory;
                    final chipColor = TatoCategories.colorFor(c);
                    return GestureDetector(
                      onTap: () => setState(() {
                        _suggestedCategory = c;
                        _editingCategory = false;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? chipColor.withOpacity(0.12)
                              : TatoColors.surface,
                          borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                          border: Border.all(
                            color: selected ? chipColor : TatoColors.border,
                          ),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? chipColor : TatoColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: TatoSpacing.xs),
              const Text(
                'TÁTO sugiere, tú decides. Puedes editar la categoría antes de confirmar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: TatoColors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: TatoSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Tomar otra',
                      variant: CustomButtonVariant.outline,
                      onPressed: _retake,
                    ),
                  ),
                  const SizedBox(width: TatoSpacing.sm),
                  Expanded(
                    child: CustomButton(
                      label: 'Confirmar',
                      icon: Icons.check,
                      onPressed: _confirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const inset = 24.0;

    void corner(Offset origin, Offset dx, Offset dy) {
      canvas.drawLine(origin, origin + dx, paint);
      canvas.drawLine(origin, origin + dy, paint);
    }

    corner(const Offset(inset, inset), const Offset(len, 0), const Offset(0, len));
    corner(Offset(size.width - inset, inset), const Offset(-len, 0), const Offset(0, len));
    corner(Offset(inset, size.height - inset), const Offset(len, 0), const Offset(0, -len));
    corner(Offset(size.width - inset, size.height - inset), const Offset(-len, 0),
        const Offset(0, -len));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
