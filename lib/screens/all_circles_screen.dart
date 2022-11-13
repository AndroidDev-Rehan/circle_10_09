import 'package:circle/screens/chat_core/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';

import 'chat_core/chat.dart';

class AllCirclesScreen extends StatelessWidget {
  const AllCirclesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text("All Circles"),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20.0),
          //   child: const Text("My Circles : ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
          // ),
          // const SizedBox(height: 10,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                color: Colors.lightBlueAccent,
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 10),
                          child: Text("My Circles  ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
                        ),
                        const SizedBox(height: 10,),
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 10),
                          child: Text("Joined ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                        ),

                        StreamBuilder<List<types.Room>>(
                          stream: FirebaseChatCore.instance.rooms(),
                          initialData: const [],
                          builder: (context,AsyncSnapshot<List<types.Room>> snapshot) {
                            // print("Hiragino Kaku Gothic ProN");
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                // alignment: Alignment.center,
                                // margin: const EdgeInsets.only(
                                //   bottom: 200,
                                // ),
                                // child: const Text('No Circles'),
                              );
                            }

                            try{
                              snapshot.data!
                                  .sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
                            }
                            catch(e){
                              for (var element in snapshot.data!) {print(element.updatedAt);}
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),

                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final types.Room room = snapshot.data![index];

                                // print("room type :${room.type}");

                                if( ((room.metadata == null) || (room.metadata!["isChildCircle"] == null) || (room.metadata!["isChildCircle"] == false)) && (room.type == (types.RoomType.group)) ){
                                  return InkWell(
                                    onTap: () {

                                      if(room.type==(types.RoomType.group)){
                                        Get.to(()=>GroupInfoScreen(groupRoom: room));
                                      }
                                      else {
                                        Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            room: room,
                                            groupChat: room.type == types.RoomType.group,
                                          ),
                                        ),
                                      );
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              _buildAvatar1(room),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 10,),
                                                    // room.type == types.RoomType.group ?
                                                    // Row(
                                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    //   children: [
                                                    //     // Text(
                                                    //     //   room.metadata?['status'] ?? ' status',
                                                    //     //   style: const TextStyle(
                                                    //     //       color: Colors.white,
                                                    //     //       fontSize: 14,
                                                    //     //       fontWeight: FontWeight.normal,
                                                    //     //       fontStyle: FontStyle.italic
                                                    //     //   ),
                                                    //     // ),
                                                    //     // Text(
                                                    //     //   room.metadata?['privacy'] ?? 'undefined',
                                                    //     //   style: const TextStyle(
                                                    //     //       color: Colors.black,
                                                    //     //       fontSize: 14,
                                                    //     //       fontWeight: FontWeight.normal,
                                                    //     //       fontStyle: FontStyle.italic
                                                    //     //   ),
                                                    //     // )
                                                    //   ],
                                                    // ) : const SizedBox(),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      room.name ?? 'no name',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox();
                              },
                            );
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 10),
                          child: const Text("Not Joined ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                        ),


                        StreamBuilder(
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
                                shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.size,
                                  itemBuilder: (context,index){
                                    Map<String,dynamic> circleMap = snapshot.data!.docs[index].data();
                                    // Map metadata = circleMap['metadata'] ?? {};
                                    List userIds = circleMap['userIds'] ?? [];

                                    print(circleMap);

                                    for (var element in userIds) {element = element.toString();}
                                    print(circleMap['name']);
                                    print("$userIds\n");


                                    if ((circleMap["type"]=="group") && (!(userIds.contains(FirebaseAuth.instance.currentUser!.uid)))) {
                                      return buildCircleContainer(circleMap);
                                    }
                                    return const SizedBox();
                                  }

                              );

                            }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20,),

          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     child: Material(
          //       color: Colors.lightBlueAccent,
          //       elevation: 5,
          //       borderRadius: BorderRadius.circular(16),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(16),
          //         ),
          //
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             SizedBox(height: 10,),
          //             const Padding(
          //               padding: EdgeInsets.only(left: 20.0),
          //               child: Text("Other Circles: ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
          //             ),
          //             const SizedBox(height: 10,),
          //
          //             Expanded(
          //               child: StreamBuilder(
          //                   stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
          //                   builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot){
          //                     if(snapshot.connectionState == ConnectionState.waiting){
          //                       return const Center(
          //                         child: CircularProgressIndicator(),
          //                       );
          //                     }
          //
          //                     if (!snapshot.hasData){
          //                       return const Center(
          //                         child: Text("No circles to show"),
          //                       );
          //                     }
          //
          //                     return ListView.builder(
          //                         itemCount: snapshot.data!.size,
          //                         itemBuilder: (context,index){
          //                           Map<String,dynamic> circleMap = snapshot.data!.docs[index].data();
          //                           // Map metadata = circleMap['metadata'] ?? {};
          //                           List userIds = circleMap['userIds'] ?? [];
          //
          //                           print(circleMap);
          //
          //                           for (var element in userIds) {element = element.toString();}
          //                           print(circleMap['name']);
          //                           print("$userIds\n");
          //
          //
          //                           if ((circleMap["type"]=="group") && (!(userIds.contains(FirebaseAuth.instance.currentUser!.uid)))) {
          //                             return buildCircleContainer(circleMap);
          //                           }
          //                           return const SizedBox();
          //                         }
          //
          //                     );
          //
          //                   }),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 20,),

        ],
      ),
    );
  }

  Widget buildCircleContainer(Map<String,dynamic> circleMap){

    final bool hasImage = circleMap['imageUrl'] != null;
    final String name = circleMap['name'] ?? '';

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
                  Text(name.isEmpty ? 'no name' : name, style: const TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold),),
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildAvatar1(types.Room room) {
    var color = Colors.transparent;

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      margin: const EdgeInsets.only(right: 0),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 30,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

}
