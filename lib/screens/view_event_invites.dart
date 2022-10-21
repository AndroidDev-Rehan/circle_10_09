import 'package:circle/models/event_model.dart';
import 'package:circle/utils/constants.dart';
import 'package:circle/widgets/EventAcceptRejectWidget.dart';
import 'package:circle/widgets/request_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';


class ViewEventInvites extends StatefulWidget {
  const ViewEventInvites({Key? key}) : super(key: key);

  @override
  State<ViewEventInvites> createState() => _ViewEventInvitesState();
}

class _ViewEventInvitesState extends State<ViewEventInvites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Circle Invites"),
        actions: [
          IconButton(onPressed: (){
            setState(() {

            });
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
            child: Text("Accept Invite to Join Circles",style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600,fontSize: 20),),
            color: Colors.transparent,
          ),
          SizedBox(height: 20,),
          Expanded(
            child: FutureBuilder(
              future: fetchInvites(),
              builder: (BuildContext context, AsyncSnapshot<List<EventModel>> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting || (!(snapshot.hasData))){
                  return const Center(child: CircularProgressIndicator(),);
                }

                List<EventModel> events = snapshot.data!;


                return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context,index){
                      return EventAcceptRejectWidget(event: events[index]);
                    }
                );
              },
            ),
          ),
        ],
      ),
    );

  }

  Future<List<EventModel>> fetchInvites() async{

    print("into fetch invites");

    List<EventModel> eventsList = <EventModel>[];

    QuerySnapshot<Map<String,dynamic>> allEventsCollection = await FirebaseFirestore.instance.collection("events").get();

    for (int i=0; i<allEventsCollection.docs.length; i++){
      EventModel eventModel = EventModel.fromMap(allEventsCollection.docs[i].data());
      if (eventModel.invitedUsers.any((element) => element.toString() == FirebaseAuth.instance.currentUser!.uid)){
        eventsList.add(eventModel);
      }
    }

    print("length of all room docs is ${allEventsCollection.docs.length}");
    print("length of roomslist is ${eventsList.length}");

    return eventsList;
  }
}


