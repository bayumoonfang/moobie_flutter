
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';

import 'package:moobie_flutter/Helper/app_link.dart';
import 'package:moobie_flutter/Helper/connection_check.dart';
import 'package:moobie_flutter/Helper/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHelper{
   String getUserEmail ;
   static var today = new DateTime.now();
   var getBulan = new DateFormat.MMMM().format(today);
   var getTahun = new DateFormat.y().format(today);

   Future<String> getConnect() async {
     ConnectionCheck().check().then((internet){
       if (internet != null && internet) {} else {
          return "ConnInterupted";
       }
     });
   }

   Future<dynamic> getSession () async {
     int value = await Session.getValue();
     String getEmail = await Session.getEmail();
     return [value,getEmail];
   }



  Future<dynamic> getDetailUser(String getValue) async {
    http.Response response = await http.Client().get(
        Uri.parse(applink+"api_model.php?act=userdetail&id="+getValue.toString()+""),
        headers: {
            "Content-Type": "application/json",
           "Accept": "application/json"}).timeout(
            Duration(seconds: 10),onTimeout: (){
             http.Client().close();
             return http.Response('Error',500);
          }
        );
        var data = jsonDecode(response.body);
        return [
          data["d"].toString(),
          data["c"].toString(),
          data["m"].toString(),
          data["b"].toString(),
          data["j"].toString()];
  }


}



