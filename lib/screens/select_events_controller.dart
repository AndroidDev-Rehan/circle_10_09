import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


class AddEventController extends GetxController{
  RxList<types.User> invitedUsers = <types.User>[].obs;
  Rx<bool> loading =false.obs;


  ///adding room ids in requests collection and userid sub document
  Future<void> inviteUsers(String circleId) async{

    loading.value = true;

    try{

      final List usersIdList = invitedUsers.map((types.User user) => user.id).toList();

      await FirebaseFirestore.instance.collection("events").doc(circleId).update(
          {
            "invitedUsers" : FieldValue.arrayUnion(usersIdList)
          }
      );

      // List registrationIds = [];
      // for (var user in invitedUsers) {
      //   Map map = user.metadata ?? {};
      //   List fcmTokens = map['fcmTokens'] ?? [];
      //   registrationIds.addAll(fcmTokens);
      // }

      // Map userMap = await CurrentUserInfo.getCurrentUserMap();
      // await DBOperations.sendNotification(registrationIds: registrationIds, title: "New Circle Invite", text: "${userMap['firstName']} ${userMap['lastName']} invited you to $circleName", );

      Get.snackbar("Success", "Invites Sent", backgroundColor: Colors.white);

    }
    catch(e){
      Get.snackbar("error", e.toString());

    }

    loading.value = false;
    invitedUsers.clear();
  }

  @override
  void dispose(){

    loading.value = false;
    invitedUsers.clear();
    super.dispose();
  }
}