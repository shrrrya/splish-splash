import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/photo_feed_controller.dart';
import '../services/photo_service.dart';
import '../widgets/photo_grid.dart';
import 'photo_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _text = TextEditingController();
  Timer? _debounce;
  PhotoFeedController? _results;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    _results?.dispose();
    super.dispose();
  }

  // Runs on every keystroke, but only fires a search after the user
  // has stopped typing for 500 ms.
  void _onChanged(String value) {
    setState(() {}); // refreshes the clear (x) button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  void _search(String value) {
    final q = value.trim();
    if (q == _query) return;
    _query = q;

    final old = _results;
    if (q.isEmpty) {
      setState(() => _results = null);
    } else {
      final c = PhotoFeedController(
        (page) => PhotoService().fetch(query: q, page: page),
      );
      c.loadMore();
      setState(() => _results = c);
    }
    // Dispose the previous controller after the old grid has detached.
    WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
  }

  void _clear() {
    _text.clear();
    _debounce?.cancel();
    _search('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _text,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                _search(v);
              },
              textInputAction: TextInputAction.search,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Search photos',
                counterText: '',
                filled: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _text.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clear,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: results == null
                ? const _SearchHint()
                : NotificationListener<ScrollStartNotification>(
                    onNotification: (_) {
                      FocusScope.of(context).unfocus(); // hide keyboard on scroll
                      return false;
                    },
                    child: PhotoGrid(
                      key: ValueKey(results), // fresh grid (and scroll position) per search
                      controller: results,
                      heroPrefix: 'search',
                      emptyMessage: 'No results for "$_query".',
                      onTapPhoto: (photo) => Navigator.of(context).pushNamed(
                        '/detail',
                        arguments: PhotoDetailArgs(photo, 'search-${photo.id}'),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_search_rounded,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          const Text('Search for photos'),
        ],
      ),
    );
  }
}