import 'package:flutter/material.dart';
import '../theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  StatusBadge({required this.status});

  Color _colorFor(String s) {
    switch (s) {
      case 'pendingAcceptance':
      case 'pending':
        return AppColors.pending;
      case 'accepted':
        return AppColors.accepted;
      case 'inProgress':
        return AppColors.inProgress;
      case 'completed':
      case 'clientConfirmed':
        return AppColors.completed;
      case 'cancelled':
      case 'rejected':
        return AppColors.cancelled;
      default:
        return Colors.grey;
    }
  }

  String _label(String s) {
    switch (s) {
      case 'pendingAcceptance':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'clientConfirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    final label = _label(status);
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      backgroundColor: color.withOpacity(0.95),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
