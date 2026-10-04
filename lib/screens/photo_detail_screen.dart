import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo.dart';
import '../providers/saved_provider.dart';

class PhotoDetailArgs {
  final Photo photo;
  final String heroTag;
  const PhotoDetailArgs(this.photo, this.heroTag);
}

class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PhotoDetailArgs;
    final photo = args.photo;
    final theme = Theme.of(context);
    final initial =
        photo.photographer.isNotEmpty ? photo.photographer[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Hero(
                  tag: args.heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: CachedNetworkImage(
                        imageUrl: photo.largeUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        // Show the already-cached thumbnail while the big one loads.
                        placeholder: (_, _) => CachedNetworkImage(
                          imageUrl: photo.thumbUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                        errorWidget: (_, _, _) =>
                            const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text(initial)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.photographer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Photo via Pixabay',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _SaveButton(photo: photo)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Photo by ${photo.photographer} on Pixabay: ${photo.pageUrl}',
                            ),
                          ),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final Photo photo;
  const _SaveButton({required this.photo});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  double _scale = 1;

  Future<void> _onTap() async {
    final saved = context.read<SavedProvider>();
    final wasSaved = saved.isSaved(widget.photo.id);
    HapticFeedback.mediumImpact();
    saved.toggle(widget.photo);
    if (!wasSaved) {
      // Little "pop" when saving.
      setState(() => _scale = 1.35);
      await Future.delayed(const Duration(milliseconds: 160));
      if (mounted) setState(() => _scale = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Correct state from the very first frame, and live afterwards.
    final isSaved = context
        .select<SavedProvider, bool>((s) => s.isSaved(widget.photo.id));
    return FilledButton.icon(
      onPressed: _onTap,
      style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14)),
      icon: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
      ),
      label: Text(isSaved ? 'Saved' : 'Save'),
    );
  }
}