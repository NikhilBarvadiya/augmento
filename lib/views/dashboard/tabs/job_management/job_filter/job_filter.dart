import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/job_filter/job_filter_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobFilter extends StatelessWidget {
  const JobFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobFilterCtrl());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Job Filters',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: decoration.colorScheme.primary,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.close(1),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => _showResetDialog(context, controller),
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Column(
                  children: [
                    _buildFilterCard(
                      'Date Posted',
                      Icons.schedule_rounded,
                      _buildChoiceChips(
                        controller,
                        ['Past 24 hours', 'Past Week', 'Past Month', 'All Time'],
                        controller.selectedDatePosted,
                        (value) => controller.selectedDatePosted.value = value,
                        singleSelect: true,
                      ),
                    ),
                    _buildFilterCard('Skills', Icons.code_rounded, _buildSkillChips(controller)),
                    _buildFilterCard(
                      'Work Type',
                      Icons.business_center_rounded,
                      _buildChoiceChips(controller, ['Remote', 'Hybrid', 'On-site'], controller.selectedWorkTypes, (value) => controller.selectedWorkTypes.value = value),
                    ),
                    _buildFilterCard(
                      'Shift Timings',
                      Icons.access_time_rounded,
                      _buildChoiceChips(controller, ['IST', 'PST', 'EST', 'GMT'], controller.selectedShifts, (value) => controller.selectedShifts.value = value),
                    ),
                    _buildFilterCard(
                      'Job Type',
                      Icons.work_outline_rounded,
                      _buildChoiceChips(controller, ['Full-time', 'Part-time', 'Contract', 'Internship'], controller.selectedJobTypes, (value) => controller.selectedJobTypes.value = value),
                    ),
                    _buildFilterCard(
                      'Experience Level',
                      Icons.trending_up_rounded,
                      _buildChoiceChips(controller, ['Entry', 'Mid', 'Senior', 'Lead'], controller.selectedExperienceLevels, (value) => controller.selectedExperienceLevels.value = value),
                    ),
                    _buildFilterCard('Salary Range', Icons.payments_outlined, _buildSalaryRangeFields(controller)),
                    _buildFilterCard(
                      'Status',
                      Icons.flag_rounded,
                      _buildChoiceChips(controller, ['All', 'Accepted', 'Rejected', 'Pending'], controller.selectedStatuses, (value) => controller.selectedStatuses.value = value, singleSelect: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActions(controller),
        ],
      ),
    );
  }

  Widget _buildFilterCard(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 18, color: decoration.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChips(JobFilterCtrl controller, List<String> options, RxList<String> selectedValues, Function(List<String>) onChanged, {bool singleSelect = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(
            option,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[700]),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (singleSelect) {
              selectedValues.clear();
              if (selected) selectedValues.add(option);
            } else {
              if (selected) {
                selectedValues.add(option);
              } else {
                selectedValues.remove(option);
              }
            }
            onChanged(selectedValues.toList());
          },
          backgroundColor: Colors.grey[100],
          selectedColor: decoration.colorScheme.primary,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? decoration.colorScheme.primary : Colors.grey[300]!),
          ),
          elevation: 0,
          pressElevation: 2,
        );
      }).toList(),
    );
  }

  Widget _buildSkillChips(JobFilterCtrl controller) {
    final skillCategories = {
      'Frontend': ['Angular', 'React', 'Vue.js', 'TypeScript', 'JavaScript', 'HTML/CSS'],
      'Backend': ['Python', 'Java', 'Node JS', 'C#', 'PHP', 'Ruby'],
      'Database & Cloud': ['MongoDB', 'PostgreSQL', 'MySQL', 'Redis', 'AWS', 'Docker'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skillCategories.entries.map((category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (skillCategories.keys.first != category.key) const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(
                category.key,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            _buildChoiceChips(controller, category.value, controller.selectedSkills, (value) => controller.selectedSkills.value = value),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSalaryRangeFields(JobFilterCtrl controller) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Min Amount',
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
              onChanged: (value) => controller.salaryMin.value = value.isEmpty ? null : int.tryParse(value),
            ),
          ),
        ),
        Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 20, height: 2, color: Colors.grey[400]),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Max Amount',
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: decoration.colorScheme.primary, fontWeight: FontWeight.w600),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
              onChanged: (value) => controller.salaryMax.value = value.isEmpty ? null : int.tryParse(value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(JobFilterCtrl controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.close(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.applyFilters();
                  Get.close(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: decoration.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Apply Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, JobFilterCtrl controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.refresh_rounded, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Reset Filters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
        content: const Text('Are you sure you want to reset all filters? This action cannot be undone.', style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetFilters();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
