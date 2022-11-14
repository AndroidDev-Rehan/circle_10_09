import 'package:circle/screens/chat_core/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';

import '../screens/select_circle_to_invite.dart';
import '../utils/constants.dart';

class PhoneContactTile extends StatefulWidget {
  const PhoneContactTile({Key? key, required this.contact, this.user})
      : super(key: key);
  final Contact contact;
  final types.User? user;

  @override
  State<PhoneContactTile> createState() => _PhoneContactTileState();
}

class _PhoneContactTileState extends State<PhoneContactTile> {
  bool loading = false;

  late final Uri _url;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.contact.phones.isEmpty) {
      return const SizedBox();
    }

    print(getValidPhoneNumber(widget.contact.phones.first.number));

    return _buildPhoneContact();
  }

  Widget _buildPhoneContact() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            (!(widget.contact.photo == null))
                ? CircleAvatar(
                    backgroundImage: MemoryImage(widget.contact.photo!),
                    radius: 30,
                  )
                : const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/user.png"),
                    radius: 30,
                  ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.displayName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.contact.phones.first.number,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            loading
                ? const SizedBox(
                    height: 40,
                    width: 80,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ))
                : ElevatedButton(
                    onPressed: () async {
                      print("object");
                      if (widget.user != null) {
                        setState(() {
                          loading = true;
                        });

                        types.Room room = await FirebaseChatCore.instance
                            .createRoom(widget.user!);
                        setState(() {
                          loading = false;
                        });

                        Get.to(() => ChatPage(room: room));
                      } else {
                        Get.to(() => InviteContactToCircleScreen(
                              contact: widget.contact,
                            ));
                      }
                    },
                    child: Text(widget.user == null ? "Invite" : "Chat"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.user == null ? Colors.green : null),
                  )
          ],
        ),
      ),
    );
  }
}
