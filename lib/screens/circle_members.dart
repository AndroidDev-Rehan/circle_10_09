import 'package:circle/widgets/single_user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class CircleMembersScreen extends StatelessWidget {
  const CircleMembersScreen({Key? key, required this.groupRoom}) : super(key: key);
  final types.Room groupRoom;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text(groupRoom.name!),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 16),
        child: StreamBuilder(
            stream: FirebaseChatCore.instance
                .room(groupRoom.id),
            builder: (context,
                AsyncSnapshot<types.Room> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 40,
                  child:
                  Center(child: Text("No Users to show")),
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox(
                  height: 40,
                  child: Center(
                      child: Text("Loading Users to show")),
                );
              }

              return ListView.builder(
                  itemCount: snapshot.data!.users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12.0),
                        child: Text(
                          "${snapshot.data!.users.length} Participants",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    types.User user =
                    snapshot.data!.users[index - 1];

                    List managers = (groupRoom
                        .metadata)?["managers"] ??
                        [];
                    managers = managers
                        .map((e) => e.toString())
                        .toList();

                    return SingleUserTile(
                      user: user,
                      groupRoom: groupRoom,
                      manager: managers.contains(user.id),
                    );
                  });
            }),
      ),
    );
  }
}
