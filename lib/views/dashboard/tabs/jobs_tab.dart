import 'package:augmento/utils/decoration.dart';
import 'package:flutter/material.dart';

class JobsTab extends StatelessWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(Icons.work_outline, color: decoration.colorScheme.primary),
            title: Text('Job Title #${index + 1}'),
            subtitle: const Text('Posted on: Sep 2025 | Applicants: 5'),
            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
