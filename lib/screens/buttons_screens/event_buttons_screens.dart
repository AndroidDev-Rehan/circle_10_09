import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/event_model.dart';
import '../add_event_screen.dart';
import '../calendar_list_events.dart';
import '../view_event_invites.dart';


class EventButtonsScreen extends StatelessWidget {
  const EventButtonsScreen({Key? key}) : super(key: key);

  final double height = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Events"),
      ),
      body:   Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(),
          ElevatedButton(
              child: const Text("Create new Event", style: TextStyle(),textAlign: TextAlign.center),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const AddEventScreen(circleId: 'global',)),
                );

              }),
          SizedBox(height: height,),
          ElevatedButton(

        ///VIEW CIRCLE INVITES REPLACEMENT
          child: const Text("View Events", style: TextStyle(fontSize: 15),textAlign: TextAlign.center,),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              ),
          onPressed: () {
            Get.to(CalendarListEventsScreen(circleId: 'global',));
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //       const ViewRequestsPage()),
            // );
          }),
          SizedBox(height: height,),

          StreamBuilder(
              stream: FirebaseFirestore.instance.collection("events").snapshots(),
              builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {

                if(snapshot.connectionState == ConnectionState.waiting || (!(snapshot.hasData))){
                  return ElevatedButton(
                      child: const Text("Event Invites", textAlign: TextAlign.center),
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 60)
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ViewEventInvites()),
                        );
                      });
                }

                int count = 0;

                QuerySnapshot<Map<String,dynamic>> allEventsCollection = snapshot.data!;

                for (int i=0; i<allEventsCollection.docs.length; i++){


                  final EventModel event  = EventModel.fromMap(allEventsCollection.docs[i].data());


                  if(event.invitedUsers.contains(FirebaseAuth.instance.currentUser!.uid)){
                    // print("trying");
                    // print(map);
                    count = count +1;
                  }
                }


                return ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Event Invites",textAlign: TextAlign.center, ),
                        count != 0 ?Text("  ($count)", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),) : SizedBox()
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ViewEventInvites()),
                      );

                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 60)
                    )

                );
              }
          ),

          SizedBox(height: height,),






        ],
      ),
    );
  }
}
