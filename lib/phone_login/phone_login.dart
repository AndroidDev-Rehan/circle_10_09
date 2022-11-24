import 'package:circle/phone_login/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../screens/main_circle_modified.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {

  // final TextEditingController _texFieldController = TextEditingController();

  String phoneNo = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            const SizedBox(height: 20,),
            const Text("Login"),
            const SizedBox(height: 10,),
            Image.asset("assets/images/Circle.jpg", width: 400, height: 80),

            SizedBox(height: 30,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'US',
                onChanged: (phone) {
                  phoneNo = phone.completeNumber;
                  print(phoneNo);
                },
              ),
            ),

            // Row(
            //   children: [
            //     Padding(
            //       padding:
            //       const EdgeInsets.symmetric(horizontal: 9, vertical: 16),
            //       child: TextFormField(
            //         controller: _texFieldController,
            //         decoration: const InputDecoration(
            //           border: UnderlineInputBorder(),
            //           labelText: 'Enter your phoneNo',
            //         ),
            //         keyboardType: TextInputType.number,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(
              width: 300,
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: 300,
                child:
                ElevatedButton(
                  onPressed: () async{

                    Get.off(OtpScreen(phoneno: phoneNo.contains("+") ? phoneNo : "+${phoneNo}"));

                    // Future<String?> user  = FireAuth.signInUsingEmailPassword(email: _texFieldController.text, password: _texFieldController2.text, context:context);

                    // if(FirebaseAuth.instance.currentUser!=null){
                    //   await getUserMap(FirebaseAuth.instance.currentUser!.uid);
                    // }


                    // user.then((value) => {
                    //   if(value == null)
                    //     {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(builder:(context) => const MainCircle()),
                    //       ),
                    //     }else {
                    //     showAlert(context,value),
                    //   }
                    // },onError: (err){
                    //   showAlert(context,err);
                    // });
                  },
                  child: const Text("Send OTP"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
