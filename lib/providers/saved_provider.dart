import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo.dart';

class SavedProvider extends ChangeNotifier {
  final Map<int, Photo> _saved = {};
  String? _uid;

  /// Newest saved first.
  List<Photo> get items => _saved.values.toList().reversed.toList();
  int get count => _saved.length;
  bool isSaved(int id) => _saved.containsKey(id);

  Future<void> load(String uid) async {
    _uid = uid;
    _saved.clear();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_$uid');
    if (raw != null) {
      for (final j in jsonDecode(raw) as List) {
        final p = Photo.fromJson(j as Map<String, dynamic>);
        _saved[p.id] = p;
      }
    }
    notifyListeners();
  }

  void clear() {
    _uid = null;
    _saved.clear();
    notifyListeners();
  }

  Future<void> toggle(Photo photo) async {
    if (_uid == null) return;
    if (_saved.containsKey(photo.id)) {
      _saved.remove(photo.id);
    } else {
      _saved[photo.id] = photo;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final uid = _uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_$uid',
      jsonEncode(_saved.values.map((p) => p.toJson()).toList()),
    );
  }
}