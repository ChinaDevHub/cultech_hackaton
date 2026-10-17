import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cultguard_logo.dart';
import '../../../../core/widgets/heritage_backdrop.dart';
import '../widgets/onboarding_illustrations.dart';
import '../widgets/page_indicator.dart';

class _Slide {
  const _Slide({
    required this.kicker,
    required this.title,
    required this.body,
    required this.accent,
    required this.illustration,
  });

  final String kicker;
  final String title;
  final String body;
  final Color accent;
  final Widget illustration;
}

const List<_Slide> _slides = <_Slide>[
  _Slide(
    kicker: 'AI DNT ÇIXARIŞI',
    title: 'Mədəni irsin rəqəmsal\nDNT-si',
    body:
        'Xalça naxışları, muğam dəstgahları və milli alətlər üçün '
        '512-ölçülü vektor barmaq izləri çıxarır, onları zaman möhürlü '
        'milli reyestrdə qeydə alırıq.',
    accent: AppColors.gold,
    illustration: DnaHelixIllustration(),
  ),
  _Slide(
    kicker: 'REAL-VAXT MONİTORİNQ',
    title: 'Generativ AI-da pozuntuları\nanında aşkarlayın',
    body:
        'Midjourney, Suno, Stable Diffusion və digər modellərin çıxışlarını '
        '24/7 izləyir, icazəsiz mənimsəmələri 94%+ dəqiqliklə müəyyən edirik.',
    accent: AppColors.crimson,
    illustration: RadarIllustration(),
  ),
  _Slide(
    kicker: 'B2B LİSENZİYALAŞDIRMA',
    title: 'İrsi qoruyun,\ndəyərini monetizasiya edin',
    body:
        'Təsdiqlənmiş, etik datasetlər GameDev studiyalarına və AI '
        'şirkətlərinə API vasitəsilə lisenziyalaşdırılır — gəlirin bir '
        'hissəsi mədəniyyət icmalarına qayıdır.',
    accent: AppColors.emerald,
    illustration: LicensingIllustration(),
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  void _finish() => context.go(AppRoutes.dashboard);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      body: HeritageBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CultGuardWordmark(),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _isLast ? 0 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: TextButton(
                            onPressed: _isLast ? null : _finish,
                            child: const Text('Keç'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemBuilder: (BuildContext context, int index) {
                        return TickerMode(
                          enabled: index == _index,
                          child: _SlideView(slide: _slides[index]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Row(
                      children: <Widget>[
                        PageIndicator(
                          count: _slides.length,
                          index: _index,
                          color: _slides[_index].accent,
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _next,
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            _isLast
                                ? Icons.shield_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _isLast ? 'Platformaya daxil ol' : 'Növbəti',
                              key: ValueKey<bool>(_isLast),
                              style: text.labelLarge?.copyWith(
                                color: AppColors.navyDeep,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Widget copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          slide.kicker,
          style: text.labelMedium?.copyWith(
            color: slide.accent,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(slide.title, style: text.headlineMedium?.copyWith(height: 1.15)),
        const SizedBox(height: 16),
        Text(
          slide.body,
          style: text.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 760;
        if (wide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: <Widget>[
                Expanded(child: slide.illustration),
                const SizedBox(width: 48),
                Expanded(child: copy),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              Expanded(child: slide.illustration),
              const SizedBox(height: 16),
              copy,
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
