import 'package:circle/screens/main_circle_modified.dart';
import 'package:circle/screens/select_circle_to_invite_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';


class InviteContactToCircleScreen extends StatelessWidget {
  InviteContactToCircleScreen({Key? key, required this.contact})
      : super(key: key);

  final Contact contact;
  final SelectCircleToInviteController requestsController =
      Get.put(SelectCircleToInviteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Select Circle'),
      ),
      body: StreamBuilder<List<types.Room>>(
        stream: (FirebaseChatCore.instance.rooms()),
        initialData: const [],
        builder: (context, AsyncSnapshot<List<types.Room>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('No Circles to Show'),
            );
          }

          print(snapshot.data!);

          return Column(
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Select the circles for which you want to invite ${contact.displayName} ", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];

                    if (room.type == types.RoomType.group) {
                      return SelectCircleToInviteWidget(
                        groupRoom: room,
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Obx(() => (requestsController.loading.value)
            ? const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : ElevatedButton(
                child: const Text("Send Invite"),
                onPressed: () async {
                  await requestsController.inviteUserToCircles(contact);
                  Get.to(const MainCircle());
                },
              )),
      ),
    );
  }
}

class SelectCircleToInviteWidget extends StatefulWidget {
  const SelectCircleToInviteWidget({Key? key, required this.groupRoom})
      : super(key: key);
  final types.Room groupRoom;

  @override
  _SelectCircleToInviteWidgetState createState() =>
      _SelectCircleToInviteWidgetState();
}

class _SelectCircleToInviteWidgetState
    extends State<SelectCircleToInviteWidget> {
  SelectCircleToInviteController addEventController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selected) {
          addEventController.invitedCircles
              .removeWhere((element) => element.id == (widget.groupRoom.id));
        } else {
          addEventController.invitedCircles.add(widget.groupRoom);
        }
        setState(() {
          selected = !selected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            _buildAvatar(widget.groupRoom),
            Text(widget.groupRoom.name!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            const Spacer(),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(types.Room room) {
    String imgUrl = widget.groupRoom.imageUrl ??
        "https://media.istockphoto.com/vectors/user-avatar-profile-icon-black-vector-illustration-vector-id1209654046?k=20&m=1209654046&s=612x612&w=0&h=Atw7VdjWG8KgyST8AXXJdmBkzn0lvgqyWod9vTb2XoE=";

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(imgUrl),
        radius: 30,
        child: null,
      ),
    );
  }
}
