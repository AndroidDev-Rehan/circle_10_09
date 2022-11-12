import 'package:circle/phone_contacts_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart' as fl;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../widgets/phone_contact_tile.dart';

class ViewPhoneContactsScreen extends StatelessWidget {
  ViewPhoneContactsScreen({Key? key}) : super(key: key);

  bool permissionGranted = false;
  PhoneContactsController phoneContactsController = PhoneContactsController();

  @override
  Widget build(BuildContext context) {

    print(FirebaseAuth.instance.currentUser!.phoneNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Contacts"),
      ),
      body: FutureBuilder(
        future: fetchContacts(),
        builder: (context,AsyncSnapshot<List<Contact>> snapshot) {

          if(snapshot.connectionState==ConnectionState.waiting || (!(snapshot.hasData))){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if ((!(snapshot.connectionState==ConnectionState.waiting )) && (!permissionGranted)){
            return const Center(
              child: Text("Permission Not Granted"),
            );
          }

          List<Contact> contacts = snapshot.data ?? [];

          return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index){

                if(index < phoneContactsController.savedUsers.length){
                  return PhoneContactTile(contact: phoneContactsController.savedContacts[index], user: phoneContactsController.savedUsers[index] );
                }

                return PhoneContactTile(contact: contacts[index],);
              }
          );
        }
      ),
    );
  }

  Future<List<Contact>> fetchContacts() async{

    permissionGranted = await FlutterContacts.requestPermission();
    if (permissionGranted) {
      phoneContactsController.allContacts = await FlutterContacts.getContacts(withPhoto: true, withProperties: true);
    }

    await phoneContactsController.getSavedCircleUsers();

    return phoneContactsController.allContacts;
  }
}
