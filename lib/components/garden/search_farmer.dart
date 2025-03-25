import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFarmerWidget extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onFarmerSelected;

  const SearchFarmerWidget({super.key, required this.onFarmerSelected});

  @override
  State<SearchFarmerWidget> createState() => _SearchFarmerWidgetState();
}

class _SearchFarmerWidgetState extends State<SearchFarmerWidget> {
  List<Map<String, dynamic>> farmersList = [];
  List<Map<String, dynamic>> filteredFarmers = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Add a garden for a farmer who is already registered",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff23566d),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Search Farmer",
                    hintText: 'Enter farmer name',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      try {
                        filteredFarmers = farmersList.where((farmer) {
                          var firstName =
                              farmer['First Name']?.toLowerCase() ?? '';
                          var lastName =
                              farmer['Last Name']?.toLowerCase() ?? '';
                          var institution =
                              farmer['Institution Name']?.toLowerCase() ?? '';
                          return firstName.contains(value.toLowerCase()) ||
                              lastName.contains(value.toLowerCase()) ||
                              institution.contains(value.toLowerCase());
                        }).toList();
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to search farmer',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        if (kDebugMode) {
                          print('ERROR GOT ON CHANGE VALUE:$e');
                        }
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: filteredFarmers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            "${filteredFarmers[index]['Institution'] != null ? filteredFarmers[index]['Institution Name'] : filteredFarmers[index]['First Name'] + ' ' + filteredFarmers[index]['Last Name']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Phone: ${filteredFarmers[index]['Phone Number']}",
                            ),
                            Text("${filteredFarmers[index]['Farmer Address']}"),
                          ],
                        ),
                        onTap: () {
                          widget.onFarmerSelected(filteredFarmers[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void getFarmersList() async {
    //TODO: fetch the farmerData from getx controller.
  }
}
