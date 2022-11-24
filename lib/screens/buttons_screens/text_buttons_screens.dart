import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat_core/users.dart';
import '../contacts_screen.dart';


class TextButtonsScreen extends StatelessWidget {
  const TextButtonsScreen({Key? key}) : super(key: key);

  final double height = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Text"),
      ),
      body:   Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(),
          SizedBox(height: height,),

          ElevatedButton(

            ///VIEW CIRCLE INVITES REPLACEMENT
              child: const Text("Text", textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
              onPressed: () {
                Get.to(const UsersPage());
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              )

          ),
          SizedBox(height: height,),


          ElevatedButton(

            ///VIEW CIRCLE INVITES REPLACEMENT
              child: const Text("Circle Users",style: TextStyle(fontSize: 15)),
              onPressed: () {
                Get.to(const UsersPage(onlyUsers: true,));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //       const ViewRequestsPage()),
                // );
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              )

          ),
          SizedBox(height: height,),

          ElevatedButton(

              child: const Text("View Contacts", style: TextStyle(fontSize: 15),textAlign: TextAlign.center,),
              onPressed: () {
                Get.to(ViewPhoneContactsScreen());
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              )

          ),








        ],
      ),
    );
  }
}
