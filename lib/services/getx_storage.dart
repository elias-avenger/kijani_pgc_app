import 'package:get_storage/get_storage.dart';

const String kUserDataKey = 'user_data';
const String kParishDataKey = 'parish_data';
const String kUnsyncedReportsKey = 'unsynced_reports';

class StorageService {
  // Private instance of GetStorage for local key-value storage
  final GetStorage _storage = GetStorage();

  /// Initializes the GetStorage instance.
  /// Call this method before using any storage operations to ensure GetStorage is ready.
  /// Typically called once at app startup.
  Future<void> init() async {
    await GetStorage.init();
  }

  /// Saves an entity under a specific key and ID in local storage.
  /// Updates the existing data if the key already exists, adding or overwriting the entity for the given ID.
  /// - [key]: The category or type of entities (e.g., 'parishes', 'users') under which the entity is stored.
  /// - [id]: The unique identifier for the entity (e.g., a parish ID or user ID).
  /// - [entity]: The entity object to be stored (not used directly; passed to toJson).
  /// - [toJson]: A function that converts the entity to a Map<String, dynamic> for storage (e.g., User.tojson).
  /// Throws an error (caught internally) if storage fails; check logs for details.
  Future<void> saveEntity(
    String key,
    String id,
    dynamic entity,
    Map<String, dynamic> Function() toJson,
  ) async {
    try {
      // Fetch existing data under the key; default to empty map if null
      Map<String, dynamic> currentData =
          _storage.read(key) ?? <String, dynamic>{};
      // Store the entity's JSON representation under its ID
      currentData[id] = toJson();
      // Persist the updated data to storage
      await _storage.write(key, currentData);
    } catch (e) {
      print('Error saving entity ($key, $id): $e');
    }
  }

  /// Fetches a single entity by its key and ID from local storage.
  /// - [key]: The category or type of entities (e.g., 'parishes') where the entity is stored.
  /// - [id]: The unique identifier of the entity to retrieve.
  /// - [fromJson]: A function that converts the stored Map<String, dynamic> back to the desired entity type(e.g, Parish.fromJson).
  /// Returns the entity if found, or null if the key or ID doesn't exist or an error occurs.
  dynamic fetchEntity(
    String key,
    String id,
    dynamic Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      // Read the data stored under the key
      Map<String, dynamic>? storedData = _storage.read(key);
      // Check if data exists and contains the specified ID
      if (storedData != null && storedData[id] != null) {
        // Convert the stored data to the entity type and return it
        return fromJson(storedData[id] as Map<String, dynamic>);
      }
      // Return null if no data is found
      return null;
    } catch (e) {
      print('Error fetching entity ($key, $id): $e');
      return null;
    }
  }

  /// Fetches all entities stored under a specific key.
  /// - [key]: The category or type of entities (e.g., 'parishes') to retrieve.
  /// - [fromJson]: A function that converts each stored Map<String, dynamic> to the desired entity type(e.g., Parish.fromJson --this is from the Parish Model).
  /// Returns a Map where keys are entity IDs and values are the converted entities.
  /// Returns an empty map if no data exists or an error occurs.
  Map<String, dynamic> fetchAllEntities(
    String key,
    dynamic Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      // Read the data stored under the key
      Map<String, dynamic>? storedData = _storage.read(key);
      // If data exists, convert each entry to the entity type
      if (storedData != null) {
        return storedData.map(
          (id, data) => MapEntry(id, fromJson(data as Map<String, dynamic>)),
        );
      }
      // Return empty map if no data is found
      return {};
    } catch (e) {
      print('Error fetching all entities ($key): $e');
      return {};
    }
  }

  /// Deletes an entity from storage by its key and ID.
  /// - [key]: The category or type of entities (e.g., 'parishes') containing the entity.
  /// - [id]: The unique identifier of the entity to delete.
  /// Returns true if deletion succeeds (even if the key is removed entirely when empty),
  /// or false if an error occurs.
  Future<bool> deleteEntity(String key, String id) async {
    try {
      // Fetch existing data under the key; default to empty map if null
      Map<String, dynamic> currentData =
          _storage.read(key) ?? <String, dynamic>{};
      // Remove the entity with the specified ID
      currentData.remove(id);
      // If the map is now empty, remove the key entirely from storage
      if (currentData.isEmpty) {
        await _storage.remove(key);
        return true;
      } else {
        // Otherwise, update the storage with the modified map
        await _storage.write(key, currentData);
        return true;
      }
    } catch (e) {
      print('Error deleting entity ($key, $id): $e');
      return false;
    }
  }

  /// Clears all entities stored under a specific key.
  /// - [key]: The category or type of entities (e.g., 'parishes') to clear.
  /// Returns true if the key is successfully removed, or false if an error occurs.
  Future<bool> clearEntities(String key) async {
    try {
      // Remove the entire key and its associated data from storage
      await _storage.remove(key);
      return true;
    } catch (e) {
      print('Error clearing entities ($key): $e');
      return false;
    }
  }

  /// Clears all data from GetStorage (e.g., for logout or reset).
  /// Returns true if all storage is successfully cleared, or false if an error occurs.
  Future<bool> clearAll() async {
    try {
      // Erase all data in GetStorage
      await _storage.erase();
      return true;
    } catch (e) {
      print('Error clearing all storage: $e');
      return false;
    }
  }
}
