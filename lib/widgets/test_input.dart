import 'package:flutter/material.dart';

class TestInput extends StatefulWidget {
  const TestInput({
    super.key,
    required this.name,
    required this.area,
    required this.onChanged,
    required this.padding,
    required this.borderRadius,
  });
  final String name;
  final String area;
  final Function(String) onChanged;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  State<TestInput> createState() => _TestInputState();
}

class _TestInputState extends State<TestInput> {
  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
        margin: widget.padding,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('${widget.name}: '),
                  Text(
                    widget.area,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withAlpha(150)),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(onChanged: widget.onChanged),
              ),
            ],
          ),
        ),
      );
}
