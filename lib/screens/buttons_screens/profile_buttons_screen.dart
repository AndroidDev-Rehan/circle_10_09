import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat_core/users.dart';
import '../contacts_screen.dart';
import '../profile_screen.dart';


class ProfileButtonsScreen extends StatelessWidget {
  const ProfileButtonsScreen({Key? key}) : super(key: key);

  final double height = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Users"),
      ),
      body:   Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(),
          ElevatedButton(

            ///VIEW CIRCLE INVITES REPLACEMENT
              child: const Text("My Profile",textAlign: TextAlign.center),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              ),
              onPressed: () {
                Get.to(ProfileScreen());
              }),
          SizedBox(height: height,),


          ElevatedButton(

            ///VIEW CIRCLE INVITES REPLACEMENT
              child: const Text("Other Users",textAlign: TextAlign.center),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              ),
              onPressed: () {
                Get.to(const UsersPage(onlyUsers: true,));
              }),
          SizedBox(height: height,),
          ElevatedButton(

            ///VIEW CIRCLE INVITES REPLACEMENT
              child: const Text("My Friends",textAlign: TextAlign.center),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60)
              ),
              onPressed: () {
                Get.to(const UsersPage(onlyUsers: true,));
              })








        ],
      ),
    );
  }
}
