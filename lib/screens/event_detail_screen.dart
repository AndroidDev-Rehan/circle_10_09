import 'package:circle/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'chat_core/chat.dart';
import 'chat_core/util.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({Key? key, required this.eventModel}) : super(key: key);
  final EventModel eventModel;



  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final List<Map<String,dynamic>> invitedUsers = [];

  final List<Map<String,dynamic>> goingUsers = [];

  final List<Map<String,dynamic>> notGoingUsers = [];

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    print(widget.eventModel.usersGoing);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Detail"),
        centerTitle: true,
      ),
      body: loading ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.eventModel.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
              SizedBox(height: 20,),
              Text(widget.eventModel.description, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),),
              SizedBox(height: 40,),
              Row(
                children: [
                  Text("Event Date:   ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.eventModel.eventDate.millisecondsSinceEpoch)), style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),)
                ],
              ),
              SizedBox(height: 20,),

              Row(
                children: [
                  Text("Event Time:   ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(Duration(seconds: widget.eventModel.eventBestTimeInSeconds).toString().substring(0, (Duration(seconds: widget.eventModel.eventBestTimeInSeconds).toString().length > 14) ? 5 : 4), style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),)
                ],
              ),
              SizedBox(height: 20,),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").doc(widget.eventModel.createdBy).snapshots(),
                builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String,dynamic>>> snapshot) {

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Row(
                      children: [
                        Text("Hosted By:   ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Hosted By:   ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 10,),

                        buildUserTile(snapshot.data!.data()!),
                      ],
                    ),
                  );
                }
              ),

              SizedBox(height: 30,),

              FutureBuilder(
                  future: getAllUsers(),
                  builder: (context,AsyncSnapshot<void> snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // List<Map<String,dynamic>> allUsers = snapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _usersGoing(),
                        const SizedBox(height: 40,),
                        _usersNotGoing(),
                        const SizedBox(height: 40,),

                        _usersInvited(),


                      ],
                    );
                  }

                  )

            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(padding: EdgeInsets.all(20),
      child: ElevatedButton(

          onPressed:
          FirebaseAuth.instance.currentUser!.uid == widget.eventModel.createdBy? null :
          ()async{
            _handlePressed(context);
          },
          child: const Text("Message Host")),
      ),
    );
  }

  Widget _usersGoing(){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Users Going to Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),),
        const SizedBox(height: 10,),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: goingUsers.length,
            itemBuilder: (context,index){
              return buildUserTile(goingUsers[index]);
            }),
      ],
    );
  }

   Widget _usersNotGoing(){

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisSize: MainAxisSize.min,
       children: [
         const Text("Users Not Going to Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),),
         const SizedBox(height: 10,),
         ListView.builder(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             itemCount: notGoingUsers.length,
             itemBuilder: (context,index){
               return buildUserTile(notGoingUsers[index]);
             }),
       ],
     );
   }

   Widget _usersInvited(){

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisSize: MainAxisSize.min,
       children: [
         const Text("Users Invited to Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber),),
         const Text("(Users who didn't respond yet)", style: TextStyle(),),

         const SizedBox(height: 10,),
         ListView.builder(
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             itemCount: invitedUsers.length,
             itemBuilder: (context,index){
               return buildUserTile(invitedUsers[index]);
             }),
       ],
     );
   }

   Widget buildUserTile(Map<String,dynamic> userMap){
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(userMap),
          const SizedBox(width: 15,),
          Text(userMap['firstName'] ?? "")

        ],
      ),
    );
  }

   Widget _buildAvatar(Map<String,dynamic> userMap) {
     return Container(
       margin: const EdgeInsets.only(right: 0),
       child: CircleAvatar(
         backgroundColor: Colors.transparent,
         backgroundImage: NetworkImage(userMap["imageUrl"]),
         radius: 20,
         child: null,
       ),
     );
   }

  Future<void> getAllUsers() async{

    clearAll();

   QuerySnapshot<Map<String,dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var element in widget.eventModel.invitedUsers) {element=element.toString();}
    for (var element in widget.eventModel.usersGoing) {element=element.toString();}
    for (var element in widget.eventModel.usersNotGoing) {element=element.toString();}

   for (var element in querySnapshot.docs) {

     if(widget.eventModel.invitedUsers.contains(element.id)){
       invitedUsers.add(element.data());
     }

     else if(widget.eventModel.usersGoing.contains(element.id)){
       goingUsers.add(element.data());
     }


     else if(widget.eventModel.usersNotGoing.contains(element.id)){
       notGoingUsers.add(element.data());
     }

   }

    return ;
  }

  clearAll(){
    invitedUsers.clear();
    goingUsers.clear();
    notGoingUsers.clear();
  }

   void _handlePressed( BuildContext context) async {

     setState(() {
       loading = true;
     });

     final navigator = Navigator.of(context);
     // print("other user: $otherUser");

     List<types.User> allUsers = await FirebaseChatCore.instance.users().first;

     types.User otherUser = allUsers.firstWhere((element) => element.id==widget.eventModel.createdBy);
     final room = await FirebaseChatCore.instance.createRoom(otherUser);


     // navigator.pop();

     setState(() {
       loading = false;
     });


     await navigator.push(
       MaterialPageRoute(
         builder: (context) => ChatPage(
           room: room,
         ),
       ),
     );
   }
}
