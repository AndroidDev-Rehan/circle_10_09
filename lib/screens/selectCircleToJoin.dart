import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';

class SelectCircleToJoinScreen extends StatefulWidget {
  const SelectCircleToJoinScreen({Key? key}) : super(key: key);

  @override
  State<SelectCircleToJoinScreen> createState() => _SelectCircleToJoinScreenState();
}

class _SelectCircleToJoinScreenState extends State<SelectCircleToJoinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text("Select Circle To Join"),),
      body: Column(
        children: [
          ElevatedButton(
              child: const Text("Join a Circle by ID"),
              onPressed: () async{
                await joinCircleById();
                // Get.to(AllCirclesScreen());
                // viewMyCircles(context);
              }),
          const SizedBox(height: 20,),
          const Text("Joining Private Circles require approval by circle manager.", style: const TextStyle(color: Colors.white),),
          const SizedBox(height: 10,),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
                builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData){
                    return const Center(
                      child: Text("No circles to show"),
                    );
                  }

                  return ListView.builder(
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context,index){
                        Map<String,dynamic> circleMap = snapshot.data!.docs[index].data();
                        if (circleMap["type"]=="group") {
                          return buildCircleContainer(circleMap,snapshot.data!.docs[index].id);
                        }
                        return const SizedBox();
                      }

                  );

                }),
          ),
        ],
      ),
    );
  }

  Widget buildCircleContainer(Map<String,dynamic> circleMap, String id){

    final bool hasImage = circleMap['imageUrl'] != null;
    final String name = circleMap['name'] ?? '';

    List userIds = circleMap['userIds'];
    bool alreadyPart = userIds.contains(FirebaseAuth.instance.currentUser!.uid);

    Map metadata = circleMap['metadata'] ?? {} ;
    List requests = metadata['userRequests'] ?? [];

    for (var element in requests) { element = element.toString();}

    bool requestSent = requests.contains(FirebaseAuth.instance.currentUser!.uid);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: hasImage ? Colors.transparent : Colors.pinkAccent,
                  backgroundImage: hasImage ? NetworkImage(circleMap['imageUrl']) : null,
                  radius: 30,
                  child: !hasImage
                      ? Text(
                    name.isEmpty ? '' : name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                      : null,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metadata["privacy"] ?? "null",style: const TextStyle(color: Colors.white,)),
                  SizedBox(height: 8,),
                  Text(name.isEmpty ? 'no name' : name, style: const TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold),),
                ],
              ),
              const Spacer(),
              ElevatedButton(onPressed: (alreadyPart || requestSent ) ? null :  () async{
                await joinCircle(circleMap,id);
              }, child: Text( alreadyPart? "Joined" : requestSent ? "Request Sent" : "Join"))
            ],
          ),

        ],
      ),
    );
  }

  Future<void> joinCircle(Map<String,dynamic> circleMap, String circleId) async{
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Are you sure you want to join"),
              Text("${circleMap["name"]!} ?", style: const TextStyle(fontWeight: FontWeight.bold),),

            ],
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () async {
                  Map metadata = circleMap["metadata"] ?? {};
                  List userRequests = metadata["userRequests"] ?? [];

                  if (metadata['privacy'] == "public" || metadata['privacy'] == null){
                    await FirebaseFirestore.instance
                        .collection("rooms")
                        .doc(circleId)
                        .update({
                      "userIds": FieldValue.arrayUnion([
                        FirebaseAuth.instance.currentUser!.uid
                      ])
                    });
                    Navigator.pop(context);
                    Get.snackbar("Success","Circle Joined.", backgroundColor: Colors.white);
                  }
                  else {

                    userRequests.add(FirebaseAuth.instance.currentUser!.uid);
                    metadata['userRequests'] = userRequests;

                    await FirebaseFirestore.instance.collection("rooms").doc(circleId).update(
                        {
                          'metadata' : metadata
                        }
                    );
                    Get.snackbar("Success","Circle Joining Request Sent to Circle Manager", backgroundColor: Colors.white);
                    Navigator.pop(context);
                  }


                },
                child: const Text("Confirm"))
          ],
        ));
  }

  Future<void> joinCircleById() async {
    {
      TextEditingController idController = TextEditingController();
      // Map? circleMap;
      types.Room? room;
      bool tried = false;
      await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enter Circle Id'),
            content: TextFormField(
              controller: idController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () async {
                    if (idController.text.isEmpty) {
                      Get.snackbar("Error", "Id cant be null");
                      return;
                    }

                    tried = true;
                    try {
                      room = await FirebaseChatCore.instance
                          .room(idController.text)
                          .first;
                    } catch (e) {
                      room = null;
                    }

                    Navigator.pop(context);
                  },
                  child: Text("Confirm"))
            ],
          ));

      bool alreadyJoined = false;

      if (room != null) {
        for (var element in room!.users) {
          if (element.id == FirebaseAuth.instance.currentUser!.uid) {
            alreadyJoined = true;
            break;
          }
        }

        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Join Circle'),
              content: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      // backgroundColor: hasImage ? Colors.transparent : color,
                      backgroundImage: NetworkImage(room!.imageUrl ??
                          'https://media.istockphoto.com/vectors/user-avatar-profile-icon-black-vector-illustration-vector-id1209654046?k=20&m=1209654046&s=612x612&w=0&h=Atw7VdjWG8KgyST8AXXJdmBkzn0lvgqyWod9vTb2XoE='),
                      radius: 40,
                      child: null,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(room?.name ?? "room")
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: alreadyJoined
                        ? null
                        : () async {
                      try {
                        // await FirebaseFirestore.instance.collection("rooms")
                        //     .doc(widget.groupRoom.id)
                        //     .update({"users": userIds});
                        await FirebaseFirestore.instance
                            .collection("rooms")
                            .doc(idController.text)
                            .update({
                          "userIds": FieldValue.arrayUnion([
                            FirebaseAuth.instance.currentUser!.uid
                          ])
                        });
                        Navigator.pop(context);
                        Get.snackbar("Success",
                            "you are added to ${room?.name ?? 'circle'}",
                            backgroundColor: Colors.white);
                      } catch (e) {
                        Get.snackbar("error", e.toString());
                        print(e);
                      }
                    },
                    child: const Text("Join"))
              ],
            ));
      } else if (tried == true && room == null) {
        Get.snackbar("Sorry", "No circle found", backgroundColor: Colors.white);
      }
    }
  }
}
