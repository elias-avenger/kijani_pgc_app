import 'package:flutter/material.dart';

class MyDateInput extends StatelessWidget {
  final String label;
  final String? value; // formatted date string to show
  final String placeholder;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final Future<DateTime?> Function()?
      onPick; // caller handles showDatePicker and formatting

  const MyDateInput({
    super.key,
    required this.label,
    required this.value,
    this.placeholder = 'Pick a date',
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        FormField<String>(
          initialValue: value,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (field) {
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await (onPick?.call() ?? Future.value(null));
                // Let the parent update controller, but mark field changed to re-run validator
                field.didChange(picked != null ? 'picked' : field.value);
              },
              child: InputDecorator(
                isEmpty: (value == null || value!.isEmpty),
                decoration: InputDecoration(
                  hintText: placeholder,
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: const Icon(Icons.calendar_month_rounded),
                  errorText: field.errorText,
                ),
                child: Text(
                  (value == null || value!.isEmpty) ? '' : value!,
                  style: TextStyle(
                    color: (value == null || value!.isEmpty)
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
