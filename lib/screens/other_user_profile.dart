import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'chat_core/chat.dart';


class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({Key? key, required this.otherUser}) : super(key: key);

  final types.User otherUser;

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  bool chatLoading = false;

  TextEditingController hobbyController = TextEditingController();
  TextEditingController musicController = TextEditingController();
  TextEditingController bookController = TextEditingController();
  TextEditingController bandController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    print(Get.width);
    double paddingRes30 = Get.width * 0.070093;
    Map metadata = widget.otherUser.metadata!;

    hobbyController.text = metadata['fvrtHobby'] ?? "";
    musicController.text = metadata['fvrtMusic'] ?? "";
    bandController.text = metadata['fvrtBand'] ?? "";
    bookController.text = metadata['fvrtBook'] ?? "";


    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(widget.otherUser.imageUrl!,
                  height: 200, width: 200, fit: BoxFit.cover) ,
            ),
            SizedBox(
              height: Get.height * 0.0777 * 0.5,
            ),
            Text((widget.otherUser.firstName ?? "") + ((widget.otherUser.lastName ?? "")), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: ()async{
                  await _handlePressed(context);
                  }, child: chatLoading ? const CircularProgressIndicator(
                  color: Colors.white,
                ) : const Text("Chat"),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(100, 40)
                  ),
                ),
                // SizedBox(width: 20,),
                ElevatedButton(onPressed: (){}, child: const Text("Add Friend"),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(100, 40)
                  ),
                )

              ],
            ),
            const SizedBox(height: 20,),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 16,),
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
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingRes30, vertical: 8),
              child: _buildCustomTextField("Favourite Hobby",
                hobbyController,
                readOnly: true,


              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingRes30, vertical: 8),
              child: _buildCustomTextField("Favourite Music",
                musicController,
                readOnly: false,
              ),
            ),
            // ///TODO REPLACE EMAIL
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingRes30, vertical: 8),
              child: _buildCustomTextField("Favourite Band",
                bandController,
                readOnly: false,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingRes30, vertical: 8),
              child: _buildCustomTextField("Favourite Book",
                bookController,
                readOnly: false,
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            // ElevatedButton(
            //     onPressed: () async {
            //       profileController.saveInfo(
            //           hobby: hobbyController.text,
            //           music: musicController.text,
            //           imageUrl: userMap['imageUrl'], book: bookController.text, band: bandController.text);
            //     },
            //     child: const Text('Save')),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField(String hintText,
      TextEditingController textEditingController,
      {bool readOnly = true,}) {
    return TextFormField(
      controller: textEditingController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: hintText,
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)
        ),
        enabledBorder:
        OutlineInputBorder(borderRadius: BorderRadius.circular(30)
        ),
        focusedBorder:
        OutlineInputBorder(borderRadius: BorderRadius.circular(30)
        ),
        disabledBorder:
        OutlineInputBorder(borderRadius: BorderRadius.circular(30)
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

  Future<void> _handlePressed( BuildContext context) async {

    setState(() {
      chatLoading = true;
    });

    final navigator = Navigator.of(context);
    print("other user: ${widget.otherUser}");
    final room = await FirebaseChatCore.instance.createRoom(widget.otherUser);

    // navigator.pop();

    setState(() {
      chatLoading = false;
    });


    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }
}


