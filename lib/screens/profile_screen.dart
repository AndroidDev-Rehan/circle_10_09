import 'dart:io';
import 'package:circle/phone_login/collect_user_info.dart';
import 'package:circle/profileController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  ProfileController profileController = ProfileController();

  TextEditingController hobbyController = TextEditingController();
  TextEditingController musicController = TextEditingController();
  TextEditingController bookController = TextEditingController();
  TextEditingController bandController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(Get.width);
    double paddingRes30 = Get.width * 0.070093;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingRes30),
          child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.data == null ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                Map<String, dynamic> userMap = snapshot.data!.data()!;

                Map metadata = userMap['metadata'] ?? {};

                hobbyController.text = metadata['fvrtHobby'] ?? "";
                musicController.text = metadata['fvrtMusic'] ?? "";
                bandController.text = metadata['fvrtBand'] ?? "";
                bookController.text = metadata['fvrtBook'] ?? "";
                // passwordController.text = userMap['firstName'];
                // emailController.text = FirebaseAuth.instance.currentUser!.email;

                print(userMap);
                if(userMap['metadata']==null){
                  Get.offAll(CollectUserInfo(phoneNo: FirebaseAuth.instance.currentUser!.phoneNumber!));
                  return SizedBox();
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      UserPhotoWidget(
                        imageUrl: userMap['imageUrl'],
                        profileController: profileController,
                      ),
                      SizedBox(
                        height: Get.height * 0.0777 * 0.65,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "User Id:",
                                        style: TextStyle(
                                            fontSize: 20),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Text(
                                        metadata['user_id'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,

                                        ),
                                        textAlign: TextAlign.center,
                                      )),
                                      IconButton(
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: metadata['user_id']));
                                            Get.snackbar("Success",
                                                "User Id Copied to Clipboard",
                                                backgroundColor: Colors.white);
                                          },
                                          icon:
                                              const Icon(Icons.copy_outlined)),
                                      // InkWell(
                                      //   onTap: () {
                                      //     Clipboard.setData(
                                      //         ClipboardData(text: widget.groupRoom.id));
                                      //     Get.snackbar("Success", "Text Copied");
                                      //   },
                                      //   child: const Icon(Icons.copy),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: paddingRes30, vertical: 8),
                        child: _buildCustomTextField("Favourite Hobby",
                            readOnly: false,
                            textEditingController: hobbyController),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: paddingRes30, vertical: 8),
                        child: _buildCustomTextField("Favourite Music",
                            readOnly: false,
                            textEditingController: musicController),
                      ),
                      // ///TODO REPLACE EMAIL
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: paddingRes30, vertical: 8),
                        child: _buildCustomTextField("Favourite Band",
                            readOnly: false,
                            textEditingController: bandController),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: paddingRes30, vertical: 8),
                        child: _buildCustomTextField("Favourite Book",
                            readOnly: false,
                            textEditingController: bookController),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      Obx(() => profileController.loading.value
                          ? const SizedBox(
                              height: 40,
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                profileController.saveInfo(
                                    hobby: hobbyController.text,
                                    music: musicController.text,
                                    imageUrl: userMap['imageUrl'], book: bookController.text, band: bandController.text,metadata: metadata);
                              },
                              child: const Text('Save'))),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(String hintText,
      {bool readOnly = false,
      required TextEditingController textEditingController}) {
    return TextFormField(
      controller: textEditingController,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: hintText,
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)
            // borderSide: const BorderSide(color: darkMain, ),
            // borderRadius: BorderRadius.circular(30),
            ),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(30)
                // borderSide: const BorderSide(color: darkMain, ),
                // borderRadius: BorderRadius.circular(30),
                ),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(30)
                // borderSide: const BorderSide(color: darkMain, ),
                // borderRadius: BorderRadius.circular(30),
                ),
        disabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(30)
                // borderSide: const BorderSide(color: darkMain, ),
                // borderRadius: BorderRadius.circular(30),
                ),

        // isDense: true,
        filled: true,
        contentPadding: const EdgeInsets.only(top: 5, left: 25),
        fillColor: Colors.white,
      ),
      style: const TextStyle(
        color: Colors.black,
      ),
      cursorColor: Colors.black,
    );
  }
}

class UserPhotoWidget extends StatefulWidget {
  const UserPhotoWidget(
      {Key? key, required this.imageUrl, required this.profileController})
      : super(key: key);

  final String imageUrl;
  final ProfileController profileController;

  @override
  State<UserPhotoWidget> createState() => _UserPhotoWidgetState();
}

class _UserPhotoWidgetState extends State<UserPhotoWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await uploadPhotoId();
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: widget.profileController.pickedFile != null
                ? Image.file(
                    File(
                      widget.profileController.pickedFile!.path,
                    ),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover)
                : Image.network(widget.imageUrl,
                    height: 200, width: 200, fit: BoxFit.cover),
          ),
          Positioned(
              bottom: 0,
              right: 20,
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.photo_camera)))
        ],
      ),
    );
  }

  uploadPhotoId() async {
    widget.profileController.pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (widget.profileController.pickedFile != null) {
      setState(() {});
    }
  }
}
