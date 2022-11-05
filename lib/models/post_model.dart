import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String type;
  final String communityName;
  final String communityProfile;
  final List<String> upVotes;
  final List<String> downVotes;
  final int commentCount;
  final String userName;
  final String uid;
  final DateTime createdAt;
  final List<String> awards;
  Post({
    required this.id,
    required this.title,
    this.link,
    this.description,
    required this.type,
    required this.communityName,
    required this.communityProfile,
    required this.upVotes,
    required this.downVotes,
    required this.commentCount,
    required this.userName,
    required this.uid,
    required this.createdAt,
    required this.awards,
  });

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? type,
    String? communityName,
    String? communityProfile,
    List<String>? upVotes,
    List<String>? downVotes,
    int? commentCount,
    String? userName,
    String? uid,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      type: type ?? this.type,
      communityName: communityName ?? this.communityName,
      communityProfile: communityProfile ?? this.communityProfile,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      commentCount: commentCount ?? this.commentCount,
      userName: userName ?? this.userName,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'title': title});
    if (link != null) {
      result.addAll({'link': link});
    }
    if (description != null) {
      result.addAll({'description': description});
    }
    result.addAll({'type': type});
    result.addAll({'communityName': communityName});
    result.addAll({'communityProfile': communityProfile});
    result.addAll({'upVotes': upVotes});
    result.addAll({'downVotes': downVotes});
    result.addAll({'commentCount': commentCount});
    result.addAll({'userName': userName});
    result.addAll({'uid': uid});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'awards': awards});

    return result;
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      description: map['description'],
      type: map['type'] ?? '',
      communityName: map['communityName'] ?? '',
      communityProfile: map['communityProfile'] ?? '',
      upVotes: List<String>.from(map['upVotes']),
      downVotes: List<String>.from(map['downVotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      userName: map['userName'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      awards: List<String>.from(map['awards']),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, link: $link, description: $description, type: $type, communityName: $communityName, communityProfile: $communityProfile, upVotes: $upVotes, downVotes: $downVotes, commentCount: $commentCount, userName: $userName, uid: $uid, createdAt: $createdAt, awards: $awards)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.title == title &&
        other.link == link &&
        other.description == description &&
        other.type == type &&
        other.communityName == communityName &&
        other.communityProfile == communityProfile &&
        listEquals(other.upVotes, upVotes) &&
        listEquals(other.downVotes, downVotes) &&
        other.commentCount == commentCount &&
        other.userName == userName &&
        other.uid == uid &&
        other.createdAt == createdAt &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        description.hashCode ^
        type.hashCode ^
        communityName.hashCode ^
        communityProfile.hashCode ^
        upVotes.hashCode ^
        downVotes.hashCode ^
        commentCount.hashCode ^
        userName.hashCode ^
        uid.hashCode ^
        createdAt.hashCode ^
        awards.hashCode;
  }
}
