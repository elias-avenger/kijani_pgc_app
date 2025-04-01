import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddFarmerAddressDialog extends StatefulWidget {
  const AddFarmerAddressDialog({super.key});

  @override
  State<AddFarmerAddressDialog> createState() => _AddFarmerAddressDialogState();
}

class _AddFarmerAddressDialogState extends State<AddFarmerAddressDialog> {
  List<Map<String, dynamic>> villageList = [];
  List<Map<String, dynamic>> filteredVillage = [];

  @override
  void initState() {
    super.initState();
    //getVillagesList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Farmer's Address"),
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 400,
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Where does the farmer come from?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Search Village",
                  hintText: 'Enter village name',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    try {
                      String searchValue = value.toLowerCase();
                      filteredVillage = villageList.where((village) {
                        var villageName = village['Name']?.toLowerCase() ?? '';
                        var parishName = village['Parish']?.toLowerCase() ?? '';
                        var subCounty =
                            village['Sub-County']?.toLowerCase() ?? '';
                        var district = village['District']?.toLowerCase() ?? '';
                        return villageName.contains(searchValue) ||
                            parishName.contains(searchValue) ||
                            subCounty.contains(searchValue) ||
                            district.contains(searchValue);
                      }).toList();

                      filteredVillage.sort((a, b) {
                        var aVillageName = a['Name']?.toLowerCase() ?? '';
                        var aParishName = a['Parish']?.toLowerCase() ?? '';
                        var aSubCounty = a['Sub-County']?.toLowerCase() ?? '';
                        var aDistrict = a['District']?.toLowerCase() ?? '';
                        var bVillageName = b['Name']?.toLowerCase() ?? '';
                        var bParishName = b['Parish']?.toLowerCase() ?? '';
                        var bSubCounty = b['Sub-County']?.toLowerCase() ?? '';
                        var bDistrict = b['District']?.toLowerCase() ?? '';

                        bool aExactMatch = aVillageName == searchValue ||
                            aParishName == searchValue ||
                            aSubCounty == searchValue ||
                            aDistrict == searchValue;
                        bool bExactMatch = bVillageName == searchValue ||
                            bParishName == searchValue ||
                            bSubCounty == searchValue ||
                            bDistrict == searchValue;

                        if (aExactMatch && !bExactMatch) {
                          return -1;
                        } else if (!aExactMatch && bExactMatch) {
                          return 1;
                        } else {
                          return 0;
                        }
                      });
                    } catch (e) {
                      if (kDebugMode) {
                        print('ERROR GOT ON CHANGE VALUE: $e');
                      }
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: filteredVillage.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.white,
                      title: Text("${filteredVillage[index]['Name']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${filteredVillage[index]['Parish']} - ${filteredVillage[index]['Sub-County']}",
                          ),
                          Text(
                            "${filteredVillage[index]['District']} District",
                          )
                        ],
                      ),
                      onTap: () async {
                        // Close the dialog with selected village
                        Navigator.of(context).pop(
                          filteredVillage[index]['ID'],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red[900],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void getVillagesList() async {
  //   List<Map<String, dynamic>> villagesData =
  //       await kLocalBase.getVillagesData();

  //   setState(() {
  //     villageList = villagesData;
  //   });
  //   filteredVillage = villageList;
  // }
}
