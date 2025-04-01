import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badgeCount;

  const AppDrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badgeCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(title),
      trailing: badgeCount != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(20)),
              child: Text(
                badgeCount.toString(),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 20),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
