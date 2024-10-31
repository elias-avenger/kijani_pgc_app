import 'package:get/get.dart';

class ReportController extends GetxController {
  // Reactive maps for different categories
  var activities = <String, bool>{
    'Pest and disease control': false,
    'Weeding': false,
    'Pruning': false,
    'Thinning': false,
    'Farmer contract signing': false,
    'Fire line creation': false,
    'Identifying outstanding farmers': false,
    'Groups mobilization': false,
    'Farmers mobilization': false,
  }.obs;

  var gardenChallenges = <String, bool>{
    'Gardens full of weed': false,
    'Garden not pruned': false,
    'Garden poorly pruned': false,
    'Trees planted at poor spacing': false,
    'Empty pots left in the garden during planting': false,
    'Mixing of species by farmers during planting': false,
    'Trees affected by disease': false,
    'Trees affected by pests': false,
    'Fireline not created at all': false,
    'Fireline not properly created': false,
    'Garden not thinned': false,
    'Garden poorly thinned': false,
    'Farmers cut down trees for their own needs': false,
  }.obs;

  var farmerChallenges = <String, bool>{
    'Demanding for a copy of their contract': false,
    'Refused to sign contract': false,
    'Farmer demanded for money': false,
    'Complaints about delay of incentive payment': false,
    'Misled by other organizations': false,
    'Farmer not willing to provide equipment': false,
  }.obs;

  // Individual challenges as a list
  var individualChallenges = [
    'Large working area',
    'Field facilitation delays',
    'Insecurity',
    'Wild animal attacks',
    'House rent not enough',
  ];

  // State tracking map for individual challenges
  var selectedIndividualChallenges = <String, bool>{}.obs;

  // Maps to store details for each category when selected
  var activityDetails = <String, dynamic>{}.obs;
  var gardenChallengeDetails = <String, dynamic>{}.obs;
  var farmerChallengeDetails = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the state of each individual challenge as unselected
    for (var challenge in individualChallenges) {
      selectedIndividualChallenges[challenge] = false;
    }
  }

  // General method to toggle the item state in any category
  void toggleItem(String category, String item, bool value) {
    RxMap<String, dynamic>? map = _getMapByCategory(category);
    if (map != null) {
      map[item] = value;
      if (!value) {
        // Clear details if the item is deselected
        _getDetailsMapByCategory(category)?.remove(item);
      }
    }
  }

  // General method to update details for a selected item in any category
  void updateItemDetails(String category, String item, dynamic details) {
    RxMap<String, dynamic>? detailsMap = _getDetailsMapByCategory(category);
    if (detailsMap != null) {
      detailsMap[item] = details;
    }
  }

  // General method to get a list of selected items with their details for a category
  List<Map<String, dynamic>> getSelectedItemsWithDetails(String category) {
    RxMap<String, dynamic>? map = _getMapByCategory(category);
    RxMap<String, dynamic>? detailsMap = _getDetailsMapByCategory(category);
    if (map == null || detailsMap == null) return [];

    return map.entries
        .where((entry) => entry.value)
        .map((entry) => {
              'item': entry.key,
              'details': detailsMap[entry.key],
            })
        .toList();
  }

  // Helper method to get the reactive map by category name
  RxMap<String, dynamic>? _getMapByCategory(String category) {
    switch (category) {
      case 'activities':
        return activities;
      case 'gardenChallenges':
        return gardenChallenges;
      case 'farmerChallenges':
        return farmerChallenges;
      case 'individualChallenges':
        return selectedIndividualChallenges;
      default:
        return null;
    }
  }

  // Helper method to get the details map by category name
  RxMap<String, dynamic>? _getDetailsMapByCategory(String category) {
    switch (category) {
      case 'activities':
        return activityDetails;
      case 'gardenChallenges':
        return gardenChallengeDetails;
      case 'farmerChallenges':
        return farmerChallengeDetails;
      default:
        return null;
    }
  }
}
