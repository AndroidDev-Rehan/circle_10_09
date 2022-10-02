import 'package:circle/screens/Create_Circle_screen.dart';
import 'package:circle/screens/chat_core/search_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

// import '../users_for_group.dart';
import 'chat.dart';
import 'util.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({ this.onlyUsers = false});

  final bool onlyUsers;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  bool loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title:  Text((!widget.onlyUsers) ?  'Text Page' : "All Contacts"),
          actions: [
            InkWell(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.search),
                ),
              onTap: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                    return const SearchUsersScreen();
                  }));
              },

            )
          ],
        ),
        body: loading ? Center(child: CircularProgressIndicator(),) : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15,),
              (!widget.onlyUsers) ? Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 20),
                child: ElevatedButton(
                  onPressed:  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>  const CreateCirclePage(),
                      ),
                    );
                  },
                  child: const Text("Create a Circle"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue
                  ),
                ),
              ): const SizedBox(),
              // const SizedBox(height: 20,),
              !widget.onlyUsers ? const Text("Users: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.deepPurple),) : SizedBox(),
              const SizedBox(height: 10,),
              StreamBuilder<List<types.User>>(
                stream: FirebaseChatCore.instance.users(),
                initialData: const [],
                builder: (context, AsyncSnapshot<List<types.User>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
                        bottom: 200,
                      ),
                      child: const Text('No users'),
                    );
                  }

                  print(snapshot.data!);

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];

                      return InkWell(
                        onTap: () {
                          _handlePressed(user, context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              _buildAvatar(user),
                              Text(getUserName(user), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20,),
              !widget.onlyUsers ? Text("Circles: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.deepPurple),) : SizedBox(),
              !widget.onlyUsers ? StreamBuilder<List<types.Room>>(
                stream: FirebaseChatCore.instance.rooms(),
                initialData: const [],
                builder: (context,AsyncSnapshot<List<types.Room>> snapshot) {
                  print("Hiragino Kaku Gothic ProN");
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
                        bottom: 200,
                      ),
                      child: const Text('No Circles'),
                    );
                  }

                  try{
                    snapshot.data!
                        .sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
                  }
                  catch(e){
                    for (var element in snapshot.data!) {print(element.updatedAt);}
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),

                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final types.Room room = snapshot.data![index];

                      print("room type :${room.type}");

                      if( ((room.metadata == null) || (room.metadata!["isChildCircle"] == null) || (room.metadata!["isChildCircle"] == false)) && (room.type == (types.RoomType.group)) ){
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  room: room,
                                  groupChat: room.type == types.RoomType.group,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildAvatar1(room),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10,),
                                          room.type == types.RoomType.group ?
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                room.metadata?['status'] ?? ' status',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.normal,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              ),
                                              // Text(
                                              //   room.metadata?['privacy'] ?? 'undefined',
                                              //   style: const TextStyle(
                                              //       color: Colors.black,
                                              //       fontSize: 14,
                                              //       fontWeight: FontWeight.normal,
                                              //       fontStyle: FontStyle.italic
                                              //   ),
                                              // )
                                            ],
                                          ) : const SizedBox(),
                                          const SizedBox(height: 4),
                                          Text(
                                            room.name ?? 'no name',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  );
                },
              )
                  : SizedBox()

            ],
          ),
        ),
      );

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

  Widget _buildAvatar1(types.Room room) {
    var color = Colors.transparent;

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 25,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }


  void _handlePressed(types.User otherUser, BuildContext context) async {

    setState(() {
      loading = true;
    });

    final navigator = Navigator.of(context);
    print("other user: $otherUser");
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    // navigator.pop();

    setState(() {
      loading = false;
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
