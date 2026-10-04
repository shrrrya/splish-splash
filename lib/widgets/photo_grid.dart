import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/photo.dart';
import '../providers/photo_feed_controller.dart';
import 'photo_tile.dart';

class PhotoGrid extends StatefulWidget {
  final PhotoFeedController controller;
  final String heroPrefix;
  final String emptyMessage;
  final void Function(Photo photo) onTapPhoto;

  const PhotoGrid({
    super.key,
    required this.controller,
    required this.heroPrefix,
    required this.emptyMessage,
    required this.onTapPhoto,
  });

  @override
  State<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 600) {
      widget.controller.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    final ok = await widget.controller.refresh();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't refresh. Check your connection.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        if (c.isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.photos.isEmpty && c.hasError) {
          return _Message(
            icon: Icons.wifi_off_rounded,
            text: "Couldn't load photos.",
            actionLabel: 'Retry',
            onAction: c.loadMore,
          );
        }
        if (c.photos.isEmpty && !c.isLoading) {
          return _Message(
            icon: Icons.image_not_supported_outlined,
            text: widget.emptyMessage,
          );
        }
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: c.photos.length,
                  itemBuilder: (context, i) {
                    final p = c.photos[i];
                    final tag = '${widget.heroPrefix}-${p.id}';
                    return PhotoTile(
                      key: ValueKey(tag),
                      photo: p,
                      heroTag: tag,
                      onTap: () => widget.onTapPhoto(p),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: _footer(c)),
            ],
          ),
        );
      },
    );
  }

  Widget _footer(PhotoFeedController c) {
    if (c.isLoading && !c.isRefreshing) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (c.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Couldn't load more photos."),
            TextButton(onPressed: c.loadMore, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (!c.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text("You've reached the end")),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}