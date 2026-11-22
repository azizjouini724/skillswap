import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (String label, Color color, IconData icon) = switch (status) {
      ExchangeStatus.pending =>
        ('Pending', AppColors.warning, Icons.hourglass_top_rounded),
      ExchangeStatus.accepted =>
        ('Accepted', AppColors.success, Icons.check_circle_rounded),
      ExchangeStatus.rejected =>
        ('Declined', AppColors.error, Icons.cancel_rounded),
      ExchangeStatus.cancelled =>
        ('Cancelled', AppColors.textLight, Icons.block_rounded),
      ExchangeStatus.completed =>
        ('Completed', AppColors.primary, Icons.verified_rounded),
      SessionStatus.proposed =>
        ('Proposed', AppColors.warning, Icons.schedule_rounded),
      SessionStatus.confirmed =>
        ('Confirmed', AppColors.success, Icons.event_available_rounded),
      _ => (status, AppColors.textLight, Icons.help_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}