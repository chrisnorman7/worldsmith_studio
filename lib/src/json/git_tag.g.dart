// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitTag _$GitTagFromJson(Map<String, dynamic> json) => GitTag(
      name: json['name'] as String,
      zipBallUrl: json['zipball_url'] as String,
      tarBallUrl: json['tarball_url'] as String,
      commit: GitCommit.fromJson(json['commit'] as Map<String, dynamic>),
      nodeId: json['node_id'] as String,
    );

Map<String, dynamic> _$GitTagToJson(GitTag instance) => <String, dynamic>{
      'name': instance.name,
      'zipball_url': instance.zipBallUrl,
      'tarball_url': instance.tarBallUrl,
      'commit': instance.commit,
      'node_id': instance.nodeId,
    };
