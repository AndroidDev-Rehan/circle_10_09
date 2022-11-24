import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:circle/screens/all_circles_screen.dart';
import 'package:circle/screens/selectCircleToJoin.dart';
import 'package:circle/screens/Create_Circle_screen.dart';
import 'package:get/get.dart';

import '../chat_core/rooms.dart';
import '../chat_core/view_requests_page.dart';


class CircleButtonScreens extends StatelessWidget {
  const CircleButtonScreens({Key? key}) : super(key: key);

  final double height = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Circles"),
      ),
      body:   Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(),
          ElevatedButton(
              child: const Text("Create new Circle", style: TextStyle(),textAlign: TextAlign.center),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(150, 60)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const CreateCirclePage()),
                );

              }),
          SizedBox(height: height,),
          ElevatedButton(
              child: const Text("View My Circles"),
              style: ElevatedButton.styleFrom(
                  // shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  fixedSize: Size(150, 60)
              ),
              onPressed: () {
                Get.to(const RoomsPage(goToInfoPage: true,));
                // viewMyCircles(context);
              }),
          SizedBox(height: height,),

          ElevatedButton(
              child: const Text("View All Circles"),
              style: ElevatedButton.styleFrom(
                // shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  fixedSize: Size(150, 60)
              ),

              onPressed: () {
                Get.to(const AllCirclesScreen());
                // viewMyCircles(context);
              }),
          SizedBox(height: height,),

          ElevatedButton(
              child: const Text("  Join a Circle  "),
              style: ElevatedButton.styleFrom(
                // shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  fixedSize: Size(150, 60)
              ),

              onPressed: () async{
                Get.to(const SelectCircleToJoinScreen());
                // Get.to(AllCirclesScreen());
                // viewMyCircles(context);
              }),
          SizedBox(height: height,),

          StreamBuilder(
              stream: FirebaseFirestore.instance.collection("rooms").snapshots(),
              builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {

                if(snapshot.connectionState == ConnectionState.waiting || (!(snapshot.hasData))){
                  return ElevatedButton(
                      child: const Text("Circle Invites", textAlign: TextAlign.center),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ViewRequestsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 60)
                      )
                  );
                }

                int count = 0;

                QuerySnapshot<Map<String,dynamic>> allRoomsCollection = snapshot.data!;

                for (int i=0; i<allRoomsCollection.docs.length; i++){


                  final Map<String,dynamic> map  = allRoomsCollection.docs[i].data();

                  if(map["requests"] == null){
                    continue;
                  }

                  final List requests = map["requests"] ?? [];


                  if(requests.contains(FirebaseAuth.instance.currentUser!.uid)){
                    // print("trying");
                    // print(map);
                    count = count +1;
                  }
                }


                return ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Circle Invites", textAlign: TextAlign.center,),
                        count != 0 ?Text("  ($count)", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),) : SizedBox()
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ViewRequestsPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 60)
                    )
                );
              }
          ),


        ],
      ),
    );
  }
}
