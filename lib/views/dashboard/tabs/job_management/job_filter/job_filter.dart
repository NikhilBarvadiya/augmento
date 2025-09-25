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
      appBar: AppBar(
        title: Text('Job Filters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: decoration.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Date Posted'),
              _buildChoiceChips(
                controller,
                ['Past 24 hours', 'Past Week', 'Past Month', 'All Time'],
                controller.selectedDatePosted,
                (value) => controller.selectedDatePosted.value = value,
                singleSelect: true,
              ),
              _buildSectionTitle('Skills'),
              _buildSkillChips(controller),
              _buildSectionTitle('Work Type'),
              _buildChoiceChips(controller, ['Remote', 'Hybrid', 'On-site'], controller.selectedWorkTypes, (value) => controller.selectedWorkTypes.value = value),
              _buildSectionTitle('Shift Timings'),
              _buildChoiceChips(controller, ['IST', 'PST', 'EST', 'GMT'], controller.selectedShifts, (value) => controller.selectedShifts.value = value),
              _buildSectionTitle('Job Type'),
              _buildChoiceChips(controller, ['Full-time', 'Part-time', 'Contract', 'Internship'], controller.selectedJobTypes, (value) => controller.selectedJobTypes.value = value),
              _buildSectionTitle('Experience Level'),
              _buildChoiceChips(controller, ['Entry', 'Mid', 'Senior', 'Lead'], controller.selectedExperienceLevels, (value) => controller.selectedExperienceLevels.value = value),
              _buildSectionTitle('Salary Range (₹/Month)'),
              _buildSalaryRangeFields(controller),
              _buildSectionTitle('Status (Onboard Tab)'),
              _buildChoiceChips(controller, ['All', 'Accepted', 'Rejected', 'Pending'], controller.selectedStatuses, (value) => controller.selectedStatuses.value = value, singleSelect: true),
              SizedBox(height: 16),
              _buildActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: decoration.colorScheme.primary),
      ),
    );
  }

  Widget _buildChoiceChips(JobFilterCtrl controller, List<String> options, RxList<String> selectedValues, Function(List<String>) onChanged, {bool singleSelect = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(option),
          selected: selectedValues.contains(option),
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
          selectedColor: decoration.colorScheme.primary.withOpacity(0.2),
          labelStyle: TextStyle(fontSize: 12, color: selectedValues.contains(option) ? decoration.colorScheme.primary : Colors.black87),
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(category.key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
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
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Min (₹)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.salaryMin.value = value.isEmpty ? null : int.tryParse(value),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Max (₹)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.salaryMax.value = value.isEmpty ? null : int.tryParse(value),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(JobFilterCtrl controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            controller.applyFilters();
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: decoration.colorScheme.primary, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          child: Text('Apply', style: TextStyle(fontSize: 14, color: decoration.colorScheme.onPrimary)),
        ),
      ],
    );
  }
}
