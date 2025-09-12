import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// Dynamic menu action model
class AppMenuAction {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool visible;

  const AppMenuAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.visible = true,
  });
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.menuActions = const <AppMenuAction>[],
    this.onBack,
  });

  final String title;
  final List<AppMenuAction> menuActions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final visible = menuActions.where((a) => a.visible).toList();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: onBack ?? () => Get.back(),
        icon: const Icon(HugeIcons.strokeRoundedCircleArrowLeft01),
        color: Colors.black,
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      actions: [
        if (visible.isNotEmpty)
          PopupMenuButton<AppMenuAction>(
            tooltip: 'Menu',
            icon: const Icon(
              HugeIcons.strokeRoundedMoreVerticalCircle02,
              color: Colors.black,
            ),
            onSelected: (AppMenuAction item) => item.onTap(),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Color(0xFFE6E6E6),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 300,
            ),
            position: PopupMenuPosition.under,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<AppMenuAction>>[
              for (final AppMenuAction item in visible)
                PopupMenuItem<AppMenuAction>(
                  value: item,
                  enabled: item.enabled,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: <Widget>[
                      Icon(item.icon, color: Colors.black),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
