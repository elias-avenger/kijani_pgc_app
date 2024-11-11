import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/data/models/group.dart';
import 'package:kijani_pmc_app/app/data/models/parish_model.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';

class ParishDetailScreen extends StatelessWidget {
  const ParishDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Parish parish = Get.arguments;

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
          parish.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: kfGreen,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'report') {
                Get.toNamed(Routes.parishReport, arguments: parish);
              }
            },
            iconColor: Colors.white,
            itemBuilder: (BuildContext context) {
              return [
                if (Get.find<AuthController>().userRole == 'bc')
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.report,
                          color: kfGreen,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Submit Daily Parish Report',
                          style: GoogleFonts.lato(),
                        ),
                      ],
                    ),
                  )
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildCoordinatorInfo(parish),
            const SizedBox(height: 20),
            _buildSummaryCards(parish),
            const SizedBox(height: 20),
            if (Get.find<AuthController>().userRole == 'bc')
              _buildTaskSection(),
            const SizedBox(height: 20),
            _buildGroupListTitle(),
            const SizedBox(height: 10),
            _buildGroupList(parish),
          ],
        ),
      ),
    );
  }

  // Widget to display the coordinator's information
  Widget _buildCoordinatorInfo(Parish parish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Coordinator: ${parish.pcName}",
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kfGreen,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "${parish.name} Parish",
          style: GoogleFonts.lato(fontSize: 18),
        ),
      ],
    );
  }

  // Widget to display summary cards
  Widget _buildSummaryCards(Parish parish) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Potted', '2000', Icons.spa),
        _buildStatCard('Pricked', '2000', Icons.agriculture),
        _buildStatCard('Sorted', '2000', Icons.widgets),
        _buildStatCard('Distributed', '2000', Icons.local_shipping),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the list of groups
  Widget _buildGroupList(Parish parish) {
    if (parish.groups.isEmpty) {
      return const Center(
        child: Text(
          "No groups available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parish.groups.length,
      itemBuilder: (context, index) {
        final group = parish.groups[index];
        return _buildGroupCard(group);
      },
    );
  }

  // Widget for each group card
  Widget _buildGroupCard(Group group) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kfGreen.withOpacity(0.1),
          child: Icon(Icons.arrow_forward_ios, color: kfGreen, size: 20),
        ),
        title: Text(
          group.id.split('|').first,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "${group.id.split('|').last.split('-').first}   Season ${group.id.split('|').last.split('-').last.split('').last}",
          style: GoogleFonts.lato(fontSize: 14, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.toNamed(Routes.group, arguments: group);
        },
      ),
    );
  }

  // Title for the group list
  Widget _buildGroupListTitle() {
    return Text(
      "Groups",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kfGreen,
      ),
    );
  }

  // Widget to display task section
  Widget _buildTaskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tasks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kfGreen,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to a task list if needed
              },
              child: Text(
                "View all →",
                style: TextStyle(
                  fontSize: 14,
                  color: kfGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTaskIndicator(Colors.green, 'Completed', '5'),
            _buildTaskIndicator(Colors.blue, 'In Progress', '5'),
            _buildTaskIndicator(Colors.red, 'Overdue', '5'),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kfGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Add new task logic
            },
            child: const Text("Assign New Task"),
          ),
        ),
      ],
    );
  }

  // Helper method for task indicators
  Widget _buildTaskIndicator(Color color, String label, String count) {
    return Row(
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor: color,
        ),
        const SizedBox(width: 5),
        Text(
          "$label: $count",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
