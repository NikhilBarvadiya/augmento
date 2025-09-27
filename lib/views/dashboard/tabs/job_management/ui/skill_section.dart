import 'package:augmento/utils/decoration.dart';
import 'package:flutter/material.dart';

class SkillSection extends StatelessWidget {
  final Map<String, dynamic>? candidate;

  const SkillSection({super.key, this.candidate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              decoration.formatDate(candidate?['createdAt']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (candidate?['budgetType'] != null || candidate?['jobType'] != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              _formatBudget(),
              style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }

  String _formatBudget() {
    if (candidate?['budget']?['hourlyFrom'] != null) {
      return 'Budget \$${candidate!['budget']['hourlyFrom']} - \$${candidate!['budget']['hourlyTo']} / Hourly';
    } else if (candidate?['budget']?['fixedRate'] != null) {
      return 'Budget \$${candidate!['budget']['fixedRate']} Fixed';
    } else {
      final jobType = candidate?['budgetType'] ?? candidate?['jobType'] ?? 'N/A';
      return 'Salary \$${candidate?['minSalary']} - \$${candidate?['maxSalary']} ($jobType)';
    }
  }
}
