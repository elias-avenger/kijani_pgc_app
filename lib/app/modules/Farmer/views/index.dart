import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/data/models/farmer.dart';
import 'package:kijani_pmc_app/app/data/models/garden.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';

class FarmerDetailScreen extends StatelessWidget {
  const FarmerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Farmer farmer = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'images/kijani_logo.png',
            color: Colors.white,
          ),
        ),
        title: Text(
          farmer.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: kfGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Add action if needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildCoordinatorInfo(farmer),
            const SizedBox(height: 20),
            _buildGroupListTitle(),
            const SizedBox(height: 10),
            _buildGroupList(farmer),
          ],
        ),
      ),
    );
  }

  // Widget to display the coordinator's information
  Widget _buildCoordinatorInfo(Farmer farmer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          farmer.name,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kfGreen,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Gender: ${farmer.gender}",
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Contact: ${farmer.phone}",
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  // Widget to display the list of gardens
  Widget _buildGroupList(Farmer farmer) {
    if (farmer.gardens.isEmpty) {
      return const Center(
        child: Text(
          "No Gardens available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: farmer.gardens.length,
      itemBuilder: (context, index) {
        final garden = farmer.gardens[index];
        return _buildGroupCard(garden);
      },
    );
  }

  // Widget for each garden card
  Widget _buildGroupCard(Garden garden) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kfGreen.withOpacity(0.1),
          child: Icon(Icons.nature_people, color: kfGreen, size: 20),
        ),
        title: Text(
          "Garden ${garden.id.split('-').last.split('').last}",
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "Initial Planting: ${garden.initialPlantingDate}",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.toNamed(Routes.garden, arguments: garden);
        },
      ),
    );
  }

  // Title for the garden list
  Widget _buildGroupListTitle() {
    return Text(
      "Gardens",
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kfGreen,
      ),
    );
  }
}
