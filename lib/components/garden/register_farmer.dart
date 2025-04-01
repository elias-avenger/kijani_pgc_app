import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/components/dialogs/address.dart';
import 'package:kijani_pmc_app/components/dialogs/datepicker.dart';
import 'package:kijani_pmc_app/screens/ui/radio_buttons.dart';
import 'package:kijani_pmc_app/screens/ui/text_field.dart';
import 'package:kijani_pmc_app/utilities/constants.dart';

class RegisterFarmerForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> controllers;

  const RegisterFarmerForm({
    super.key,
    required this.formKey,
    required this.controllers,
  });

  @override
  State<RegisterFarmerForm> createState() => _RegisterFarmerFormState();
}

class _RegisterFarmerFormState extends State<RegisterFarmerForm> {
  bool isInstitution = false;

  String? gender;
  String? contract;
  String? onboarded;
  String? nationalID;
  String? infoMatchID;

  bool? fullyOnboarded;
  bool? signedContract;
  bool? anotherCompany;

  int myVar = 0;

  XFile? farmerIDImage;

  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              const Text(
                'Register as institution',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(
                width: 12,
              ),
              Switch(
                inactiveThumbColor: Colors.black,
                activeColor: Colors.green,
                value: isInstitution,
                onChanged: (bool value) {
                  setState(() {
                    isInstitution = value;
                  });
                },
              )
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            isInstitution ? "Institution Details" : "Farmer's Details",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          if (isInstitution)
            MyTextField(
              labelText: 'Institution name',
              controller: widget.controllers['institution'],
              inputType: TextInputType.name,
              validate: _validateName,
            ),
          if (!isInstitution)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyTextField(
                  labelText: 'First name',
                  controller: widget.controllers['fName'],
                  inputType: TextInputType.name,
                  validate: _validateName,
                ),
                MyTextField(
                  labelText: 'Last name',
                  validate: _validateName,
                  controller: widget.controllers['lName'],
                  inputType: TextInputType.name,
                ),
                DatePickerTextField(
                  labelText: 'Date Of Birth',
                  onDateSelected: _handleDateSelected,
                  initialDate:
                      DateTime(today.year - 18, today.month, today.day),
                  firstDate: DateTime(today.year - 110, today.month, today.day),
                  lastDate: DateTime(today.year - 2, today.month, today.day),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Gender',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 5,
                ),
                RadioButtons(
                  groupValue: gender,
                  firstBtnValue: 'Male',
                  secondBtnValue: 'Female',
                  firstBtnColor: Colors.blue,
                  secondBtnColor: Colors.pink,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
                //Text(gender ?? 'null'),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Does the farmer have a National ID?',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 5,
                ),
                RadioButtons(
                  groupValue: nationalID,
                  firstBtnValue: 'Yes',
                  secondBtnValue: 'No',
                  firstBtnColor: Colors.green[900],
                  secondBtnColor: Colors.deepOrange,
                  onChanged: (value) {
                    setState(() {
                      nationalID = value;
                    });
                  },
                ),
                if (nationalID == 'Yes')
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: kBlackButtonStyle,
                        onPressed: () async {
                          // //select image from either gallery or camera
                          // final selectedImage =
                          //     await kImagePicker.showBottomSheet(context);

                          // if (selectedImage != null) {
                          //   setState(() {
                          //     //add image to images
                          //     farmerIDImage = selectedImage;
                          //   });
                          // }
                        },
                        child: const Text('Take National ID Photo'),
                      ),
                      const SizedBox(height: 5),
                      //display image 1
                      farmerIDImage != null
                          ? Image.file(
                              File(farmerIDImage!.path),
                              height: 300,
                            )
                          : const Text(''),
                      const Text(
                        'Does the farmer\'s information match what is on the National ID?',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      RadioButtons(
                        groupValue: infoMatchID,
                        firstBtnValue: 'Yes',
                        secondBtnValue: 'No',
                        firstBtnColor: Colors.green[900],
                        secondBtnColor: Colors.deepOrange,
                        onChanged: (value) {
                          setState(() {
                            infoMatchID = value;
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
          const SizedBox(
            height: 16,
          ),
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              focusColor: Colors.grey[600],
              labelText: 'Farmer Address',
              labelStyle: TextStyle(color: Colors.grey[600]), // Label color
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
            controller: widget.controllers['address'],
            validator: _validateAddress,
            onTap: () async {
              var selectedVillage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFarmerAddressDialog(),
                ),
              );
              if (selectedVillage != null) {
                setState(() {
                  //_addressController.text = selectedVillage;
                });
              }
            },
          ),
          const SizedBox(
            height: 8,
          ),
          MyTextField(
            labelText: 'Phone Number',
            controller: widget.controllers['phone'],
            inputType: TextInputType.phone,
            validate: _validatePhoneNumber,
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Signed Contract with Kijani?',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 5,
          ),
          RadioButtons(
            groupValue: contract,
            firstBtnValue: 'Yes',
            secondBtnValue: 'No',
            firstBtnColor: Colors.green[900],
            secondBtnColor: Colors.deepOrange,
            onChanged: (value) {
              setState(() {
                contract = value;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Fully onboarded on FlexyPay?',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 5,
          ),
          RadioButtons(
            groupValue: onboarded,
            firstBtnValue: 'Yes',
            secondBtnValue: 'No',
            firstBtnColor: Colors.green[900],
            secondBtnColor: Colors.deepOrange,
            onChanged: (value) {
              setState(() {
                onboarded = value;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            "Next Of Kin's Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          MyTextField(
            labelText: 'First name',
            controller: widget.controllers['nkFName'],
            inputType: TextInputType.name,
            validate: _validateName,
          ),
          MyTextField(
            labelText: 'Last name',
            controller: widget.controllers['nkLName'],
            inputType: TextInputType.name,
            validate: _validateName,
          ),
          MyTextField(
            labelText: 'Phone Number',
            controller: widget.controllers['nkPhone'],
            inputType: TextInputType.phone,
            validate: _validatePhoneNumber,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //function to determine DOB
  void _handleDateSelected(DateTime date) {
    setState(() {
      //widget.co = date;
    });
  }

  String? _validateName(String? value) {
    if ((value == null || value.length < 3) && isInstitution == false) {
      return 'Please enter your name';
    } else if ((value == null || value.length < 3) && isInstitution == true) {
      return 'Please enter institution name';
    }
    const namePattern = r'^[A-Za-z ]+$';
    final regex = RegExp(namePattern);
    if (!regex.hasMatch(value!)) {
      return 'Enter a valid name';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    const phonePattern = r'^0\d{9}$';
    final regex = RegExp(phonePattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter farmer\'s address';
    }
    return null;
  }
}
