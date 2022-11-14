import 'package:circle/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class PhoneContactsController extends GetxController {
  late List<Contact> allContacts;
  final List<types.User> savedUsers = [];
  final List<Contact> savedContacts = [];

  ///List of circle users saved in user contact book
  Future<List<types.User>> getSavedCircleUsers() async {
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
    savedContacts.clear();
    savedUsers.clear();
    print("into getSavedUsers");

    Stream<List<types.User>> usersStream = FirebaseChatCore.instance.users();

    // await Future.delayed(const Duration(seconds: 1));

    int count = 0;
    usersStream.listen((event) {
      count=count+1;
      print("stream count: $count");
      print("total users: ${event.length}");

      for (var element in event) {
        print(element.firstName);
      }

    });

    final List<types.User> allUsers = await usersStream.first;

    print("Firestore documents users count : ${(await FirebaseFirestore.instance.collection('users').get()).docs.length}");

    if(FirebaseFirestore.instance.settings.persistenceEnabled! ){
      print("enabled");
    }
    else{
      print("disabled");

    }


    print("all users length: ${allUsers.length}");

    ///checking any firebase user saved in contacts
    for (var user in allUsers) {
      print("analyzing user : ${user.firstName}");
      Map? metadata = user.metadata;

      if (metadata == null || metadata['phone'] == null || metadata['phone'] == FirebaseAuth.instance.currentUser!.phoneNumber) {
        print("continuing");
        continue;
      }

      print(metadata['phone']);

      bool userSaved = allContacts.any((contact) {
        if (contact.phones.isEmpty) {
          return false;
        }

        return contact.phones.any((phone) => getValidPhoneNumber(phone.number) == metadata['phone']);
      });

      if (userSaved) {
        print("user saved found");
        savedUsers.add(user);
        Contact contact = allContacts.firstWhere((element) => element.phones.any((phone) => getValidPhoneNumber(phone.number) == metadata['phone']));
        savedContacts.add(contact);
        allContacts.removeWhere((element) => element.phones.any((phone) => getValidPhoneNumber(phone.number)==metadata['phone']));
      }
    }

    return savedUsers;
  }
}



