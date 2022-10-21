import 'package:circle/logoutController.dart';
import 'package:circle/phone_login/phone_login.dart';
import 'package:circle/screens/all_circles_screen.dart';
import 'package:circle/screens/chat_core/search_chat_screen.dart';
import 'package:circle/screens/chat_core/search_users.dart';
import 'package:circle/screens/chat_core/users.dart';
import 'package:circle/screens/contacts_screen.dart';
import 'package:circle/screens/profile_screen.dart';
import 'package:circle/screens/selectCircleToJoin.dart';
import 'package:circle/screens/view_circle_page.dart';
import 'package:circle/screens/view_event_invites.dart';
import 'package:circle/userinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:circle/screens/Create_Circle_screen.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../notification_service/local_notification_service.dart';
import '../utils/db_operations.dart';
import 'calendar_list_events.dart';
import 'chat_core/rooms.dart';
import 'chat_core/view_requests_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MainCircle extends StatefulWidget {
  const MainCircle({Key? key}) : super(key: key);
  @override
  State<MainCircle> createState() => MainCircleState();
}

class MainCircleState extends State<MainCircle> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();

  int index = 0;
  @override
  State<MainCircle> createState() => MainCircleState();

  void viewMyCircles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const viewCircle()),
    );
  }

  @override
  void initState() {
    super.initState();

    /// 1. This method call when app in terminated state and you get a notification
    /// when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          print(message.notification?.title);
          print(message.notification?.body);
          print("notification data: ${message.data}");

          if((message.notification?.title?.toLowerCase().contains("invite") ?? false) || (message.notification?.body?.toLowerCase().contains("invite") ?? false)){
            Get.to(const ViewRequestsPage());
          }

          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    /// 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
          if((message.notification?.title?.toLowerCase().contains("invite") ?? false) || (message.notification?.body?.toLowerCase().contains("invite") ?? false)){
            print("contains invite word");
            Get.to(const ViewRequestsPage());
          }
        }
      },
    );

    /// 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data}");
          if((message.notification?.title?.toLowerCase().contains("invite") ?? false) || (message.notification?.body?.toLowerCase().contains("invite") ?? false)){
            Get.to(const ViewRequestsPage());
          }

        }
      },
    );
  }

  int _currentIndex = 0;

  LogOutController logOutController = LogOutController();

  Map<String, dynamic>? userMap;

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser!.uid);
    // print(FirebaseChatCore.instance.firebaseUser);

    // TODO: implement build
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          key: _scaffoldKey1,
          drawer: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                userMap = snapshot.data?.data();
                Map metadata = userMap?['metadata'] ?? {};

                if (userMap != null) {
                  CurrentUserInfo.userMap = userMap;
                  metadata = userMap!['metadata'];
                }


                return Drawer(
                  child: Container(
                    color: Colors.blue,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          padding: EdgeInsets.zero,
                          child: UserAccountsDrawerHeader(
                            margin: EdgeInsets.zero,
                            accountName: userMap == null
                                ? Text('username')
                                : Text(
                                    "${userMap!["firstName"]} ${userMap!["lastName"]}"),
                            accountEmail: Text(
                                metadata['user_id'] ?? ""),
                            currentAccountPicture: userMap == null
                                ? null
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userMap!["imageUrl"]),
                                  ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            CupertinoIcons.home,
                            color: Colors.white,
                          ),
                          title: const Text(
                            "Home",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Get.off(const MainCircle());
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            CupertinoIcons.search_circle_fill,
                            color: Colors.white,
                          ),
                          title: const Text(
                            "Search Circles",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            Get.to(const SearchChatScreen());
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            CupertinoIcons.search,
                            color: Colors.white,
                          ),
                          title: const Text(
                            "Search Users",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            Get.to(const SearchUsersScreen());
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            CupertinoIcons.add,
                            color: Colors.white,
                          ),
                          title: const Text(
                            "Create a Circle",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            Get.to(CreateCirclePage());
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            CupertinoIcons.person_2,
                            color: Colors.white,
                          ),
                          title: const Text(
                            "Select Users",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            Get.to(UsersPage());
                          },
                        ),
                        // ListTile(
                        //   leading: Icon(
                        //     CupertinoIcons.checkmark_circle,
                        //     color: Colors.white,
                        //   ),
                        //   title: Text(
                        //     "Join A Circle",
                        //     textScaleFactor: 1.2,
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        //   onTap: () async {
                        //     Get.back();
                        //     await joinCircleById();
                        //     // Get.off(MainCircle());
                        //   },
                        // ),
                        // ListTile(
                        //   leading: Icon(
                        //     CupertinoIcons.arrow_up_down_circle_fill,
                        //     color: Colors.white,
                        //   ),
                        //   title: Text(
                        //     "View All Circles",
                        //     textScaleFactor: 1.2,
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        //   onTap: () async {
                        //     Get.back();
                        //     Get.to(AllCirclesScreen());
                        //     // await joinCircleById();
                        //     // Get.off(MainCircle());
                        //   },
                        // ),
                        // ListTile(
                        //   leading: Icon(
                        //     CupertinoIcons.arrow_down_circle,
                        //     color: Colors.white,
                        //   ),
                        //   title: Text(
                        //     "Circle Invites",
                        //     textScaleFactor: 1.2,
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        //   onTap: () async {
                        //     Get.back();
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) =>
                        //           const ViewRequestsPage()),
                        //     );
                        //
                        //   },
                        // ),
                        ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          title: Text(
                            "Log Out",
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () async {
                            Get.back();
                            await logout();
                          },
                        )
                      ],
                    ),
                  ),
                );
              }),
          backgroundColor: Colors.lightBlue,
          appBar: AppBar(
            elevation: 10.0,
            shadowColor: Colors.white70,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
              side: BorderSide(width: 0.7),
            ),
            title: const Text(
              'Circle',
              style: TextStyle(
                  fontSize: 25.0, fontFamily: 'Lora', letterSpacing: 1.0),
            ),
            bottom: _bottom(),
            actions: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 10.0),
              //   child: Obx(() => (!logOutController.loading.value)
              //       ? IconButton(
              //           // tooltip: 'Refresh',
              //           icon: const Icon(
              //             Icons.logout_outlined,
              //             size: 25.0,
              //           ),
              //           onPressed: () async {
              //             // print('Hiragino Kaku Gothic ProN');
              //             await logout();
              //           })
              //       : SizedBox(
              //           height: 25,
              //           width: 25,
              //           child: CircularProgressIndicator(),
              //         )),
              // ),
              InkWell(
                onTap: () {
                  // print("Hiragino Kaku Gothic ProN");
                  Get.to(const SearchChatScreen());
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(
                    CupertinoIcons.search_circle,
                    size: 25.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(
                      CupertinoIcons.refresh_circled,
                      size: 25.0,
                    ),
                    onPressed: () async {
                      Get.offAll(() => const MainCircle());
                      // print('Clicked Refresh in Main Window');
                    }),
              ),
            ],
          ),
          body: (_currentIndex == 1)
              ? const RoomsPage(
                  secondVersion: true,
                )
              : SafeArea(
                  top: false,
                  bottom: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: <Widget>[
                          ElevatedButton(
                              child: const Text("View My Circles"),
                              onPressed: () {
                                Get.to(const RoomsPage());
                                // viewMyCircles(context);
                              }),
                          ElevatedButton(
                              child: const Text("View All Circles"),
                              onPressed: () {
                                Get.to(const AllCirclesScreen());
                                // viewMyCircles(context);
                              }),
                          ElevatedButton(
                              child: const Text("  Join a Circle  "),
                              onPressed: () async{
                                Get.to(const SelectCircleToJoinScreen());
                                // Get.to(AllCirclesScreen());
                                // viewMyCircles(context);
                              }),
                          ElevatedButton(
                              child: const Text("Create A Circle"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateCirclePage()),
                                );
                              }),
                          ElevatedButton(

                              ///VIEW CIRCLE INVITES REPLACEMENT
                              child: const Text("        Profile      "),
                              onPressed: () {
                                Get.to(ProfileScreen());
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //       const ViewRequestsPage()),
                                // );
                              }),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance.collection("rooms").snapshots(),
                            builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {

                              if(snapshot.connectionState == ConnectionState.waiting || (!(snapshot.hasData))){
                                return ElevatedButton(
                                    child: const Text(" Circle Invites "),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const ViewRequestsPage()),
                                      );
                                    });
                              }

                              int count = 0;

                              QuerySnapshot<Map<String,dynamic>> allRoomsCollection = snapshot.data!;

                              for (int i=0; i<allRoomsCollection.docs.length; i++){


                                final Map<String,dynamic> map  = allRoomsCollection.docs[i].data();

                                if(map["requests"] == null){
                                  continue;
                                }

                                final List requests = map["requests"] ?? [];


                                if(requests.contains(FirebaseAuth.instance.currentUser!.uid)){
                                  // print("trying");
                                  // print(map);
                                  count = count +1;
                              }
                              }


                              return ElevatedButton(
                                  child: Row(
                                    children: [
                                      const Text("Circle Invites  "),
                                      count != 0 ?Text("($count)", style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),) : SizedBox()
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const ViewRequestsPage()),
                                    );
                                  });
                            }
                          ),

                          StreamBuilder(
                              stream: FirebaseFirestore.instance.collection("events").snapshots(),
                              builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {

                                if(snapshot.connectionState == ConnectionState.waiting || (!(snapshot.hasData))){
                                  return ElevatedButton(
                                      child: const Text(" Event Invites "),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const ViewEventInvites()),
                                        );
                                      });
                                }

                                int count = 0;

                                QuerySnapshot<Map<String,dynamic>> allEventsCollection = snapshot.data!;

                                for (int i=0; i<allEventsCollection.docs.length; i++){


                                  final EventModel event  = EventModel.fromMap(allEventsCollection.docs[i].data());


                                  if(event.invitedUsers.contains(FirebaseAuth.instance.currentUser!.uid)){
                                    // print("trying");
                                    // print(map);
                                    count = count +1;
                                  }
                                }


                                return ElevatedButton(
                                    child: Row(
                                      children: [
                                        const Text("Event Invites  "),
                                        count != 0 ?Text("($count)", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),) : SizedBox()
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const ViewEventInvites()),
                                      );

                                    });
                              }
                          ),

                          ElevatedButton(

                            ///VIEW CIRCLE INVITES REPLACEMENT
                              child: const Text("          Text         "),
                              onPressed: () {
                                Get.to(const UsersPage());
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //       const ViewRequestsPage()),
                                // );
                              }),
                          ElevatedButton(

                            ///VIEW CIRCLE INVITES REPLACEMENT
                              child: const Text("   Circle Users   "),
                              onPressed: () {
                                Get.to(const UsersPage(onlyUsers: true,));
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //       const ViewRequestsPage()),
                                // );
                              }),
                          ElevatedButton(

                            ///VIEW CIRCLE INVITES REPLACEMENT
                              child: const Text("View Circles Events", style: TextStyle(fontSize: 15),),
                              onPressed: () {
                                Get.to(CalendarListEventsScreen(circleId: 'global',));
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //       const ViewRequestsPage()),
                                // );
                              }),
                          ElevatedButton(

                            ///VIEW CIRCLE INVITES REPLACEMENT
                              child: const Text("View Phone Contacts", style: TextStyle(fontSize: 15),),
                              onPressed: () {
                                Get.to(ViewPhoneContactsScreen());
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //       const ViewRequestsPage()),
                                // );
                              }),


                        ],
                      ),
                      // const NavigationBarItem(label: "messaging",icon: CupertinoIcons.bubble_left_bubble_right,),
                      // const NavigationBarItem(label: "home",icon: Icons.home,),
                      // const NavigationBarItem(label: "setting",icon: Icons.settings,)
                    ],
                  ),
                ),

          ///BOTTOM NAVIGATION BAR

          // bottomNavigationBar: BottomNavigationBar(
          //   backgroundColor: Colors.blue[600],
          //   onTap: (index) {
          //     print("hi");
          //     // setState(() {
          //     //   this.index = index;
          //     // });
          //
          //     if (index == 1) {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => RoomsPage()),
          //       );
          //       // _scaffoldKey1.currentState!.openDrawer();
          //     }
          //
          //     // else if (index == 2) {
          //     //   Navigator.push(
          //     //     context,
          //     //     MaterialPageRoute(builder: (context) => RoomsPage()),
          //     //   );
          //     // }
          //   },
          //   items: const [
          //     BottomNavigationBarItem(
          //       label: 'Home',
          //       icon: Icon(CupertinoIcons.home),
          //     ),
          //     // BottomNavigationBarItem(
          //     //   label: 'Profile',
          //     //   icon: Icon(
          //     //     Icons.group,
          //     //   ),
          //     // ),
          //     BottomNavigationBarItem(
          //       label: 'Chat',
          //       icon: Icon(
          //         CupertinoIcons.chat_bubble,
          //       ),
          //     ),
          //   ],
          // )),
    ));
  }

  // _createDynamicLink() async {
  //   print("staring  ..");
  //   final dynamicLinkParams = DynamicLinkParameters(
  //     link: Uri.parse("https://circledev.page.link/circle/007"),
  //     uriPrefix: "https://circledev.page.link",
  //     androidParameters: const AndroidParameters(
  //         packageName: "com.example.circle", minimumVersion: 1),
  //     iosParameters: const IOSParameters(bundleId: "com.example.circle"),
  //     // longDynamicLink: Uri.parse("https://circledev.page.link/circle?id=120")
  //   );
  //
  //   final Uri dynamicLink =
  //       await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
  //   print(dynamicLink);
  //
  //   // final ShortDynamicLink shortenedLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
  //
  //   final PendingDynamicLinkData? x =
  //       await FirebaseDynamicLinks.instance.getDynamicLink(dynamicLink);
  //   final PendingDynamicLinkData? y = await FirebaseDynamicLinks.instance
  //       .getDynamicLink(Uri.parse("https://circledev.page.link/circles"));
  //   // final PendingDynamicLinkData? z = await FirebaseDynamicLinks.instance.getDynamicLink(shortenedLink.shortUrl);
  //
  //   // print(x);
  //   print(y);
  //   // print(z);
  //
  //   // print("short url : $z");
  //
  //   // return shortenedLink.shortUrl;
  // }

  Future<void> logout() async {
    print('hi');

    logOutController.loading.value = true;

    try {
      String fcmToken = await DBOperations.getDeviceTokenToSendNotification();
      // List<String> tokenList = [fcmToken];

      if (userMap == null) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get();
        userMap = documentSnapshot.data()!;
      }

      Map metadata = userMap!['metadata'];

      List previousTokens = metadata['fcmTokens'];
      previousTokens.removeWhere((dynamic element) {
        return element.toString() == fcmToken.toString();
      });

      metadata['fcmTokens'] = previousTokens;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"metadata": metadata});
    } catch (e) {
      print(e);
      rethrow;
    }

    await FirebaseAuth.instance.signOut();

    logOutController.loading.value = false;
    CurrentUserInfo.userMap = null;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return PhoneLoginScreen();
    }));
  }

  // Future<void> joinCircleById() async {
  //   {
  //     TextEditingController idController = TextEditingController();
  //     // Map? circleMap;
  //     types.Room? room;
  //     bool tried = false;
  //     await showDialog(
  //         context: context,
  //         builder: (_) => AlertDialog(
  //               title: const Text('Enter Circle Id'),
  //               content: TextFormField(
  //                 controller: idController,
  //                 decoration: const InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   focusedBorder: OutlineInputBorder(),
  //                   enabledBorder: OutlineInputBorder(),
  //                   isDense: true,
  //                 ),
  //               ),
  //               actions: [
  //                 ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text("Cancel")),
  //                 ElevatedButton(
  //                     onPressed: () async {
  //                       if (idController.text.isEmpty) {
  //                         Get.snackbar("Error", "Id cant be null");
  //                         return;
  //                       }
  //
  //                       tried = true;
  //                       try {
  //                         room = await FirebaseChatCore.instance
  //                             .room(idController.text)
  //                             .first;
  //                       } catch (e) {
  //                         room = null;
  //                       }
  //
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text("Confirm"))
  //               ],
  //             ));
  //
  //     bool alreadyJoined = false;
  //
  //     if (room != null) {
  //       for (var element in room!.users) {
  //         if (element.id == FirebaseAuth.instance.currentUser!.uid) {
  //           alreadyJoined = true;
  //           break;
  //         }
  //       }
  //
  //       await showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //                 title: const Text('Join Circle'),
  //                 content: Container(
  //                   margin: const EdgeInsets.only(right: 16),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       CircleAvatar(
  //                         // backgroundColor: hasImage ? Colors.transparent : color,
  //                         backgroundImage: NetworkImage(room!.imageUrl ??
  //                             'https://media.istockphoto.com/vectors/user-avatar-profile-icon-black-vector-illustration-vector-id1209654046?k=20&m=1209654046&s=612x612&w=0&h=Atw7VdjWG8KgyST8AXXJdmBkzn0lvgqyWod9vTb2XoE='),
  //                         radius: 40,
  //                         child: null,
  //                       ),
  //                       const SizedBox(
  //                         height: 15,
  //                       ),
  //                       Text(room?.name ?? "room")
  //                     ],
  //                   ),
  //                 ),
  //                 actions: [
  //                   ElevatedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Text("Cancel")),
  //                   ElevatedButton(
  //                       onPressed: alreadyJoined
  //                           ? null
  //                           : () async {
  //                               try {
  //                                 // await FirebaseFirestore.instance.collection("rooms")
  //                                 //     .doc(widget.groupRoom.id)
  //                                 //     .update({"users": userIds});
  //                                 await FirebaseFirestore.instance
  //                                     .collection("rooms")
  //                                     .doc(idController.text)
  //                                     .update({
  //                                   "userIds": FieldValue.arrayUnion([
  //                                     FirebaseAuth.instance.currentUser!.uid
  //                                   ])
  //                                 });
  //                                 Navigator.pop(context);
  //                                 Get.snackbar("Success",
  //                                     "you are added to ${room?.name ?? 'circle'}",
  //                                     backgroundColor: Colors.white);
  //                               } catch (e) {
  //                                 Get.snackbar("error", e.toString());
  //                                 print(e);
  //                               }
  //                             },
  //                       child: const Text("Join"))
  //                 ],
  //               ));
  //     } else if (tried == true && room == null) {
  //       Get.snackbar("Sorry", "No circle found", backgroundColor: Colors.white);
  //     }
  //   }
  // }

  PreferredSizeWidget? _bottom() {
    return TabBar(
      indicatorPadding: EdgeInsets.only(left: 20.0, right: 20.0),
      labelColor: Colors.blueGrey,
      unselectedLabelColor: Colors.white70,
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: Colors.black87),
          insets: EdgeInsets.symmetric(horizontal: 15.0)),
      automaticIndicatorColorAdjustment: true,
      labelStyle: const TextStyle(
        fontFamily: 'Lora',
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
      onTap: (index) {
        // print("\nIndex is:$index");
        if (mounted) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      tabs: const [
        Tab(
          child: Text(
            'Home Page',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Tab(
          child: Text(
            'Chats',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

}

class NavigationBarItem extends StatelessWidget {
  const NavigationBarItem({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        // print('context');
      },
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(
              height: 8,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
