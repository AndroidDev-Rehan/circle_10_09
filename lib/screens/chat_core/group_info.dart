import 'package:circle/group_info_controller.dart';
import 'package:circle/screens/add_event_screen.dart';
import 'package:circle/screens/calendar_list_events.dart';
import 'package:circle/screens/chat_core/add_group_members.dart';
import 'package:circle/screens/chat_core/view_nested_rooms.dart';
import 'package:circle/screens/chat_core/view_requests_page.dart';
import 'package:circle/screens/view_user_requests.dart';
import 'package:circle/utils/dynamiclink_helper.dart';
import 'package:circle/widgets/single_user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import '../main_circle_modified.dart';
import 'package:flutter/services.dart';

class GroupInfoScreen extends StatefulWidget {
  final types.Room groupRoom;

  const GroupInfoScreen({Key? key, required this.groupRoom}) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // bool loading = false;
  // bool updatingData = false;
  late String circleLink;
  final GroupInfoController groupInfoController = GroupInfoController();
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupDesController = TextEditingController();

  bool isManager = false;

  int reqCount = 0;

  @override
  initState() {
    groupNameController.text = widget.groupRoom.name!;
    groupDesController.text = widget.groupRoom.metadata!['description'] ?? "";

    List managers = (widget.groupRoom.metadata)?["managers"] ?? [];

    isManager = managers.contains(FirebaseAuth.instance.currentUser!.uid);

    Map metadata = widget.groupRoom.metadata ?? {};
    List req = metadata['userRequests'] ?? [];
    reqCount = req.length;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool tried = false;

    // print(widget.groupRoom.metadata);
    return FutureBuilder(
        future: _generateLink(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // print("into waiting");
            return Scaffold(
              appBar: AppBar(
                title: const Text("Circle Info"),
                centerTitle: true,
              ),
              body: const Center(
                child: Text("Generating group link .."),
              ),
            );
          }

          return Scaffold(
              appBar: AppBar(
                title: const Text("Circle Info"),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          widget.groupRoom.imageUrl ??
                              "https://media.istockphoto.com/vectors/user-avatar-profile-icon-black-vector-illustration-vector-id1209654046?k=20&m=1209654046&s=612x612&w=0&h=Atw7VdjWG8KgyST8AXXJdmBkzn0lvgqyWod9vTb2XoE=",
                          width: 100,
                          height: 100,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                              controller: groupNameController,
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Circle name can't be empty";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                label: Text(
                                  "Circle Name",
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25)),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 100,
                            child: TextFormField(
                              // initialValue: "",
                                controller: groupDesController,
                                validator: (String? value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Circle name can't be empty";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  label: Text(
                                    "Circle Description",
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                  hintText: "Enter Circle Description here"
                                ),
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal, fontSize: 20),
                              maxLines: null,
                              minLines: null,
                              readOnly: false,
                              expands: true,


                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Expanded(child: Text(circleLink)),
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
                    ),
                    const SizedBox(
                      height: 05,
                    ),

                    ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: circleLink));
                          Get.snackbar("Success", "Link Copied",
                              backgroundColor: Colors.white);
                        },
                        child: const Text("Copy Invite Link")),

                    MuteButton(groupRoom: widget.groupRoom),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ((widget.groupRoom.metadata != null) &&
                                (widget.groupRoom.metadata!["isChildCircle"] ??
                                    false))
                            ? SizedBox()
                            : Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Get.off(AddMembersScreen(
                                          groupRoom: widget.groupRoom, invite : true));
                                    },
                                    child:  Text((widget.groupRoom.metadata!["isChildCircle"] ?? false) ? "Add Users" : "Invite Users")),
                              ),
                        SizedBox(
                          width: (widget.groupRoom.metadata != null) &&
                                  (widget.groupRoom
                                          .metadata!["isChildCircle"] ??
                                      false)
                              ? 0
                              : 20,
                          height: 0,
                        ),
                        ((widget.groupRoom.metadata != null) &&
                                (widget.groupRoom.metadata!["isChildCircle"] ??
                                    false))
                            ? const SizedBox()
                            : Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Get.off(ViewNestedRoom(
                                          user: FirebaseAuth
                                              .instance.currentUser!,
                                          parentRoom: widget.groupRoom));
                                    },
                                    child: const Text("View Inner Circles")),
                              )
                      ],
                    ),
                    const SizedBox(
                      height: 00,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () async {
                                TextEditingController idController =
                                    TextEditingController();
                                Map? userMap;
                                tried = false;
                                await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text('Enter User Id'),
                                          content: TextFormField(
                                            controller: idController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              focusedBorder:
                                                  OutlineInputBorder(),
                                              enabledBorder:
                                                  OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel")),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  tried = true;
                                                  DocumentSnapshot<Map>
                                                      documentSnapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("users")
                                                          .doc(
                                                              idController.text)
                                                          .get();
                                                  userMap =
                                                      documentSnapshot.data();
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Confirm"))
                                          ],
                                        ));

                                if (userMap != null) {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: const Text('User Found'),
                                            content: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircleAvatar(
                                                    // backgroundColor: hasImage ? Colors.transparent : color,
                                                    backgroundImage:
                                                        NetworkImage(userMap![
                                                            "imageUrl"]),
                                                    radius: 40,
                                                    child: null,
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                      "${userMap!['firstName']} ${userMap!['lastName']}")
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Cancel")),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    try {
                                                      // await FirebaseFirestore.instance.collection("rooms")
                                                      //     .doc(widget.groupRoom.id)
                                                      //     .update({"users": userIds});
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("rooms")
                                                          .doc(widget
                                                              .groupRoom.id)
                                                          .update({
                                                        "userIds": FieldValue
                                                            .arrayUnion([
                                                          idController.text
                                                        ])
                                                      });
                                                      Navigator.pop(context);
                                                      Get.snackbar("Success",
                                                          "${userMap!['firstName']} is added to circle",
                                                          backgroundColor:
                                                              Colors.white);
                                                    } catch (e) {
                                                      Get.snackbar("error",
                                                          e.toString());
                                                      print(e);
                                                    }
                                                  },
                                                  child: Text("Add"))
                                            ],
                                          ));
                                } else if (tried) {
                                  Get.snackbar("Sorry", "No user found",
                                      backgroundColor: Colors.white);
                                }
                              },
                              child: const Text("Add User by uid")),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  Get.to(CalendarListEventsScreen(
                                      circleId: widget.groupRoom.id));
                                },
                                child: Text("View Circle Events")))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    isManager
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder(
                                stream: FirebaseChatCore.instance.room(widget.groupRoom.id),
                                builder: (BuildContext context,AsyncSnapshot<types.Room> snapshot) {
                                  if(!(snapshot.connectionState==ConnectionState.waiting || (!(snapshot.hasData)))) {
                                    types.Room newRoom = snapshot.data!;
                                    Map metadata = newRoom.metadata ?? {};
                                    List req = metadata['userRequests'] ?? [];
                                    reqCount = req.length;
                                  }

                                  return ElevatedButton(
                                      onPressed: () {
                                        Get.to(ViewUserRequestsPage(
                                            groupRoom: widget.groupRoom));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("View Circle Requests  "),
                                          reqCount != 0 ?Text("($reqCount)", style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),) : SizedBox()

                                        ],
                                      ));
                                }
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          )
                        : const SizedBox(),
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
                                      "Circle Id:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(child: Text(widget.groupRoom.id)),
                                    IconButton(
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: widget.groupRoom.id));
                                          Get.snackbar("Success",
                                              "Circle Id Copied to Clipboard",
                                              backgroundColor: Colors.white);
                                        },
                                        icon: const Icon(Icons.copy_outlined))
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
                      height: 20,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 8.0),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         "${widget.groupRoom.users.length} Participants",
                    //         style: const TextStyle(
                    //             fontSize: 18, fontWeight: FontWeight.bold),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),

                    // Text(groupRoom.name!,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    FutureBuilder(
                        future: allowedToSeeUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.data == false) {
                            return SizedBox();
                          }
                          return StreamBuilder(
                              stream: FirebaseChatCore.instance
                                  .room(widget.groupRoom.id),
                              builder: (context,
                                  AsyncSnapshot<types.Room> snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox(
                                    height: 40,
                                    child:
                                        Center(child: Text("No Users to show")),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    height: 40,
                                    child: Center(
                                        child: Text("Loading Users to show")),
                                  );
                                }

                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
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

                                      List managers = (widget.groupRoom
                                              .metadata)?["managers"] ??
                                          [];
                                      managers = managers
                                          .map((e) => e.toString())
                                          .toList();

                                      return SingleUserTile(
                                        user: user,
                                        groupRoom: widget.groupRoom,
                                        manager: managers.contains(user.id),
                                      );
                                    });
                              });
                        }),
                  ],
                ),
              ),
              bottomNavigationBar: Obx(() => groupInfoController.loading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16),
                      child: ElevatedButton(
                        child: const Text("Save Info"),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // print("hello");
                            await _updateGroupNameAndDesc();
                            Get.offAll(
                              const MainCircle(),
                            );
                          }
                        },
                      ),
                    )));
        });
  }

  Future<bool> allowedToSeeUsers() async {
    if ((widget.groupRoom.metadata == null) ||
        (widget.groupRoom.metadata!["isChildCircle"] ?? false)) {
      return true;
    }

    List childCircles = widget.groupRoom.metadata?["childCircles"] ?? [];

    for (int i = 0; i < childCircles.length; i++) {
      types.Room room =
          await FirebaseChatCore.instance.room(childCircles[i]).first;
      List roomUsersIds = room.users.map((types.User user) => user.id).toList();

      if (roomUsersIds.contains(FirebaseAuth.instance.currentUser!.uid)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _generateLink() async {
    // if ((widget.groupRoom.metadata != null) &&
    //     (widget.groupRoom.metadata!['link'] != null)) {
    //   circleLink = widget.groupRoom.metadata!['link'];
    //   return;
    // }

    circleLink = await DynamicLinkHelper.createDynamicLink(widget.groupRoom.id);

    Map metadata = widget.groupRoom.metadata ?? {};
    metadata["link"] = circleLink;

    FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.groupRoom.id)
        .update({'metadata': metadata});
  }

  Future<void> _updateGroupNameAndDesc() async {
    // setState(() {
    //   loading = true;
    // });

    groupInfoController.loading.value = true;

    Map metadata = widget.groupRoom.metadata ?? {};
    metadata['description'] = groupDesController.text;

    await FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.groupRoom.id)
        .update({"name": groupNameController.text, 'metadata' : metadata});

    groupInfoController.loading.value = false;
  }
}

class MuteButton extends StatefulWidget {
  final types.Room groupRoom;

  const MuteButton({Key? key, required this.groupRoom}) : super(key: key);

  @override
  State<MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<MuteButton> {
  bool muted = false;
  List mutedIds = [];
  Map metadata = {};
  bool loading = false;

  @override
  void initState() {
    metadata = widget.groupRoom.metadata ?? {};
    mutedIds = metadata['mutedBy'] ?? [];
    for (var element in mutedIds) {
      element = element.toString();
    }

    ///If already muted
    if (mutedIds.contains(FirebaseAuth.instance.currentUser!.uid)) {
      muted = true;
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                loading = true;
              });

              if (muted) {
                mutedIds.removeWhere((element) =>
                    element == FirebaseAuth.instance.currentUser!.uid);
                muted = false;
              } else {
                mutedIds.add(FirebaseAuth.instance.currentUser!.uid);
                muted = true;
              }

              metadata['mutedBy'] = mutedIds;
              await FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(widget.groupRoom.id)
                  .update({'metadata': metadata});
              setState(() {
                loading = false;
              });

              if(muted){
                Get.snackbar("Success", "Circle Muted",
                    backgroundColor: Colors.white);

              }
              else{
                Get.snackbar("Success", "Circle Unmuted",
                    backgroundColor: Colors.white);

              }

            },
            child: Text(muted ? "Unmute" : "Mute"),
            style: ElevatedButton.styleFrom(
              primary: !muted ? Colors.red : Colors.green,
            ),
          );
  }
}
