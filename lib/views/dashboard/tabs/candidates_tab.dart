import 'package:augmento/utils/decoration.dart';
import 'package:flutter/material.dart';

class CandidatesTab extends StatelessWidget {
  const CandidatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Candidates'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Management'),
              Tab(text: 'Requirements'),
            ],
            labelColor: decoration.colorScheme.primary,
            unselectedLabelColor: decoration.colorScheme.onSurfaceVariant,
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Candidates Management: List, Add, Edit Candidates')),
            Center(child: Text('Candidate Requirements: Skills, Qualifications, etc.')),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.person_add)),
      ),
    );
  }
}
