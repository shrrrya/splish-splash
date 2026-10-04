import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../providers/saved_provider.dart';

class PhotoTile extends StatelessWidget {
  final Photo photo;
  final String heroTag;
  final VoidCallback onTap;

  const PhotoTile({
    super.key,
    required this.photo,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final saved =
        context.select<SavedProvider, bool>((s) => s.isSaved(photo.id));
    final placeholderColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: photo.ratio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: photo.thumbUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 600,
                    fadeInDuration: const Duration(milliseconds: 250),
                    placeholder: (_, _) => Container(color: placeholderColor),
                      errorWidget: (_, _, _) => Container(
                      color: placeholderColor,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: saved ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}