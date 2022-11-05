import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});
  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHightWidth = kIsWeb ? 180 : 110;
    double iconSize = kIsWeb ? 90 : 55;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0).copyWith(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => navigateToType(context, "image"),
              child: SizedBox(
                height: cardHightWidth,
                width: cardHightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 16,
                  color: currentTheme.backgroundColor,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => navigateToType(context, "text"),
              child: SizedBox(
                height: cardHightWidth,
                width: cardHightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 16,
                  color: currentTheme.backgroundColor,
                  child: Center(
                    child: Icon(
                      Icons.font_download_outlined,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => navigateToType(context, "link"),
              child: SizedBox(
                height: cardHightWidth,
                width: cardHightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 10,
                  color: currentTheme.backgroundColor,
                  child: Center(
                    child: Icon(
                      Icons.link_outlined,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
