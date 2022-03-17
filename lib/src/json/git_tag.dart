import 'package:json_annotation/json_annotation.dart';

import 'git_commit.dart';

part 'git_tag.g.dart';

/// A tag received from GitHub.
@JsonSerializable()
class GitTag {
  /// Create an instance.
  const GitTag({
    required this.name,
    required this.zipBallUrl,
    required this.tarBallUrl,
    required this.commit,
    required this.nodeId,
  });

  /// Create an instance from a JSON object.
  factory GitTag.fromJson(Map<String, dynamic> json) => _$GitTagFromJson(json);

  /// The name of the tag.
  final String name;

  /// The URL for getting a zip file.
  @JsonKey(name: 'zipball_url')
  final String zipBallUrl;

  /// The URL for getting a tar ball.
  @JsonKey(name: 'tarball_url')
  final String tarBallUrl;

  /// The commit that references this tag.
  final GitCommit commit;

  /// The node ID of this tag.
  @JsonKey(name: 'node_id')
  final String nodeId;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GitTagToJson(this);
}
