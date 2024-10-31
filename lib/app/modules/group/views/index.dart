import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/data/models/farmer.dart';
import 'package:kijani_pmc_app/app/data/models/group.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Group group = Get.arguments;

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
          group.name,
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
            _buildCoordinatorInfo(group),
            const SizedBox(height: 20),
            _buildSummaryCards(group),
            const SizedBox(height: 20),
            _buildFarmerListTitle(),
            const SizedBox(height: 10),
            _buildGroupList(group),
          ],
        ),
      ),
    );
  }

  // Widget to display the coordinator's information
  Widget _buildCoordinatorInfo(Group group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Group Name: ${group.name}",
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kfGreen,
          ),
        ),
        const SizedBox(height: 5),
        if (group.lastVisit != 'Not available')
          Row(
            children: [
              Text(
                "Last Visited: ${group.lastVisit.split('T').first}",
                style:
                    GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 5),
              Text(
                "at ${group.lastVisit.split('T').last.split('.').first}",
                style:
                    GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
      ],
    );
  }

  // Widget to display summary cards
  Widget _buildSummaryCards(Group group) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Potted', group.potted.toString(), Icons.spa),
        _buildStatCard('Pricked', group.pricked.toString(), Icons.agriculture),
        _buildStatCard('Sorted', group.sorted.toString(), Icons.widgets),
        _buildStatCard(
            'Distributed', group.distributed.toString(), Icons.local_shipping),
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
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the list of farmers
  Widget _buildGroupList(Group group) {
    if (group.farmers.isEmpty) {
      return const Center(
        child: Text(
          "No farmers available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: group.farmers.length,
      itemBuilder: (context, index) {
        final farmer = group.farmers[index];
        return _buildFarmerCard(farmer);
      },
    );
  }

  // Widget for each farmer card
  Widget _buildFarmerCard(Farmer farmer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kfGreen.withOpacity(0.1),
          child: Icon(Icons.person, color: kfGreen, size: 20),
        ),
        title: Text(
          farmer.name,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "${farmer.gardens.length} gardens",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.toNamed(Routes.farmer, arguments: farmer);
        },
      ),
    );
  }

  // Title for the farmer list
  Widget _buildFarmerListTitle() {
    return Text(
      "Farmers",
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kfGreen,
      ),
    );
  }
}
