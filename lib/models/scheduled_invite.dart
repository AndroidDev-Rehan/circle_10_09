import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledInvite{
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> invitedToCircleIds;
  final String phoneNo;
  final String invitedByUserId;

  ScheduledInvite({required this.createdAt,required this.invitedByUserId,required this.invitedToCircleIds,required this.phoneNo,required this.updatedAt});

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'invitedToCircleIds': invitedToCircleIds,
      'phoneNo': phoneNo,
      'invitedByUserId': invitedByUserId,
    };
  }

  factory ScheduledInvite.fromMap(Map<String, dynamic> map) {

    return ScheduledInvite(
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as Timestamp).millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as Timestamp).millisecondsSinceEpoch),
      invitedToCircleIds: (map['invitedToCircleIds'] as List).map((e) => e.toString()).toList(),
      phoneNo: map['phoneNo'] as String,
      invitedByUserId: map['invitedByUserId'] as String,
    );
  }
}
