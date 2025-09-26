import 'package:augmento/utils/decoration.dart';
import 'package:augmento/views/dashboard/tabs/job_management/ui/skill_section.dart';
import 'package:augmento/views/dashboard/tabs/projects/ui/project_bid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectsDetailsCard extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectsDetailsCard({super.key, required this.project});

  @override
  State<ProjectsDetailsCard> createState() => _ProjectsDetailsCardState();
}

class _ProjectsDetailsCardState extends State<ProjectsDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * .92 - 10,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.project["isApplied"] == true
              ? null
              : () async {
                  bool isCheck = await Get.to(() => ProjectBid(project: widget.project)) ?? false;
                  if (isCheck == true) {
                    widget.project["isApplied"] = true;
                    setState(() {});
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(),
                const SizedBox(height: 16),
                SkillSection(candidate: widget.project),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.project['title']?.toString().capitalizeFirst.toString() ?? 'Unknown Project',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.project["isApplied"] == false) Icon(Icons.arrow_forward_ios, size: 16, color: decoration.colorScheme.primary),
        if (widget.project["isApplied"] == true) Text("Already Applied", style: TextStyle(fontSize: 10, color: Colors.red)),
      ],
    );
  }
}
