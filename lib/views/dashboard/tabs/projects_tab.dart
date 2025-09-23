import 'package:augmento/utils/decoration.dart';
import 'package:flutter/material.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projects & Bids'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Vendor Projects'),
              Tab(text: 'My Bids'),
            ],
            labelColor: decoration.colorScheme.primary,
            unselectedLabelColor: decoration.colorScheme.onSurfaceVariant,
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Vendor Projects Management')),
            Center(child: Text('My Bids: List of Bids Placed')),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      ),
    );
  }
}
