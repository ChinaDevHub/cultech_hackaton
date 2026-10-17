import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cultguard_logo.dart';
import '../widgets/splash_painters.dart';

/// Animated intro: a vector grid radiates out, a heritage medallion is traced
/// stroke by stroke and "digitised" into AI nodes, then the CultGuard shield
/// lands in its heart and flies (Hero) into onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const Duration introDuration = Duration(milliseconds: 3400);
  static const Duration holdDuration = Duration(milliseconds: 700);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashPage.introDuration,
  );

  late final SplashGridPainter _gridPainter = SplashGridPainter(
    progress: _controller,
  );
  late final MedallionTracePainter _medallionPainter = MedallionTracePainter(
    progress: _controller,
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.56, 0.82, curve: Curves.elasticOut),
  );
  late final Animation<double> _logoOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.56, 0.7, curve: Curves.easeOut),
  );
  late final Animation<double> _wordmark = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.66, 0.92, curve: Curves.easeOutCubic),
  );

  bool _showSlogan = false;
  bool _navigated = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(_onTick)
      ..addStatusListener(_onStatus)
      ..forward();
  }

  void _onTick() {
    if (!_showSlogan && _controller.value >= 0.72) {
      setState(() => _showSlogan = true);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status.isCompleted) {
      _holdTimer = Timer(SplashPage.holdDuration, _goNext);
    }
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Size size = MediaQuery.sizeOf(context);
    final double medallionSize = (size.shortestSide * 0.62).clamp(220.0, 440.0);

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Semantics(
        label: 'CultGuard yüklənir. Davam etmək üçün toxunun.',
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _goNext,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              RepaintBoundary(child: CustomPaint(painter: _gridPainter)),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox.square(
                          dimension: medallionSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Positioned.fill(
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    painter: _medallionPainter,
                                  ),
                                ),
                              ),
                              FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Hero(
                                    tag: CultGuardLogo.heroTag,
                                    child: CultGuardLogo(
                                      size: medallionSize * 0.26,
                                      glow: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        AnimatedBuilder(
                          animation: _wordmark,
                          builder: (BuildContext context, Widget? _) {
                            return Opacity(
                              opacity: _wordmark.value,
                              child: Text(
                                'CULTGUARD',
                                style: text.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4 + 10 * (1 - _wordmark.value),
                                  foreground: Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: AppColors.goldGradient,
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 320, 40),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        AnimatedOpacity(
                          opacity: _showSlogan ? 1 : 0,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOut,
                          child: AnimatedSlide(
                            offset: _showSlogan
                                ? Offset.zero
                                : const Offset(0, 0.4),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Azərbaycan Mədəni İrsinin\nRəqəmsal Mühafizəçisi',
                                textAlign: TextAlign.center,
                                style: text.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AnimatedOpacity(
                          opacity: _showSlogan ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            'CulTech Hakatonu · Bakı 2026',
                            style: text.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 160,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (BuildContext context, Widget? _) {
                                return LinearProgressIndicator(
                                  value: _controller.value,
                                  minHeight: 2,
                                  backgroundColor: AppColors.outline,
                                  color: AppColors.gold,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
