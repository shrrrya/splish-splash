import 'package:flutter/foundation.dart';
import '../models/photo.dart';
import '../services/photo_service.dart';

typedef PageFetcher = Future<List<Photo>> Function(int page);

/// Holds a paginated list of photos plus its loading/error state.
/// Used by the feed now, and by search later.
class PhotoFeedController extends ChangeNotifier {
  final PageFetcher fetchPage;
  PhotoFeedController(this.fetchPage);

  final List<Photo> photos = [];
  int _page = 1;
  bool _disposed = false;

  bool isLoading = false;
  bool isRefreshing = false;
  bool hasMore = true;
  bool hasError = false;

  bool get isInitialLoading => isLoading && photos.isEmpty;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    hasError = false;
    _notify();
    try {
      final batch = await fetchPage(_page);
      final existing = photos.map((p) => p.id).toSet();
      photos.addAll(batch.where((p) => !existing.contains(p.id)));
      _page++;
      if (batch.length < PhotoService.perPage) hasMore = false;
    } catch (_) {
      hasError = true;
    }
    isLoading = false;
    _notify();
  }

  /// Reloads from page 1. Returns false if it failed (old photos are kept).
  Future<bool> refresh() async {
    if (isLoading) return true;
    isLoading = true;
    isRefreshing = true;
    _notify();
    var ok = true;
    try {
      final batch = await fetchPage(1);
      photos
        ..clear()
        ..addAll(batch);
      _page = 2;
      hasMore = batch.length >= PhotoService.perPage;
      hasError = false;
    } catch (_) {
      ok = false;
    }
    isLoading = false;
    isRefreshing = false;
    _notify();
    return ok;
  }
}