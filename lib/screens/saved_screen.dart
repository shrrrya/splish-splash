import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/saved_provider.dart';
import '../widgets/photo_tile.dart';
import 'photo_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<SavedProvider>().items;
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Saved',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        const Text('Nothing saved yet'),
                        const SizedBox(height: 4),
                        Text('Photos you save will show up here',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : MasonryGridView.count(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final p = items[i];
                      final tag = 'saved-${p.id}';
                      return PhotoTile(
                        key: ValueKey(tag),
                        photo: p,
                        heroTag: tag,
                        onTap: () => Navigator.of(context).pushNamed(
                          '/detail',
                          arguments: PhotoDetailArgs(p, tag),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}