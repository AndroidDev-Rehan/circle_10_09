import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../screens/chat_core/util.dart';
import '../utils/db_operations.dart';


class UserRequestWidget extends StatefulWidget {
  final types.Room room;
  final Map<String,dynamic> userMap;
  final String userId;
  const UserRequestWidget({Key? key, required this.room, required this.userMap, required this.userId,}) : super(key: key);

  @override
  State<UserRequestWidget> createState() => _UserRequestWidgetState();
}

class _UserRequestWidgetState extends State<UserRequestWidget> {

  bool loading = false;
  bool dismissed = false;

  @override
  Widget build(BuildContext context) {
    // print(object)
    const double size = 50;

    return dismissed ? const SizedBox() : loading ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(),),) : Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        leading: _buildAvatar(),
        title: Text(widget.userMap["firstName"] ?? "no name", style: const TextStyle(fontWeight: FontWeight.bold),),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children:  [
            InkWell(
                onTap: accept,
                child: const Icon(Icons.check_circle, color: Colors.green, size: size,)),
            const SizedBox(width: 5,),
            InkWell(
                onTap: reject,
                child: const Icon(Icons.remove_circle, color: Colors.red, size: size,))
          ],
        ),
      ),
    );
  }

  Future<void> reject() async {
    setState((){
      loading = true;
    });

    try{

      Map metadata = widget.room.metadata ?? {};
      List ids = metadata["userRequests"] ?? [];
      ids.removeWhere((element){
        String id = element.toString();
        return id == widget.userId;
      } );

      metadata["userRequests"] = ids;


      await FirebaseFirestore.instance.collection("rooms").doc(widget.room.id).update({
        "metadata" : metadata
      });

      Get.snackbar("Success","Request Denied",backgroundColor: Colors.white,isDismissible: true);

    }
    catch(e){
      print(e);
    }

    setState((){
      loading = false;
      dismissed = true;
    });

  }

  Future<void> accept()async{

    final List<String> userIds = widget.room.users.map((types.User user) => user.id).toList();
    userIds.add(widget.userId);

    setState((){
      loading = true;
    });

    try {

      Map metadata = widget.room.metadata ?? {};
      List ids = metadata["userRequests"] ?? [];
      ids.removeWhere((element){
        String id = element.toString();
        return id == widget.userId;
      } );

      metadata["userRequests"] = ids;


      await FirebaseFirestore.instance.collection("rooms").doc(widget.room.id).update({
        "metadata" : metadata
      });

      await FirebaseFirestore.instance.collection("rooms")
          .doc(widget.room.id)
          .update({"userIds": userIds,});


      Get.snackbar("Success","User added to circle",backgroundColor: Colors.white,isDismissible: true );


    }
    catch(e){
      print(e);
    }

    setState((){
      loading = false;
      dismissed = true;
    });

  }

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(widget.userMap["imageUrl"]),
        radius: 20,
        child: null,
      ),
    );
  }


}
