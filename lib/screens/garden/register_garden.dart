import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:kijani_pmc_app/components/garden/register_farmer.dart';
import 'package:kijani_pmc_app/components/garden/search_farmer.dart';
import 'package:kijani_pmc_app/screens/ui/radio_buttons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewGardenForm extends StatefulWidget {
  const NewGardenForm({super.key});

  @override
  State<NewGardenForm> createState() => _NewGardenFormState();
}

class _NewGardenFormState extends State<NewGardenForm> {
  // Store the selected farmer data
  Map<String, dynamic>? selectedFarmer;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _institutionNameController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _dobController;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nkFNameController = TextEditingController();
  final TextEditingController _nkLNameController = TextEditingController();
  final TextEditingController _nkPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _anotherCompanyController =
      TextEditingController();

  String isNewfarmer = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xff23566d),
        title: const Text('Register Garden'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Is the farmer already registered?',
              ),
              RadioButtons(
                groupValue: isNewfarmer,
                firstBtnValue: 'Yes',
                secondBtnValue: 'No',
                firstBtnColor: const Color(0xff23566d),
                secondBtnColor: Colors.deepOrange,
                onChanged: (value) {
                  setState(() {
                    isNewfarmer = value!;
                  });
                },
              ),
              if (isNewfarmer == 'No')
                RegisterFarmerForm(
                  formKey: _formKey,
                  controllers: {
                    'fName': _firstNameController,
                    'lName': _lastNameController,
                    'institution': _institutionNameController,
                    'dob': _dobController,
                    'phone': _phoneNumberController,
                    'nkFName': _nkFNameController,
                    'nkLName': _nkLNameController,
                    'nkPhone': _nkPhoneController,
                    'address': _addressController,
                    'anotherCompany': _anotherCompanyController,
                    'id_image': null,
                  },
                ),
              if (isNewfarmer == 'Yes')
                SearchFarmerWidget(
                  onFarmerSelected: (farmer) {
                    setState(() {
                      selectedFarmer = farmer;
                      // Update form fields with the selected farmer's data if needed
                      _firstNameController.text = farmer['First Name'];
                      _lastNameController.text = farmer['Last Name'];
                      _phoneNumberController.text = farmer['Phone Number'];
                      _addressController.text = farmer['Farmer Address'];
                    });
                  },
                ),
              const SizedBox(height: 20),
              EasyButton(
                height: 60,
                buttonColor: const Color(0xff23566d),
                borderRadius: 10,
                idleStateWidget: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Track Garden",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.add_box_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
                loadingStateWidget: LoadingAnimationWidget.hexagonDots(
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () async {
                  //TODO: Handle form submission here

                  if (isNewfarmer == 'No') {
                    if (_formKey.currentState!.validate()) {
                      //TODO: handle creating farmer here
                    }
                  } else {
                    if (selectedFarmer != null) {
                      //TODO: handle tracking garden here with farmer data
                      print('Selected Farmer: $selectedFarmer');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
