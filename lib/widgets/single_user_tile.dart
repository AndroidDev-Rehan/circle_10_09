import 'package:circle/screens/chat_core/util.dart';
import 'package:circle/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';

import '../screens/other_user_profile.dart';

class SingleUserTile extends StatefulWidget {
  const SingleUserTile({Key? key, required this.user, required this.groupRoom, this.hideDelete = false, this.manager = false}) : super(key: key);

  final types.User user;
  final types.Room groupRoom;
  final bool manager;
  final bool hideDelete;

  @override
  State<SingleUserTile> createState() => _SingleUserTileState();
}

class _SingleUserTileState extends State<SingleUserTile> {

  bool loading=false;
  bool deleted = false;

  @override
  Widget build(BuildContext context) {
    return deleted ? SizedBox() : Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: InkWell(
        onTap: (){
          if(widget.user.id == FirebaseAuth.instance.currentUser!.uid){
            Get.to(ProfileScreen());
          }
          else {
                  Get.to(() => OtherUserProfileScreen(
                        otherUser: widget.user,
                      ));
                }
              },
        child: Row(
          children: [
            _buildAvatar(widget.user),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(getUserName(widget.user), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(height: widget.manager ? 2 : 0,),
                widget.manager ? Text("manager") : SizedBox(height: 0,),
              ],
            ),
            Spacer(),
            !loading ?
            Visibility(
              visible: widget.hideDelete ? false : true,
              maintainState: true,
              maintainSize: true,
              maintainAnimation: true,
              child: InkWell(
                onTap: () async{
                  await removeMember();
                },
                  child: Icon(Icons.delete_outline)
              ),
            ) : const SizedBox(
              height: 30,
              width: 30,
              child: Center(child: CircularProgressIndicator()),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(types.User user) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

  Future<void> removeMember() async{


    print(widget.groupRoom.users.length);
    print(widget.groupRoom.users);
    // return;

    List userIds = [widget.user.id];

    // widget.groupRoom.users.removeWhere((types.User user) => (user.id == widget.user.id));
    // List<String> userIds = widget.groupRoom.users.map((types.User user) => user.id).toList();

    if(mounted){
      setState(() {
        loading = true;
      });
    }

    try {
      await FirebaseFirestore.instance.collection("rooms")
          .doc(widget.groupRoom.id)
          .update({"userIds": FieldValue.arrayRemove(userIds)});
      deleted = true;
    }
    catch(e){
      deleted = false;
      print(e);
    }

    if(mounted){
      setState(() {
        loading = false;
      });
    }
  }


}
