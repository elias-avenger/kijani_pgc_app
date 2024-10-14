class ImageNamesAndPaths {
  Map<String, dynamic> getImagesNamesAndPaths(
      {required Map<String, dynamic> imagesData}) {
    Map<String, dynamic> photosData = {};
    for (String image in imagesData.keys) {
      String imageName =
          "$image-${DateTime.now().millisecondsSinceEpoch}-${imagesData[image]?.name}";
      String imgPath = imagesData[image]!.path;
      photosData[image] = {
        'imageName': imageName,
        'imagePath': imgPath,
      };
    }
    return photosData;
  }
}
