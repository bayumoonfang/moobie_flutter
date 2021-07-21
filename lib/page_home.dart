
import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:moobie_flutter/Helper/app_helper.dart';
import 'package:moobie_flutter/Helper/app_link.dart';
import 'package:moobie_flutter/Helper/color_based.dart';
import 'package:http/http.dart' as http;
import 'package:moobie_flutter/Helper/page_route.dart';
import 'package:moobie_flutter/Helper/session.dart';
import 'package:moobie_flutter/Jualan/page_jualan.dart';
import 'package:toast/toast.dart';


class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> {
  List data,data2;
  var client = http.Client();
  Timer timer;
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
  //=============================================================================
  String getEmail = '...';
  String getMoobiIdentity = '...';
  String getBranch = '...';
  String getUserID = '...';
  String getStorename = '...';
  String getNamaUser = '...';
  _startingVariable() async {
    await AppHelper().getConnect().then((value){if(value == 'ConnInterupted'){
      showToast("Koneksi terputus..", gravity: Toast.CENTER,duration:
      Toast.LENGTH_LONG);}});
       /*AppHelper().getSession().then((value){if(value[0] != 1) {
       Navigator.pushReplacement(context, ExitPage(page: Home()));} else{
       getEmail = value[1];}});*/
    await AppHelper().getDetailUser("bayumoonfang@gmail.com").then((value){
      setState(() {
        getMoobiIdentity = value[0];
        getBranch = value[1];
        getUserID = value[2];
        getStorename = value[3];
        getNamaUser = value[4];
      });
    });
  }

  ReloadData() async {
    setState(() {
      getDataTotalNotif();
      getDataTotal();
    });
  }



  void _loaddata() async {
    await _startingVariable();
  }

  @override
  void initState() {
    super.initState();
    _loaddata();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => {
      ReloadData()
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<List> getDataTotalNotif() async {
    http.Response response = await client.get(
        Uri.parse(applink+"api_model.php?act=getdata_totalnotif&userid="
            +getUserID.toString()),
        headers: {"Accept":"application/json"}
    );
 return json.decode(response.body);
  }

  Future<List> getDataTotal() async {
    http.Response response = await client.get(
        Uri.parse(applink+"api_model.php?act=getdata_monthsalestotal&branch="
            +getBranch.toString()),
        headers: {"Accept":"application/json"}
    );
    return json.decode(response.body);
  }



  @override
  Widget build(BuildContext context) {
     return WillPopScope(
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: HexColor(main_color),
            automaticallyImplyLeading: false,
            actions: [
              Container(padding: const EdgeInsets.only(top: 19,right: 35),
              height: 53,width: 58,
              child: FutureBuilder(
                future: getDataTotalNotif(),
                builder: (context, snapshot) {
                     return ListView.builder(
                      itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                      itemBuilder: (context, i)
                      {
                        return snapshot.data[i]["a"].toString() == "0" ?
                        InkWell(onTap: () {},
                            child: FaIcon(
                              FontAwesomeIcons.solidBell, size: 20,color: Colors.white,))
                            :
                        InkWell(
                            onTap: () {},
                            child: Badge(
                              badgeContent: Text(snapshot.data[i]["a"].toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),),
                              child: FaIcon(
                                FontAwesomeIcons.solidBell, size: 20,color: Colors.white),
                            )
                        );
                      });
                },
              ),),
              Padding(padding: const EdgeInsets.only(top: 19,right: 25), child :
              InkWell(
                hoverColor: Colors.transparent,
                child : FaIcon(FontAwesomeIcons.cog, size: 20,),
                onTap: () {
                  //Navigator.push(context, ExitPage(page: SettingHome()));
                },
               )
              ),

            ],
            title:
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child:   Text("Moobi", style: TextStyle(color: Colors.white,
                    fontFamily: 'VarelaRound', fontSize: 24,
                    fontWeight: FontWeight.bold),)
            ),
            elevation: 0,
            centerTitle: false,
          ),
          body: Stack(
            children: [
              Container(width: double.infinity,height: 120,color:  HexColor("#602d98"),
              child: Stack(
                children: [
                    Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 28,top: 15),
                            child:  Align(
                              alignment: Alignment.bottomLeft,
                              child:  Text(getStorename.toString(), style: TextStyle(color: Colors.white,
                                  fontFamily: 'VarelaRound', fontSize: 12,
                                  fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 28,top: 5),
                            child:  Align(
                              alignment: Alignment.bottomLeft,
                              child:  Container(
                                  padding: const EdgeInsets.only(top: 2),
                                  height: 33,
                                  width: double.infinity,
                                  child: FutureBuilder(
                                    future: getDataTotal(),
                                    builder: (context, snapshot) {
                                      return ListView.builder(
                                        itemCount: (snapshot.data == null ? 0 : snapshot.data.length),
                                        itemBuilder: (context, i) {
                                          return
                                            snapshot.data[i]['a'] == null ?
                                            Text("Rp. 0",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'VarelaRound',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),)
                                                :
                                            Text( "Rp. "+
                                                NumberFormat.currency(
                                                    locale: 'id', decimalDigits: 0, symbol: '').format(
                                                    int.parse(
                                                        snapshot.data[i]['a'] == null ? "0" :
                                                        snapshot.data[i]['a'].toString())),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'VarelaRound',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                            );
                                        },
                                      );
                                    },
                                  )
                              ),
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 28,top: 5),
                            child:  Align(
                                alignment: Alignment.bottomLeft,
                                child:  Opacity(
                                  opacity: 0.7,
                                  child: Text(AppHelper().getBulan+" "+AppHelper().getTahun, style: TextStyle(color: Colors.white,
                                      fontFamily: 'VarelaRound', fontSize: 11,
                                      fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                                )
                            )
                        ),
                      ],
                    )
                ],
              )),
              Padding(
                padding: const EdgeInsets.only(top: 95,left: 25,right: 25),
                child:
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    height: 77,
                    width: double.infinity,
                    child:
                    Padding(
                      padding: const EdgeInsets.only(top: 15,left: 15,right: 25),
                      child:
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 60,
                        children: [
                          InkWell(
                            onTap: () {
                              //Navigator.push(context, ExitPage(page: Profile()));
                            },
                            child:
                            Column(
                              children: [
                                FaIcon(FontAwesomeIcons.user,color: HexColor(second_color)),
                                Padding(padding: const EdgeInsets.only(top:8),
                                  child: Text("Profile", style: TextStyle(fontFamily: 'VarelaRound',
                                      fontSize: 12,color: HexColor(second_color))),)
                              ],
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                //Navigator.push(context, ExitPage(page: Toko()));
                              },
                              child:
                              Column(
                                children: [
                                  FaIcon(FontAwesomeIcons.store,color: HexColor(second_color)),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Outlet Saya", style: TextStyle(fontFamily: 'VarelaRound',
                                        fontSize: 12,color: HexColor(second_color)
                                    )),)
                                ],
                              )),

                          InkWell(
                              onTap: () {
                                //Navigator.push(context, ExitPage(page: Gudang()));
                              },
                              child:
                              Column(
                                children: [
                                  FaIcon(FontAwesomeIcons.warehouse,color: HexColor(second_color)),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Gudang", style: TextStyle(fontFamily: 'VarelaRound',
                                        fontSize: 12,color: HexColor(second_color))),)
                                ],
                              )),
                        ],
                      ),
                    ),
                ),),


              Padding(
                  padding: const EdgeInsets.only(top: 200,left: 25,right: 25),
                  child: Column(
                    children: [
                    /*  getMoobiIdentity == 'Classic' ?
                      Container(
                          padding: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: HexColor("#e8fcfb"),
                          ),
                          width: double.infinity,
                          height: 70,
                          child: ListTile(
                            title:
                            Text("Subscribe ke MOOBIE Premier", style: TextStyle(
                                fontFamily: 'VarelaRound',fontWeight: FontWeight.bold,
                                fontSize: 14,color: HexColor("#025f64"))),
                            subtitle:
                            Text("Nikmati fitur lengkapnya", style: TextStyle(fontFamily: 'VarelaRound'
                                ,fontSize: 12,color: HexColor("#025f64"))),
                            trailing: FaIcon(FontAwesomeIcons.angleRight,color: HexColor("#025f64")),
                          )
                      )
                          :
                      Container(),
                      getMoobiIdentity == 'Classic' ?
                      SizedBox(
                        height: 25,
                      )
                          : Container(),*/
                      Wrap(
                        spacing: 30,
                        runSpacing: 30,
                        children: [
                          InkWell(
                            onTap: (){
                                Navigator.push(context, ExitPage(page: Jualan(
                                    getBranch.toString(),
                                    getEmail.toString(),
                                    getNamaUser.toString()
                                )));
                              },
                            child:Column(
                              children: [
                                Container(
                                    height: 55, width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: HexColor("#f7faff"),
                                    ),
                                    child: Center(
                                      child: FaIcon(FontAwesomeIcons.shoppingBasket, color: HexColor("#1c6bea"), size: 24,),
                                    )
                                ),
                                Padding(padding: const EdgeInsets.only(top:8),
                                  child: Text("Jualan", style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                              ],
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              //Navigator.push(context, ExitPage(page: ProdukHome()));
                            },
                            child:Column(
                              children: [
                                Container(
                                    height: 55, width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: HexColor("#fff4f0"),
                                    ),
                                    child: Center(
                                      child: FaIcon(FontAwesomeIcons.cubes, color: HexColor("#ff8556"), size: 24,),
                                    )
                                ),
                                Padding(padding: const EdgeInsets.only(top:8),
                                  child: Text("Produk", style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                              ],
                            ),
                          ),

                          InkWell(
                            onTap: (){
                              //Navigator.pushReplacement(context, ExitPage(page: LaporanHome()));
                              },
                            child:Column(
                              children: [
                                Container(
                                    height: 55, width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: HexColor("#f3fcf9"),
                                    ),
                                    child: Center(
                                      child: FaIcon(FontAwesomeIcons.clipboard, color: HexColor("#00c160"), size: 24,),
                                    )
                                ),
                                Padding(padding: const EdgeInsets.only(top:8),
                                  child: Text("Laporan", style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                              ],
                            ),
                          ),

                          InkWell(
                            child:Column(
                              children: [
                                Container(
                                    height: 55, width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: HexColor("#f3effd"),
                                    ),
                                    child: Center(
                                      child: FaIcon(FontAwesomeIcons.moneyCheck, color: HexColor("#6238b6"),
                                        size: 24,),
                                    )
                                ),
                                Padding(padding: const EdgeInsets.only(top:8),
                                  child: Text("Kas Saya",
                                      style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                              ],
                            ),
                          ),

                          //PREIMUM CONTENT=====================================================
                          Opacity(
                              opacity: 0.6,
                              child : Column(
                                children: [
                                  Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: HexColor("#DDDDDD"),
                                      ),
                                      child: Center(
                                        child: FaIcon(FontAwesomeIcons.users, color: Colors.black,
                                          size: 24,),
                                      )
                                  ),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Customer",
                                        style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                                ],
                              )),

                          Opacity(
                              opacity: 0.6,
                              child : Column(
                                children: [
                                  Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: HexColor("#DDDDDD"),
                                      ),
                                      child: Center(
                                        child: FaIcon(FontAwesomeIcons.percent, color: Colors.black,
                                          size: 24,),
                                      )
                                  ),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Diskon",
                                        style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                                ],
                              )),

                          Opacity(
                              opacity: 0.6,
                              child : Column(
                                children: [
                                  Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: HexColor("#DDDDDD"),
                                      ),
                                      child: Center(
                                        child: FaIcon(FontAwesomeIcons.receipt, color: Colors.black,
                                          size: 24,),
                                      )
                                  ),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Voucher",
                                        style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                                ],
                              )),

                          Opacity(
                              opacity: 0.6,
                              child : Column(
                                children: [
                                  Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: HexColor("#DDDDDD"),
                                      ),
                                      child: Center(
                                        child: FaIcon(FontAwesomeIcons.truckLoading, color: Colors.black,
                                          size: 24,),
                                      )
                                  ),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Pembelian",
                                        style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                                ],
                              )),

                          Opacity(
                              opacity: 0.6,
                              child : Column(
                                children: [
                                  Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: HexColor("#DDDDDD"),
                                      ),
                                      child: Center(
                                        child: FaIcon(FontAwesomeIcons.fileInvoice, color: Colors.black,
                                          size: 24,),
                                      )
                                  ),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Invoiced",
                                        style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                                ],
                              )),

                          Opacity(
                              opacity: 0.6,
                              child : Column(
                                children: [
                                  Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: HexColor("#DDDDDD"),
                                      ),
                                      child: Center(
                                        child: FaIcon(FontAwesomeIcons.user, color: Colors.black,
                                          size: 24,),
                                      )
                                  ),
                                  Padding(padding: const EdgeInsets.only(top:8),
                                    child: Text("Vendor",
                                        style: TextStyle(fontFamily: 'VarelaRound',fontSize: 13)),)
                                ],
                              )),

                        ],
                      )
                    ],
                  )

              )

            ],
          )

        ),
     );
  }
}