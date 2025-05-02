import 'package:flutter/material.dart';
import 'package:kijani_pgc_app/components/widgets/dashboard_tile.dart';
import 'package:kijani_pgc_app/models/dashboard_tile.dart';

class DashboardTileGrid extends StatelessWidget {
  final List<DashboardTileData> tiles;

  const DashboardTileGrid({required this.tiles, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tiles
          .map((tile) => DashboardTile(
                title: tile.title,
                icon: tile.icon,
                count: tile.count,
                color: tile.color,
              ))
          .toList(),
    );
  }
}
