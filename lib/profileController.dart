import 'package:circle/screens/main_circle_modified.dart';
import 'package:circle/utils/db_operations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


class ProfileController extends GetxController{
  Rx<bool> loading = false.obs;
  XFile? pickedFile;
  Rx<String> usernameId = '@circle'.obs;

  final Rx<TextEditingController> firstNameController = TextEditingController().obs;
  // final TextEditingController lastNameController = TextEditingController();


  Future<String> uploadImageAndGetUrl( ) async {
    String downloadUrl = '';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("file ${DateTime.now()}");
    UploadTask uploadTask = ref.putFile(File(pickedFile!.path));
    await uploadTask.then((res) async{
      downloadUrl = await res.ref.getDownloadURL();
    });
    return downloadUrl;
  }


  Future<void> saveInfo({required String hobby, required String music, required String band, required String book, required String imageUrl , bool createIt = false, required Map metadata }) async{
    loading.value = true;
    try{
      print("picked file is ${pickedFile?.path}");

      if(createIt){
        String fcmToken = await DBOperations.getDeviceTokenToSendNotification();
        List<String> tokenList = [fcmToken];
        await FirebaseChatCore.instance.createUserInFirestore(
          types.User(
              firstName: hobby,
              id: FirebaseAuth.instance.currentUser!.uid,
              imageUrl: (pickedFile != null) ? (await uploadImageAndGetUrl()) : imageUrl,
              lastName: music,
              metadata: {
                "fcmTokens":tokenList
              }
          ),
        );

        Get.to(const MainCircle());
      }

      else{
        metadata['fvrtHobby'] = hobby;
        metadata['fvrtMusic'] = music;
        metadata['fvrtBook'] = book;
        metadata['fvrtBand'] = band;

    await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'imageUrl': (pickedFile != null) ? (await uploadImageAndGetUrl()) : imageUrl,
          'metadata': metadata
        });
        Get.back();
      }
      Get.snackbar("Success", "Info saved", backgroundColor: Colors.white);
    }
    catch(e){
      print(e);
      Get.snackbar("Error", e.toString());
    }
    loading.value = false;
  }


Future<void> saveInfo1({required String firstName, required String lastName, required String imageUrl , bool createIt = false }) async{
    loading.value = true;
    try{
      print("picked file is ${pickedFile?.path}");

      if(!(await usernameIdExists())){
        String fcmToken = await DBOperations.getDeviceTokenToSendNotification();
        List<String> tokenList = [fcmToken];
        await FirebaseChatCore.instance.createUserInFirestore(
          types.User(
            firstName: firstName,
            id: FirebaseAuth.instance.currentUser!.uid,
            imageUrl: (pickedFile != null) ? (await uploadImageAndGetUrl()) : imageUrl,
            lastName: lastName,
            metadata: {
              "fcmTokens":tokenList,
              'user_id' : usernameId.value,
              'phone' : FirebaseAuth.instance.currentUser!.phoneNumber
            }
          ),
        );

        Get.to(const MainCircle());
      }

      else{
        Get.snackbar("Req Failed", "Username is already taken", backgroundColor: Colors.white);
        loading.value = false;
        return;
      }
      Get.snackbar("Success", "Info saved", backgroundColor: Colors.white);
    }
    catch(e){
      print(e);
      Get.snackbar("Error", e.toString());
    }
    loading.value = false;
  }

  Future<bool> usernameIdExists() async{
   List<types.User> users = await FirebaseChatCore.instance.users().first;
   for (var user in users) {
     Map metadata = {};

     if (user.metadata == null){
       continue;
     }
     metadata = user.metadata!;

     if (metadata['user_id'] == usernameId.value){
       return true;
    }

   }
   return false;
  }
}