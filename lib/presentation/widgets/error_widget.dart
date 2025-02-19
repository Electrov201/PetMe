import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final double size;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Lottie.network(
                'https://lottie.host/58ebb5c9-9f91-4e25-9d0a-9d4b19dc2d7c/1Ccp1Y3YWu.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              CustomButton(
                text: 'Try Again',
                onPressed: onRetry!,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoDataWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final double size;

  const NoDataWidget({
    super.key,
    required this.message,
    this.onAction,
    this.actionLabel,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Lottie.network(
                'https://lottie.host/b6ae9827-91ab-4c34-a654-642e0653e49d/0bYODXDp5j.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              CustomButton(
                text: actionLabel!,
                onPressed: onAction!,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
