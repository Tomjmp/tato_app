import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';

enum _ScanState { idle, capturing, analyzing, suggested }

/// UI-only mock of the Edge AI classification flow described in the
/// product spec: Cámara → Imagen capturada → Categoría sugerida →
/// Confirmación. No camera plugin or ML Kit inference is wired up yet —
/// this simulates the timing and result so the flow can be designed and
/// reviewed before the real on-device model is integrated.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  _ScanState _state = _ScanState.idle;
  String? _suggestedCategory;
  int _confidence = 0;
  bool _editingCategory = false;
  List<String> _categoryNames = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null) return;
    final categories = await ref.read(getCategoriesUseCaseProvider)(businessId);
    if (mounted) setState(() => _categoryNames = categories.map((c) => c.name).toList());
  }

  Future<void> _capture() async {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null) return;

    setState(() => _state = _ScanState.capturing);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _state = _ScanState.analyzing);

    final result = await ref.read(classifyProductUseCaseProvider)(businessId: businessId);
    if (!mounted) return;

    setState(() {
      _suggestedCategory = result.category;
      _confidence = result.confidence;
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
    HapticFeedback.mediumImpact();
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
    // Pantalla oscura: contexto de cámara (ver design/DESIGN_SYSTEM.md, 06).
    return Scaffold(
      backgroundColor: TatoColors.logoInk,
      appBar: AppBar(
        backgroundColor: TatoColors.logoInk,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        title: Text(
          'Escanear producto',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white, fontSize: 18),
        ),
        actions: [
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
        ],
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
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (captured)
            Container(
              color: const Color(0xFF334155),
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
            const Icon(Icons.photo_camera_outlined,
                color: Color(0xFF475569), size: 56),
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
              'Encuadra el producto y captura la foto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(TatoSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
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
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text('Sugerencia de TÁTO',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: TatoColors.onSurfaceVariant)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '$_confidence%',
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
                  children: _categoryNames
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
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                          border: Border.all(
                            color: selected ? chipColor : Theme.of(context).colorScheme.outlineVariant,
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
                'La IA sugiere, tú siempre confirmas.',
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
      ..color = TatoColors.secondary
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
