import 'package:flutter/material.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pgc_app/components/widgets/file_upload_field.dart';
import 'package:kijani_pgc_app/components/widgets/multi_select.dart';
import 'package:kijani_pgc_app/components/widgets/text_area_field.dart';

class GroupTrainingReport extends StatefulWidget {
  const GroupTrainingReport({super.key});

  @override
  State<GroupTrainingReport> createState() => _GroupTrainingReportState();
}

class _GroupTrainingReportState extends State<GroupTrainingReport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController detailsController = TextEditingController();

  final users = const [
    {"id": 1, "name": "Alice Johnson", "role": "Trainer"},
    {"id": 2, "name": "Bob Smith", "role": "Coordinator"},
    {"id": 3, "name": "Charlie Brown", "role": "Farmer"},
    {"id": 4, "name": "Diana Prince", "role": "Trainer"},
    {"id": 5, "name": "Ethan Hunt", "role": "Coordinator"},
    {"id": 6, "name": "Fiona Gallagher", "role": "Farmer"},
    {"id": 7, "name": "George Miller", "role": "Trainer"},
    {"id": 8, "name": "Hannah Davis", "role": "Coordinator"},
    {"id": 9, "name": "Isaac Newton", "role": "Farmer"},
    {"id": 10, "name": "Jane Foster", "role": "Trainer"},
    {"id": 11, "name": "Kevin Lee", "role": "Coordinator"},
    {"id": 12, "name": "Laura Kim", "role": "Farmer"},
    {"id": 13, "name": "Michael Jordan", "role": "Trainer"},
    {"id": 14, "name": "Nina Williams", "role": "Coordinator"},
    {"id": 15, "name": "Oscar Wilde", "role": "Farmer"},
    {"id": 16, "name": "Paula Abdul", "role": "Trainer"},
    {"id": 17, "name": "Quentin Blake", "role": "Coordinator"},
    {"id": 18, "name": "Rachel Green", "role": "Farmer"},
    {"id": 19, "name": "Samuel Adams", "role": "Trainer"},
    {"id": 20, "name": "Tina Turner", "role": "Coordinator"},
  ];

  // Current values (kept to preserve your existing behavior)
  List<Map<String, dynamic>> picked = const [];
  List<String> _attendanceImages = [];
  List<String> _trainingImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(
        title: 'Group Training Report',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              spacing: 5.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Attendance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("Select Farmers present at the training session"),

                // --- Users Multi-select (refactored with _ValidatedField) ---
                _ValidatedField<List<Map<String, dynamic>>>(
                  initialValue: picked,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please select at least one user.'
                      : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: MultiSelectDropdown<Map<String, dynamic>>(
                          items: users,
                          labelFor: (u) => u["name"],
                          subtitleFor: (u) => "Role: ${u["role"]}",
                          placeholder: "Select users",
                          accentColor: const Color(0xFF265E3C),
                          onChanged: (values) {
                            setState(() => picked = values);
                            field.didChange(values);
                            debugPrint(
                                "Picked: ${values.map((u) => u["id"]).toList()}");
                          },
                        ),
                      ),
                      _ErrorText(field.errorText),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  "Images",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // --- Attendance images (refactored) ---
                _ValidatedField<List<String>>(
                  initialValue: _attendanceImages,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please upload at least one attendance photo.'
                      : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImagePickerWidget(
                        onImagesSelected: (values) {
                          _attendanceImages = values;
                          field.didChange(values);
                        },
                        label: "Attendance List",
                        maxImages: 2,
                      ),
                      _ErrorText(field.errorText),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // --- Training session images (refactored) ---
                _ValidatedField<List<String>>(
                  initialValue: _trainingImages,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please upload at least one training session photo.'
                      : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImagePickerWidget(
                        onImagesSelected: (values) {
                          _trainingImages = values;
                          field.didChange(values);
                        },
                        label: "Training Session",
                        maxImages: 2,
                        hintText: "Upload the training session photos",
                      ),
                      _ErrorText(field.errorText),
                    ],
                  ),
                ),

                const SizedBox(height: 8.0),
                const Text(
                  "Training Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // --- Comments textarea (refactored) ---
                _ValidatedField<String>(
                  initialValue: detailsController.text,
                  validator: (value) =>
                      ((value ?? detailsController.text).trim().isEmpty)
                          ? 'Please enter your training comments.'
                          : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextAreaWidget(
                        label:
                            "Please share you experience from the training session",
                        controller: detailsController,
                        onChanged: (value) => field.didChange(value),
                      ),
                      _ErrorText(field.errorText),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                // Submit (kept same; onPressed must be async for PrimaryButton)
                PrimaryButton(
                  text: "Submit",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                      debugPrint("Form valid. Ready to submit.");
                    } else {
                      debugPrint("Form not valid");
                    }
                  },
                ),

                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small reusable wrapper to cut FormField boilerplate
class _ValidatedField<T> extends StatelessWidget {
  const _ValidatedField({
    required this.builder,
    this.initialValue,
    this.validator,
  });

  final T? initialValue;
  final String? Function(T?)? validator;
  final Widget Function(FormFieldState<T> field) builder;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      validator: validator,
      builder: (field) => builder(field),
    );
  }
}

/// Consistent error text below fields
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.error);
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Text(
        error!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
