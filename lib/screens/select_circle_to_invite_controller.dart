import 'package:circle/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';

import '../models/scheduled_invite.dart';
import '../userinfo.dart';


class SelectCircleToInviteController extends GetxController{
  RxList<types.Room> invitedCircles = <types.Room>[].obs;
  Rx<bool> loading =false.obs;


  ///inviting users to circles
  Future<void> inviteUserToCircles(Contact contact) async{

    loading.value = true;

    try{

      ScheduledInvite scheduledInvite = ScheduledInvite(createdAt: DateTime.now(), invitedByUserId: FirebaseAuth.instance.currentUser!.uid, invitedToCircleIds: invitedCircles.map((element) => element.id).toList(), phoneNo: getValidPhoneNumber(contact.phones.first.number), updatedAt: DateTime.now());

      await FirebaseFirestore.instance.collection("scheduledInvites").doc(getValidPhoneNumber(contact.phones.first.number)).collection(getValidPhoneNumber(contact.phones.first.number)).doc("${getValidPhoneNumber(contact.phones.first.number)} ${FirebaseAuth.instance.currentUser!.uid}").set(
        scheduledInvite.toMap()
      );

      await _launchUrl(contact);

    }
    catch(e){
      // print(e);
      // if(kDebugMode) {
      //   Get.snackbar("error", e.toString());
      // }
    }

    loading.value = false;
    invitedCircles.clear();
  }

  Future<void> _launchUrl(Contact contact) async {


    Map userMap = await CurrentUserInfo.getCurrentUserMap();
    String firstName = userMap['firstName'];

    late Uri _url;

    if(contact.phones.isNotEmpty){
      _url = Uri(
        scheme: 'sms',
        path: contact.phones.first.number.trim(),
        queryParameters: <String, String>{
          'body': '$firstName has invited you to join circle app, Join Circle App now for fun and daily updates' ,
        },
      );
    }


    print(_url);

    // String updUrl = _url.toString().replaceAll("+", "%20");

    if (!await launchUrl(_url,)) {
      print("url launcher error, sms");
    }
  }


  @override
  void dispose(){

    loading.value = false;
    invitedCircles.clear();
    super.dispose();
  }
}