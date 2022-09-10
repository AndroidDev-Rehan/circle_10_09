import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AllCirclesScreen extends StatelessWidget {
  const AllCirclesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text("All Circles"),),
      body: StreamBuilder(
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
                    return buildCircleContainer(circleMap);
                  }
                  return const SizedBox();
                }

            );

          }),
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
}
