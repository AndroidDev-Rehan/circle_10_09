import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/scheduled_invite.dart';

class NewUserConfigurations{

  bool setupDone = false;

  Future<void> setupUserScheduledInvites() async{
    print("into setup user scheduled invites function");

    if(setupDone){
      return;
    }

    try{

      QuerySnapshot<Map<String,dynamic>> collection = await FirebaseFirestore.instance.collection('scheduledInvites').doc(FirebaseAuth.instance.currentUser!.phoneNumber!).
          collection(FirebaseAuth.instance.currentUser!.phoneNumber!).get();

      List<ScheduledInvite> invites = collection.docs.map((e) => ScheduledInvite.fromMap(e.data())).toList();

      for (var invite in invites) {

        for (var element in invite.invitedToCircleIds) {
          List<String> list = [];
          list.add(FirebaseAuth.instance.currentUser!.uid);
          await FirebaseFirestore.instance.collection('rooms').doc(element).update({
            "requests" : FieldValue.arrayUnion(list)
          });

          await FirebaseFirestore.instance.collection('scheduledInvites').doc(FirebaseAuth.instance.currentUser!.phoneNumber!).
          collection(FirebaseAuth.instance.currentUser!.phoneNumber!).doc("${invite.phoneNo} ${invite.invitedByUserId}").delete();

        }
      }
      setupDone = true;


    }
    catch(e){
      rethrow;
      print(e);
    }
  }
}