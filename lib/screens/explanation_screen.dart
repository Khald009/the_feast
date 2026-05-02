import 'package:flutter/material.dart';

class ExplanationScreen extends StatelessWidget {
  final String summary;
  final List<String> structuredSections;

  const ExplanationScreen(
      {super.key, required this.summary, required this.structuredSections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explanation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(summary, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('Structured Content',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: structuredSections.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(structuredSections[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
