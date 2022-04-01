import 'package:json_annotation/json_annotation.dart';

part 'git_commit.g.dart';

/// A reference to a git commit.
@JsonSerializable()
class GitCommit {
  /// Create an instance.
  const GitCommit({
    required this.sha,
    required this.url,
  });

  /// Create an instance from a JSON object.
  factory GitCommit.fromJson(final Map<String, dynamic> json) =>
      _$GitCommitFromJson(json);

  /// The hash of the commit.
  final String sha;

  /// The URL for the commit.
  final String url;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GitCommitToJson(this);
}
