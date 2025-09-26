import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SkillSection extends StatelessWidget {
  final Map<String, dynamic>? candidate;

  const SkillSection({super.key, this.candidate});

  @override
  Widget build(BuildContext context) {
    final requiredSkills = candidate?['skills'] as List? ?? candidate?['requiredSkills'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code_rounded, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Required Skills',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              _formatDate(candidate!['createdAt']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        requiredSkills.isNotEmpty
            ? Wrap(
                spacing: 6,
                runSpacing: 6,
                children: requiredSkills.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Text(
                      skill.toString(),
                      style: TextStyle(fontSize: 11, color: Colors.purple[700], fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Text('No skills specified', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ),
        if (candidate!['budgetType'] != null || candidate!['jobType'] != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${candidate!['budgetType'] ?? candidate!['jobType']} (Salary)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (candidate!['budget']?["hourlyFrom"] == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                candidate!['budget']?["fixedRate"] != null ? '₹${candidate!['budget']?["fixedRate"]}' : 'Min : ₹${candidate!["minSalary"]} - Max : ₹${candidate!["maxSalary"]}',
                style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
              ),
            ),
          if (candidate!['budget']?["hourlyFrom"] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                'From : ${candidate!['budget']["hourlyFrom"]} - To : ${candidate!['budget']["hourlyTo"]}',
                style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date not available';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}
