import 'package:flutter/material.dart';

class TestInput extends StatefulWidget {
  final String name;
  final Function(String) onChanged;
  const TestInput({super.key, required this.name, required this.onChanged});

  @override
  State<TestInput> createState() => _TestInputState();
}

class _TestInputState extends State<TestInput> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.name}: '),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
