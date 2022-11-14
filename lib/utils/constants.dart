import 'package:flutter/cupertino.dart';

class StringConstants{
  static const circleRequestsCollection = "circle_requests";
}

String? countryCode = WidgetsBinding.instance.window.locale.countryCode;

String getValidPhoneNumber(String phoneNo){

  // print("country code: $countryCode");

  if(phoneNo.startsWith("+")){
    return phoneNo.trim().replaceAll('(', '').replaceAll(')', '').replaceAll('-', '').replaceAll(" ", "");
  }

  phoneNo = phoneNo.trim().replaceAll('(', '').replaceAll(')', '').replaceAll('-', '').replaceAll(" ", "");
  String validPhoneNo = phoneNo;



  late String dialCode;
  if(countryCode==null){
    dialCode = "1";
  }
  else if (countryCode!.toUpperCase() == "PK"){
    dialCode = "92";
  }
  else {
    dialCode = "1";
  }

  // dialCode = "92";

  if (dialCode=="1"){

    if(phoneNo.contains("324456475")){
      print("dial code is 1");
    }

    // print("dial code is 1");

    if(phoneNo.length<=10){
      validPhoneNo = "+1" + phoneNo ;
    }

    else if(phoneNo.length>10 && phoneNo.startsWith("001")){
      validPhoneNo =  phoneNo.replaceFirst("001", "+1") ;
    }

    else if(phoneNo.length>10){
      validPhoneNo = "+" + phoneNo ;
    }

    return validPhoneNo;
  }

  else {

    if(phoneNo.contains("324456475")){
      print("dial code is 92");
    }


    if(phoneNo.startsWith("0")){
      validPhoneNo = phoneNo.replaceFirst("0", "+92") ;
    }

    else if(phoneNo.startsWith("92")){
      validPhoneNo = "+" + phoneNo;
    }

    return validPhoneNo;
  }


}