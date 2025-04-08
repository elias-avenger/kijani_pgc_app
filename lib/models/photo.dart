class Photo {
  final String name;
  final String path;

  Photo({required this.name, required this.path});

  factory Photo.fromPath(String path) {
    return Photo(
      name: path.split('/').last,
      path: path,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
    };
  }
}
