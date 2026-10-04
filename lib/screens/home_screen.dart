import 'package:flutter/material.dart';
import '../providers/photo_feed_controller.dart';
import '../services/photo_service.dart';
import 'photo_detail_screen.dart';
import '../widgets/photo_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PhotoFeedController _feed =
      PhotoFeedController((page) => PhotoService().fetch(page: page));

  @override
  void initState() {
    super.initState();
    _feed.loadMore();
  }

  @override
  void dispose() {
    _feed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'SplishSplash',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PhotoGrid(
              controller: _feed,
              heroPrefix: 'feed',
              emptyMessage: 'No photos found.',
              // Temporary: tapping toggles save so we can test the saved logic.
              // Next step replaces this with the photo detail screen.
              onTapPhoto: (photo) => Navigator.of(context).pushNamed(
                '/detail',
                arguments: PhotoDetailArgs(photo, 'feed-${photo.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}