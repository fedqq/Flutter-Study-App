import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/gradient_widgets.dart';
import 'package:flutter_application_1/utils/theming.dart';

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
    return GradientOutline(
      innerPadding: 16,
      gradient: Theming.grayGradient,
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
    );
  }
}
