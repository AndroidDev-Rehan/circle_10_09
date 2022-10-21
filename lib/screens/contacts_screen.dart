import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
// import 'package:flutter_contacts/flutter_contacts.dart' as fl;

import 'package:flutter_contacts/flutter_contacts.dart';

class ViewPhoneContactsScreen extends StatelessWidget {
  ViewPhoneContactsScreen({Key? key}) : super(key: key);

  bool permissionGranted = false;

  @override
  Widget build(BuildContext context) {
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
                return _buildContact(contacts[index]);
              }

          );
        }
      ),
    );
  }

  Widget _buildContact(Contact contact){
    if(contact.phones.isEmpty){
      return SizedBox();
    }
    print(contact);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children:  [
          const SizedBox(width: 20,),
          (!(contact.photo==null)) ? CircleAvatar(
            backgroundImage: MemoryImage(contact.photo!),
            radius: 30,
          ) : CircleAvatar(
            backgroundImage: AssetImage("assets/images/user.png"),
            radius: 30,

          ),
          const SizedBox(width: 10,),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.displayName, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 4,),
              Text(contact.phones.first.number, style: TextStyle(color: Colors.black, fontSize: 18, ),),

            ],
          )



        ],
      ),
    );
  }

  Future<List<Contact>> fetchContacts() async{

    List<Contact> contacts = [];
    permissionGranted = await FlutterContacts.requestPermission(readonly: true);
    if (permissionGranted) {
      contacts = await FlutterContacts.getContacts(withPhoto: true, withProperties: true);
    }
    return contacts;
  }
}
