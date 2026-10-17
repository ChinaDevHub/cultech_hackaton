import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'glass_panel.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return GlassPanel(
      accent: AppColors.crimson,
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, color: AppColors.crimson),
          const SizedBox(width: 14),
          Expanded(child: Text(message, style: text.bodyMedium)),
          if (onRetry != null) ...<Widget>[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Yenidən cəhd et'),
            ),
          ],
        ],
      ),
    );
  }
}
