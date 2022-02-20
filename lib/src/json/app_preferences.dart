import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsmith/constants.dart';

part 'app_preferences.g.dart';

/// Preferences for the application.
@JsonSerializable()
class AppPreferences {
  /// Create an instance.
  const AppPreferences({
    required this.recentProjects,
  });

  /// Create an instance from a JSON object.
  factory AppPreferences.fromJson(Map<String, dynamic> json) =>
      _$AppPreferencesFromJson(json);

  /// Load an instance from shared preferences.
  factory AppPreferences.load(SharedPreferences preferences) {
    final data = preferences.getString(_key);
    if (data == null) {
      return AppPreferences(recentProjects: List<String>.empty(growable: true));
    }
    final json = jsonDecode(data) as JsonType;
    return AppPreferences.fromJson(json);
  }

  /// The preferences key to load JSON from.
  static const _key = 'preferences';

  /// A list of paths to recently opened projects.
  final List<String> recentProjects;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AppPreferencesToJson(this);

  /// Save this instance.
  void save(SharedPreferences preferences) {
    recentProjects
        .removeWhere((element) => File(element).existsSync() == false);
    final json = indentedJsonEncoder.convert(toJson());
    preferences.setString(_key, json);
  }
}
