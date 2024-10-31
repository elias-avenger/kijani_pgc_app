import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/data/models/garden.dart';
import 'package:kijani_pmc_app/app/data/models/planting_update.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';

class GardenDetailScreen extends StatelessWidget {
  const GardenDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Garden garden = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'images/kijani_logo.png',
            color: Colors.white,
          ),
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
            _buildGardenInfo(garden),
            const SizedBox(height: 20),
            _buildSummaryCards(garden),
            const SizedBox(height: 20),
            _buildUpdateListTitle(),
            const SizedBox(height: 10),
            _buildUpdateList(garden),
          ],
        ),
      ),
    );
  }

  // Widget to display the garden's information
  Widget _buildGardenInfo(Garden garden) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Garden ${garden.id.split('-').last.split('').last}",
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kfGreen,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Initial Planting Date: ${garden.initialPlantingDate}",
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(
          "Is Boundary: ${garden.isBoundary ? 'Yes' : 'No'}",
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(
          "Center Point: ${garden.center}",
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  // Widget to display summary cards for garden data
  Widget _buildSummaryCards(Garden garden) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
            'Received', garden.received.toString(), Icons.local_florist),
        _buildStatCard('Planted', garden.planted.toString(), Icons.spa),
        _buildStatCard('Surviving', garden.surviving.toString(), Icons.nature),
        _buildStatCard('Replaced', garden.replaced.toString(), Icons.autorenew),
      ],
    );
  }

  // Helper method for summary cards
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kfGreen, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the title for the planting updates list
  Widget _buildUpdateListTitle() {
    return Text(
      "Planting Updates",
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kfGreen,
      ),
    );
  }

  // Widget to display the list of planting updates
  Widget _buildUpdateList(Garden garden) {
    if (garden.updates.isEmpty) {
      return const Center(
        child: Text(
          "No planting updates available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: garden.updates.length,
      itemBuilder: (context, index) {
        final update = garden.updates[index];
        return _buildUpdateCard(update);
      },
    );
  }

  // Widget for each planting update card
  Widget _buildUpdateCard(PlantingUpdate update) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kfGreen.withOpacity(0.1),
          child: Icon(Icons.update, color: kfGreen, size: 20),
        ),
        title: Text(
          update.id.split('--').last,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              "Planted: ${update.latestPlanted}",
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
            ),
            Text(
              "Received: ${update.latestReceived}",
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
            ),
            Text(
              "Surviving: ${update.surviving}",
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle navigation if needed
        },
      ),
    );
  }
}
