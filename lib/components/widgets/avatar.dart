import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DynamicCircleAvatar extends StatelessWidget {
  final String imageUrl;

  const DynamicCircleAvatar({
    super.key,
    required this.imageUrl,
  });

  // Simple URL validation
  bool _isValidUrl(String url) {
    return url.isNotEmpty && Uri.tryParse(url)?.hasAuthority == true;
  }

  @override
  Widget build(BuildContext context) {
    // Use a fallback if the URL is invalid
    final imageProvider = _isValidUrl(imageUrl)
        ? CachedNetworkImageProvider(imageUrl)
        : const AssetImage('images/kijani_logo.png') as ImageProvider;

    return FutureBuilder(
      future: _isValidUrl(imageUrl)
          ? precacheImage(CachedNetworkImageProvider(imageUrl), context)
          : null, // Skip precaching if URL is invalid
      builder: (context, snapshot) {
        return CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: snapshot.connectionState == ConnectionState.done &&
                  snapshot.error == null &&
                  _isValidUrl(imageUrl)
              ? CachedNetworkImageProvider(imageUrl)
              : const AssetImage('images/kijani_logo.png') as ImageProvider,
        );
      },
    );
  }
}
