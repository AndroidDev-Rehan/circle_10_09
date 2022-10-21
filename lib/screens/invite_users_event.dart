import 'package:circle/screens/main_circle_modified.dart';
import 'package:circle/screens/select_events_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';

import 'chat_core/util.dart';

class InviteUsersEventScreen extends StatelessWidget {
  InviteUsersEventScreen({Key? key, required this.eventId}) : super(key: key);

  final String eventId;
  final AddEventController requestsController = Get.put(AddEventController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Add Contacts'),
      ),
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, AsyncSnapshot<List<types.User>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('No contacts'),
            );
          }

          print(snapshot.data!);

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];

              return SelectInviteUserWidget(
                user: user,
              );
            },
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
                child: const Text("Invite Users"),
                onPressed: requestsController.invitedUsers.isEmpty
                    ? null
                    : () async {
                        await requestsController.inviteUsers(eventId);
                        Get.to(const MainCircle());
                      },
              )),
      ),
    );
  }
}

class SelectInviteUserWidget extends StatefulWidget {
  const SelectInviteUserWidget({Key? key, required this.user}) : super(key: key);
  final types.User user;

  @override
  State<SelectInviteUserWidget> createState() => _SelectInviteUserWidgetState();
}

class _SelectInviteUserWidgetState extends State<SelectInviteUserWidget> {
  AddEventController addEventController = Get.find();

  @override
  void initState(){

    super.initState();
  }

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(selected){
          addEventController.invitedUsers.removeWhere((element) => element.id==(widget.user.id));
        }
        else{
          addEventController.invitedUsers.add(widget.user);
        }
        setState(() {
          selected=!selected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            _buildAvatar(widget.user),
            Text(getUserName(widget.user)),
            const Spacer(),
            Icon( selected ? Icons.check_circle   : Icons.circle_outlined, color: Colors.purple,),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(types.User user) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

}
