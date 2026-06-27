import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showValue;
  final void Function(int)? onRate;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.showValue = false,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: onRate != null ? () => onRate!(index + 1) : null,
            child: Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              size: size,
              color: color ?? AppColors.starGold,
            ),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final double size;
  final void Function(int) onRate;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    this.size = 32,
    required this.onRate,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1;
            });
            widget.onRate(_currentRating);
          },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            size: widget.size,
            color: AppColors.starGold,
          ),
        );
      }),
    );
  }
}
