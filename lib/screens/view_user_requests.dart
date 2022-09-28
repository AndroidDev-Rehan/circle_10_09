import 'package:circle/utils/constants.dart';
import 'package:circle/widgets/request_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../widgets/user_request_widget.dart';

///Requests by user to join circle
///Only Visible to Manager of Circle

class ViewUserRequestsPage extends StatefulWidget {
  const ViewUserRequestsPage({Key? key, required this.groupRoom}) : super(key: key);

  final types.Room groupRoom;

  @override
  State<ViewUserRequestsPage> createState() => _ViewUserRequestsPageState();
}

class _ViewUserRequestsPageState extends State<ViewUserRequestsPage> {
  @override
  void initState(){
    super.initState();
  }

  List userIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Circle Joining Requests"),
        actions: [
          IconButton(onPressed: (){
            setState(() {});
            }, icon: const Icon(Icons.refresh)),
          const SizedBox(width: 10,),
        ],
      ),
      backgroundColor: Colors.lightBlue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text("Accept Requests to Add Members",style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,fontSize: 20),),
            color: Colors.transparent,
          ),
          const SizedBox(height: 20,),
          Expanded(
            child: FutureBuilder(
              future: fetchRequests(),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String,dynamic>>> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting || (!(snapshot.hasData))){
                  return const Center(child: CircularProgressIndicator(),);
                }

                List<Map<String,dynamic>> users = snapshot.data!;


                return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context,index){
                      return UserRequestWidget(room: widget.groupRoom, userMap: users[index], userId: userIds[index],);
                    }
                );
              },
            ),
          ),
        ],
      ),
    );

  }

  Future<List<Map<String,dynamic>>> fetchRequests() async{
    userIds = (widget.groupRoom.metadata)?['userRequests'] ?? [];
    List<Map<String,dynamic>> users = [];


    for (int i=0; i<userIds.length; i++){
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection("users").doc(userIds[i]).get();
      users.add(documentSnapshot.data()!);
    }

    return users;
  }

}

