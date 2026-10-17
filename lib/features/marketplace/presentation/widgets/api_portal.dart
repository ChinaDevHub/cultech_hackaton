import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/pulse_dot.dart';
import '../../../../core/widgets/scramble_text.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/api_key.dart';
import '../bloc/api_key_cubit.dart';

/// Instant Bearer-key generator with copy, reveal and a live curl snippet.
class ApiKeyGeneratorCard extends StatelessWidget {
  const ApiKeyGeneratorCard({super.key});

  static const String _placeholder = 'cg_live_••••••••••••••••••••••••••••••••';

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      accent: AppColors.gold,
      child: BlocBuilder<ApiKeyCubit, ApiKeyState>(
        builder: (BuildContext context, ApiKeyState state) {
          final ApiKeyCubit cubit = context.read<ApiKeyCubit>();
          final ApiKey? key = state.key;
          final bool generating = state.status == ApiKeyStatus.generating;
          final String display = key == null
              ? _placeholder.replaceFirst('cg_live_', state.environment.prefix)
              : state.revealed
              ? key.value
              : key.masked;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionHeader(
                icon: Icons.key_rounded,
                title: 'API Açar Generatoru',
                subtitle:
                    'Bearer açarı ilə datasetlərə və AI DNT API-sinə giriş',
                trailing: SegmentedButton<ApiEnvironment>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: <ButtonSegment<ApiEnvironment>>[
                    for (final ApiEnvironment env in ApiEnvironment.values)
                      ButtonSegment<ApiEnvironment>(
                        value: env,
                        label: Text(env.label),
                      ),
                  ],
                  selected: <ApiEnvironment>{state.environment},
                  onSelectionChanged: generating
                      ? null
                      : (Set<ApiEnvironment> selection) =>
                            cubit.selectEnvironment(selection.first),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: key == null
                        ? AppColors.outline
                        : AppColors.gold.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Bearer ',
                      style: AppTypography.mono(color: AppColors.textMuted),
                    ),
                    Expanded(
                      child: SelectionArea(
                        child: ScrambleText(
                          display,
                          style: AppTypography.mono(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: key == null
                                ? AppColors.textMuted
                                : AppColors.goldLight,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: state.revealed ? 'Gizlət' : 'Göstər',
                      onPressed: key == null ? null : cubit.toggleReveal,
                      icon: Icon(
                        state.revealed
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 18,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kopyala',
                      onPressed: key == null
                          ? null
                          : () => copyWithFeedback(
                              context,
                              key.value,
                              successMessage: 'API açarı panoya kopyalandı',
                            ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: generating ? null : cubit.generate,
                    icon: generating
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(key == null ? 'Açar yarat' : 'Yeni açar yarat'),
                  ),
                  if (key != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const PulseDot(color: AppColors.emerald, size: 7),
                        const SizedBox(width: 4),
                        Text(
                          'Aktiv · ${key.scopes.join(', ')}',
                          style: AppTypography.mono(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (state.errorMessage != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: text.bodySmall?.copyWith(color: AppColors.crimson),
                ),
              ],
              const SizedBox(height: 18),
              _CodeSnippet(
                code:
                    'curl https://api.cultguard.az/v1/dna/match \\\n'
                    '  -H "Authorization: Bearer ${key == null ? '<API_AÇARI>' : key.masked}" \\\n'
                    '  -H "Content-Type: application/json" \\\n'
                    '  -d \'{"media_kind": "image", "vector": [...]}\'',
                copyText: key == null
                    ? null
                    : 'curl https://api.cultguard.az/v1/dna/match '
                          '-H "Authorization: Bearer ${key.value}" '
                          '-H "Content-Type: application/json" '
                          '-d \'{"media_kind": "image", "vector": []}\'',
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Açarı gizli saxlayın — onu klient tətbiqinə deyil, '
                      'serverinizin mühit dəyişənlərinə yerləşdirin.',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CodeSnippet extends StatelessWidget {
  const _CodeSnippet({required this.code, this.copyText});

  final String code;
  final String? copyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070C18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 48, 14),
            child: SelectableText(
              code,
              style: AppTypography.mono(
                fontSize: 12,
                color: const Color(0xFFA5F3FC),
                height: 1.65,
              ),
            ),
          ),
          if (copyText != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Kodu kopyala',
                iconSize: 16,
                onPressed: () => copyWithFeedback(
                  context,
                  copyText!,
                  successMessage: 'curl nümunəsi kopyalandı',
                ),
                icon: const Icon(Icons.content_copy_rounded),
              ),
            ),
        ],
      ),
    );
  }
}

/// Endpoint overview and SLA facts next to the key generator.
class ApiQuickstartCard extends StatelessWidget {
  const ApiQuickstartCard({super.key});

  static const List<(String, String, String)> _endpoints =
      <(String, String, String)>[
        ('GET', '/v1/datasets', 'Lisenziyalı datasetlər kataloqu'),
        ('POST', '/v1/dna/match', 'AI DNT oxşarlıq axtarışı'),
        ('GET', '/v1/incidents', 'Real-vaxt pozuntu axını'),
        ('POST', '/v1/claims', 'Müəllif hüququ iddiası'),
        ('POST', '/v1/licenses', 'B2B lisenziya sifarişi'),
      ];

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionHeader(
            icon: Icons.integration_instructions_rounded,
            title: 'REST API v1',
            subtitle: 'JSON · OAuth2 Bearer · CORS aktiv',
          ),
          const SizedBox(height: 14),
          for (final (String method, String path, String description)
              in _endpoints)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          (method == 'GET'
                                  ? AppColors.emerald
                                  : AppColors.amber)
                              .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      method,
                      style: AppTypography.mono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: method == 'GET'
                            ? AppColors.emerald
                            : AppColors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(path, style: AppTypography.mono(fontSize: 12.5)),
                        Text(
                          description,
                          style: text.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          const Row(
            children: <Widget>[
              Expanded(
                child: _Fact(value: '99.95%', label: 'SLA'),
              ),
              Expanded(
                child: _Fact(value: '42 ms', label: 'p50 gecikmə'),
              ),
              Expanded(
                child: _Fact(value: '2', label: 'region'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: AppTypography.mono(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.goldLight,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
