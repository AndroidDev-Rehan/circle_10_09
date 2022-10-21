import 'package:circle/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/db_operations.dart';



class EventAcceptRejectWidget extends StatefulWidget {
  const EventAcceptRejectWidget({Key? key, required this.event}) : super(key: key);
  final EventModel event;

  @override
  State<EventAcceptRejectWidget> createState() => _EventAcceptRejectWidgetState();
}

class _EventAcceptRejectWidgetState extends State<EventAcceptRejectWidget> {

  bool loading = false;
  bool dismissed = false;

  @override
  Widget build(BuildContext context) {
    const double size = 50;

    return dismissed ? const SizedBox() : loading ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(),),) : Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.event.eventDate.millisecondsSinceEpoch)), style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16),),
            SizedBox(height: 5,),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(widget.event.title.length > 18 ? widget.event.title.substring(0,18) : widget.event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                ),
                Spacer(),
                Text(Duration(seconds: widget.event.eventBestTimeInSeconds).toString().substring(0, (Duration(seconds: widget.event.eventBestTimeInSeconds).toString().length > 14) ? 5 : 4), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
              ],

            ),
            Row(
              // mainAxisSize: MainAxisSize.min,
              children:  [
                ElevatedButton(
                  onPressed: accept, child:
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 5,),
                    Text("Going"),
                  ],
                ),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
                Spacer(),
                // const SizedBox(width: 5,),
                ElevatedButton(
                  onPressed: reject,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear),
                      SizedBox(width: 5,),
                      Text("Not Going"),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
              ],
            ),
          ],
        ),
        // trailing: Text(Duration(seconds: widget.event.eventBestTimeInSeconds).toString().substring(0, (Duration(seconds: widget.event.eventBestTimeInSeconds).toString().length > 14) ? 5 : 4), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children:  [
        //     ElevatedButton(
        //         onPressed: accept, child:
        //     Row(
        //       mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Icon(Icons.check),
        //             SizedBox(width: 5,),
        //             Text("Going"),
        //           ],
        //         ),
        //       style: ElevatedButton.styleFrom(primary: Colors.green),
        //     ),
        //     const SizedBox(width: 5,),
        //     ElevatedButton(
        //       onPressed: reject,
        //       child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.clear),
        //         SizedBox(width: 5,),
        //         Text("Not Going"),
        //       ],
        //     ),
        //       style: ElevatedButton.styleFrom(primary: Colors.red),
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Future<void> reject() async {
    setState((){
      loading = true;
    });

    try{
      List<String> list = [];
      list.add(FirebaseAuth.instance.currentUser!.uid);

      FirebaseFirestore.instance
          .collection("events")
          .doc(widget.event.eventId)
          .update({"usersNotGoing": FieldValue.arrayUnion(list), 'invitedUsers' : FieldValue.arrayRemove(list)}, );

      Get.snackbar("Success","Invite Rejected",backgroundColor: Colors.white,isDismissible: true);

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

    setState((){
      loading = true;
    });

    try {

      List<String> list = [];
      list.add(FirebaseAuth.instance.currentUser!.uid);

      FirebaseFirestore.instance
          .collection("events")
          .doc(widget.event.eventId)
          .update({"usersGoing": FieldValue.arrayUnion(list), 'invitedUsers' : FieldValue.arrayRemove(list)}, );



      Get.snackbar("Success","Invite Accepted",backgroundColor: Colors.white,isDismissible: true );

    }
    catch(e){
      print(e);
    }

    setState((){
      loading = false;
      dismissed = true;
    });

  }
}
