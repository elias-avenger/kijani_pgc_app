class PlantingUpdate {
  final String id;
  final String scientificName;
  final int received;
  final int planted;
  final int surviving;
  final int replaced;
  final int lostTrees;
  final int lostSeedlings;
  final String latestReceivedDate;
  final int latestReceived;
  final String latestPlantedDate;
  final int latestPlanted;
  final String latestSurvivingDate;
  final int survivingTrees;

  PlantingUpdate({
    required this.id,
    required this.scientificName,
    required this.received,
    required this.planted,
    required this.surviving,
    required this.replaced,
    required this.lostTrees,
    required this.lostSeedlings,
    required this.latestReceivedDate,
    required this.latestReceived,
    required this.latestPlantedDate,
    required this.latestPlanted,
    required this.latestSurvivingDate,
    required this.survivingTrees,
  });

  factory PlantingUpdate.fromJson(Map<String, dynamic> json) {
    print("PARSING PLANTING UPDATE: $json");
    try {
      return PlantingUpdate(
        id: json['ID'] ?? 'No ID',
        scientificName: _getStringFromList(json, 'Scientific Name'),
        received: _getIntFromJson(json, 'Received'),
        planted: _getIntFromJson(json, 'Planted'),
        surviving: _getIntFromJson(json, 'Surviving'),
        replaced: _getIntFromJson(json, 'Replaced'),
        lostTrees: _getIntFromJson(json, 'Lost Trees'),
        lostSeedlings: _getIntFromJson(json, 'Lost Seedlings'),
        latestReceivedDate: _getStringFromJson(json, 'Latest Received Date'),
        latestReceived: _getIntFromJson(json, 'Latest Received'),
        latestPlantedDate: _getStringFromJson(json, 'Latest Planted Date'),
        latestPlanted: _getIntFromJson(json, 'Latest Planted'),
        latestSurvivingDate: _getStringFromJson(json, 'Latest Surviving Date'),
        survivingTrees: _getIntFromJson(json, 'Surviving Trees'),
      );
    } catch (e) {
      // Log the error and return a default PlantingUpdate object with sensible defaults
      print("Error parsing PlantingUpdate: $e");
      return PlantingUpdate(
        id: 'Error',
        scientificName: 'Error',
        received: 0,
        planted: 0,
        surviving: 0,
        replaced: 0,
        lostTrees: 0,
        lostSeedlings: 0,
        latestReceivedDate: 'Not available',
        latestReceived: 0,
        latestPlantedDate: 'Not available',
        latestPlanted: 0,
        latestSurvivingDate: 'Not available',
        survivingTrees: 0,
      );
    }
  }

  // Helper method to safely extract string values from JSON
  static String _getStringFromJson(Map<String, dynamic> json, String key) {
    try {
      var value = json[key];
      if (value != null && value is String) {
        return value;
      }
    } catch (e) {
      print("Error extracting string value for $key: $e");
    }
    return 'Not available';
  }

  // Helper method to safely extract integer values from JSON
  static int _getIntFromJson(Map<String, dynamic> json, String key) {
    try {
      var value = json[key];
      if (value != null) {
        if (value is int) {
          return value;
        } else if (value is String) {
          return int.tryParse(value) ?? 0;
        }
      }
    } catch (e) {
      print("Error extracting integer value for $key: $e");
    }
    return 0;
  }

  // Helper method to safely extract string values from a list in JSON
  static String _getStringFromList(Map<String, dynamic> json, String key) {
    try {
      if (json.containsKey(key) &&
          json[key] is List &&
          (json[key] as List).isNotEmpty) {
        return (json[key] as List).first.toString();
      }
    } catch (e) {
      print("Error extracting string from list for $key: $e");
    }
    return 'Not available';
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Scientific Name': scientificName,
      'Received': received,
      'Planted': planted,
      'Surviving': surviving,
      'Replaced': replaced,
      'Lost Trees': lostTrees,
      'Lost Seedlings': lostSeedlings,
      'Latest Received Date': latestReceivedDate,
      'Latest Received': latestReceived,
      'Latest Planted Date': latestPlantedDate,
      'Latest Planted': latestPlanted,
      'Latest Surviving Date': latestSurvivingDate,
      'Surviving Trees': survivingTrees,
    };
  }
}
