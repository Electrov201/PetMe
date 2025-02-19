import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingAnimation({
    super.key,
    this.size = 200,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Lottie.network(
              'https://lottie.host/7a99b7a9-cd86-4d43-a22c-f6c4c9c4d6f2/HxqBHvgkDo.json',
              fit: BoxFit.contain,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Theme.of(context).colorScheme.background.withOpacity(0.8),
            child: LoadingAnimation(message: message),
          ),
      ],
    );
  }
}
