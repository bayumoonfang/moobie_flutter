



import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:cache_image/cache_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:moobie_flutter/Helper/app_link.dart';
import 'package:moobie_flutter/Helper/color_based.dart';
import 'package:moobie_flutter/Helper/page_route.dart';
import 'package:moobie_flutter/Produk/page_produk.dart';
import 'package:moobie_flutter/page_home.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;


class Jualan extends StatefulWidget {
  final String getBranch;
  final String getEmail;
  final String getNamaUser;
  const Jualan(this.getBranch, this.getEmail, this.getNamaUser);
  @override
  JualanState  createState() => JualanState();
}

class Produk{
  final String namaProduk;
  Produk(this.namaProduk);
}


class JualanState extends State<Jualan> {
  bool _isvisible = true;
  var client = http.Client();
  List data, data2;
  TextEditingController _tambahanNama = TextEditingController();
  TextEditingController _tambahanBiaya = TextEditingController();
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  startSCreen() async {
    var duration = const Duration(seconds: 1);
    return Timer(duration, () {
      setState(() {
        _isvisible = true;
      });
    });
  }

 /* String filter = "";
  String sortby = '0';
  getDataProdukJual() async {
    var response = await client.get(Uri.parse(applink+"api_model.php?act=getdata_produk_jual&id="
        +widget.getBranch+""
        "&filter="+filter
        +"&sort="+sortby));
    var jsonData = jsonDecode(response.body);
    List<Produk> produks = [];
    for(var p in jsonData) {
      Produk produk = Produk(p["a"]);
      produks.add(produk);
    }
    print(produks.length);
    return produks;
  }*/

  String filter = "Semua";
  String filterq = "";
  Future<dynamic> getDataProdukJual() async {
    http.Response response = await client.get(
        Uri.parse(applink+"api_model.php?act=getdata_produk_jual&id="
            +widget.getBranch+""
            "&filter="+filter+"&filterq="+filterq),
        headers: {
          "Accept":"application/json",
          "Content-Type": "application/json"}
    );
    return json.decode(response.body);
  }

  Future<List> getDataOrderPending() async {
    http.Response response = await client.get(
        Uri.parse(applink+"api_model.php?act=getdata_countorderpending"
            "&branch="+widget.getBranch+"&namauser="+widget.getNamaUser),
        headers: {"Accept":"application/json","Content-Type": "application/json"}
    );
    return json.decode(response.body);
  }

  addKeranjangLain() async {
    await client.post(
        Uri.parse(applink+"api_model.php?act=add_keranjanglain"),
        body: {
          "namauser" : widget.getNamaUser,
          "produk_branch" : widget.getBranch,
          "produk_name" : _tambahanNama.text,
          "produk_harga" : _tambahanBiaya.text
        }).timeout(Duration(seconds: 10),
        onTimeout: () {
          showToast("Connection Timeout", gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
          return;
        });
    setState(() {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(context);
      _tambahanNama.text = "";
      _tambahanBiaya.text = "";
      getDataOrderPending();
    });
  }

  addKeranjang(String valProduk) async {
    final response = await client.post(Uri.parse(applink+"api_model.php?act=add_keranjang"), body: {
      "produk_id": valProduk.toString(),
      "namauser" : widget.getNamaUser,
      "produk_branch" : widget.getBranch
    }).timeout(Duration(seconds: 10),
        onTimeout: () {
          showToast("Connection Timeout", gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
          return;
        });
    Map data = jsonDecode(response.body);
    setState(() {
      if (data["message"].toString() == '0') {
        showToast("Stock tidak bisa digunakan", gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG);
        return false;
      } else if (data["message"].toString() == '1') {
        showToast("Mohon maaf stock habis", gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG);
        return false;
      } else if (data["message"].toString() == '2') {
        showToast("Mohon maaf stock tidak mencukupi", gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG);
        return false;
      } else {
        setState(() {
          getDataOrderPending();
        });
      }
    });
  }


  hapus_trans() async {
    await client.post(
        Uri.parse(applink+"api_model.php?act=hapus_trans"),
        body: {
          "namauser" : widget.getNamaUser,
          "produk_branch" : widget.getBranch
        }).timeout(Duration(seconds: 10),
        onTimeout: () {
          showToast("Connection Timeout", gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG);
          return;
        });
    setState(() {
      getDataOrderPending();
    });
  }

  TambahBiayaAdd() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                //title: Text(),
                content: ResponsiveContainer(
                    widthPercent: 100,
                    heightPercent: 26.5,
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.only(top: 8), child:
                        Align(alignment: Alignment.center,
                            child: Text("Tambah Biaya Lainnya",
                                style: TextStyle(fontFamily: 'ProximaNova',
                                    fontSize: 16, fontWeight: FontWeight.bold))
                        ),),
                        Padding(padding: const EdgeInsets.only(top: 15), child:
                        Align(alignment: Alignment.center, child:
                        TextFormField(
                          controller: _tambahanNama,
                          style: TextStyle(fontFamily: "ProximaNova",
                              fontSize: 15,fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: new InputDecoration(
                            contentPadding: const EdgeInsets.only(top: 1,left: 10,
                                bottom: 1),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: HexColor("#DDDDDD"),
                                  width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: HexColor("#DDDDDD"),
                                  width: 1.0),
                            ),
                            hintText: 'Nama Biaya. Contoh : Ongkir, dll',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintStyle: TextStyle(fontFamily: "ProximaNova",
                                color: HexColor("#c4c4c4"),fontSize: 15),
                          ),
                        ),
                        )),
                        Padding(padding: const EdgeInsets.only(top: 5), child:
                        Align(alignment: Alignment.center, child:
                        TextFormField(
                          controller: _tambahanBiaya,
                          style: TextStyle(fontFamily: "ProximaNova",fontSize: 15,
                              fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: new InputDecoration(
                            contentPadding: const EdgeInsets.only(top: 1,left: 10,
                                bottom: 1),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: HexColor("#DDDDDD"),
                                  width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: HexColor("#DDDDDD"),
                                  width: 1.0),
                            ),
                            hintText: 'Biaya. Contoh : 12000, 15000',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintStyle: TextStyle(fontFamily: "ProximaNova",
                                color: HexColor("#c4c4c4"), fontSize: 15),
                          ),
                        ),
                        )),
                        Padding(padding: const EdgeInsets.only(top: 20), child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(child: OutlineButton(
                              onPressed: () {
                                Navigator.pop(context);
                              }, child: Text("Keluar",style: TextStyle(
                                fontFamily: "ProximaNova",fontWeight:
                            FontWeight.bold),),)),
                            Expanded(child: OutlineButton(
                              borderSide: BorderSide(width: 1.0,
                                  color: Colors.redAccent),
                              onPressed: () {
                                addKeranjangLain();
                              }, child: Text("Tambah", style: TextStyle(color:
                            Colors.red,fontFamily: "ProximaNova",
                                fontWeight: FontWeight.bold),),)),
                          ],),)
                      ],
                    )
                ),
              );
            },
          );
        });
  }


  void _filterMe() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content:
              Container(
                  height: 125,
                  child: Scrollbar(
                      isAlwaysShown: true,
                      child :
                      SingleChildScrollView(
                        child :
                        Column(
                          children: [

                            InkWell(
                              onTap: (){
                                setState(() {
                                  filter = 'Semua';
                                  Navigator.pop(context);
                                });
                              },
                              child: Align(alignment: Alignment.centerLeft,
                                child:    Text(
                                  "Semua",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontSize: 15),
                                ),),
                            ),
                            Padding(padding: const EdgeInsets.only(top:15,bottom: 15,left: 4,right: 4),
                              child: Divider(height: 5,),),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  filter = 'Termurah';
                                  Navigator.pop(context);
                                });
                              },
                              child: Align(alignment: Alignment.centerLeft,
                                child:    Text(
                                  "Harga Terendah",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontSize: 15),
                                ),),
                            ),
                            Padding(padding: const EdgeInsets.only(top:15,bottom: 15,left: 4,right: 4),
                              child: Divider(height: 5,),),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  filter = 'Termahal';
                                  Navigator.pop(context);
                                });
                              },
                              child: Align(alignment: Alignment.centerLeft,
                                child:    Text(
                                  "Harga Tertinggi",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontSize: 15),
                                ),),
                            ),
                            Padding(padding: const EdgeInsets.only(top:15,bottom: 15,left: 4,right: 4),
                              child: Divider(height: 5,),),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  filter = 'Diskon';
                                  Navigator.pop(context);
                                });
                              },
                              child: Align(alignment: Alignment.centerLeft,
                                child:    Text(
                                  "Produk Diskon",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontSize: 15),
                                ),),
                            )
                          ],
                        ),
                      )))
          );
        });
  }


  alertHapusTrans() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Container(
                width: double.infinity,
                height: 178,
                child: Column(
                  children: [
                    Align(alignment: Alignment.center, child:
                    Text("Konfirmasi", style: TextStyle(fontFamily: 'VarelaRound', fontSize: 20,
                        fontWeight: FontWeight.bold)),),
                    Padding(padding: const EdgeInsets.only(top: 15), child:
                    Align(alignment: Alignment.center, child: FaIcon(FontAwesomeIcons.trashAlt,
                      color: Colors.redAccent,size: 35,)),),
                    Padding(padding: const EdgeInsets.only(top: 15), child:
                    Align(alignment: Alignment.center, child:
                    Text("Apakah anda yakin mengkosongkan keranjang ? ",
                        style: TextStyle(fontFamily: 'VarelaRound', fontSize: 12)),)),
                    Padding(padding: const EdgeInsets.only(top: 25), child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(child: OutlineButton(
                          onPressed: () {Navigator.pop(context);}, child: Text("Tidak"),)),
                        Expanded(child: OutlineButton(
                          borderSide: BorderSide(width: 1.0, color: Colors.redAccent),
                          onPressed: () {
                            hapus_trans();
                            Navigator.pop(context);
                          }, child: Text("Kosongkan", style: TextStyle(color: Colors.red),),)),
                      ],),)
                  ],
                )
            ),
          );
        });
  }




  @override
  Widget build(BuildContext context) {
      return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.5,
            backgroundColor: Colors.white,
            leadingWidth: 38, // <-- Use this
            centerTitle: false,
            title: Text(
              "Transaksi Baru",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Nunito',
                  fontSize: 18,fontWeight: FontWeight.bold),
            ),
            leading: Container(
              padding: const EdgeInsets.only(left: 7),
              child: Builder(
                builder: (context) => IconButton(
                    icon: new Icon(Icons.arrow_back),
                    color: Colors.black,
                    onPressed: () => {
                      Navigator.pop(context)
                    }),
              ),
            ),
            actions: [
              InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  TambahBiayaAdd();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25,top : 16),
                  child: FaIcon(
                    FontAwesomeIcons.plus,
                    color: HexColor("#6b727c"),
                    size: 18,
                  ),
                ),
              ),
              InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  _filterMe();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25,top : 16),
                  child: FaIcon(
                    FontAwesomeIcons.sortAmountDown,
                    color: HexColor("#6b727c"),
                    size: 18,
                  ),
                ),
              ),
              InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  alertHapusTrans();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 27,top : 16),
                  child: FaIcon(
                    FontAwesomeIcons.trashAlt,
                    color: HexColor("#6b727c"),
                    size: 18,
                  ),
                ),
              )
            ],
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(padding: const EdgeInsets.only(left: 15,top: 10,
                right: 15),
                  child: Container(
                    height: 45,
                    child: TextFormField(
                      enableInteractiveSelection: false,
                      onChanged: (text) {
                        setState(() {
                          filterq = text;
                        });
                      },
                      style: TextStyle(fontFamily: "ProximaNova",fontSize: 15),
                      decoration: new InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        fillColor: HexColor("#f4f4f4"),
                        filled: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(Icons.search,size: 18,
                            color: HexColor("#6c767f"),),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,
                            width: 1.0,),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: HexColor("#f4f4f4"),
                              width: 1.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: 'Cari Produk...',
                      ),
                    ),
                  )),
                Padding(padding: const EdgeInsets.only(top: 10),),
                Visibility(
                    visible: _isvisible,
                    child :
                    Expanded(child: _dataField())
                ),
                Padding(padding: const EdgeInsets.only(bottom: 10),),
              ],
            ),
          ),
            floatingActionButton:
            Container(
              height: 65,
              width: 65,
              child: FutureBuilder(
                  future: getDataOrderPending(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                        itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                        itemBuilder: (context, i) {
                          return  FittedBox(
                              child: Badge(
                                badgeContent: Text(
                                  snapshot.data[i]["a"].toString() == "null" ? "0" :
                                  snapshot.data[i]["a"].toString()
                                  ,style: TextStyle(color: Colors.white,fontSize: 14),),
                                position: BadgePosition(end: 0,top: 0),
                                child: FloatingActionButton(
                                  backgroundColor: HexColor(main_color),
                                  onPressed: () {
                                    snapshot.data[i]["a"].toString() == "null" ?
                                    FocusScope.of(context).requestFocus(FocusNode())
                                        :
                                    Navigator.push(context, ExitPage(page: Home()));
                                  },
                                  child: FaIcon(FontAwesomeIcons.shoppingBasket),
                                ),
                              )
                          );
                        });
                  }
              ),

            )
        ),
      );
  }


  Widget _dataField() {
     return FutureBuilder(
       future: getDataProdukJual(),
       builder: (context, snapshot) {
         if (snapshot.data == null) {
           return Container(
             child: Center(
               child: Text("Loading..."),
             ),
           );
         } else {
           return ListView.builder(
             itemCount: snapshot.data == null ? 0 : snapshot.data.length,
             padding: const EdgeInsets.only(top: 10,bottom: 80),
             itemBuilder: (context, i) {
                return Column(
                  children: [
                    InkWell(
                      onTap: (){
                        addKeranjang(snapshot.data["g"].toString());
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: ListTile(
                        leading:
                        snapshot.data[i]["e"] != 0 ?
                          Badge(
                            badgeContent: Text(snapshot.data[i]["e"].toString(),
                                style: TextStyle(color: Colors.white,fontSize: 12)),
                            child: SizedBox(
                                width: 60,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child : CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                    snapshot.data[i]["d"] == '' ?
                                    applink+"photo/nomage.jpg"
                                        :
                                    applink+"photo/"+widget.getBranch+"/"+snapshot.data[i]["d"],
                                    progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                        CircularProgressIndicator(value:
                                        downloadProgress.progress),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                )),
                          )
                              :
                          SizedBox(
                              width: 60,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child : CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl:
                                  snapshot.data[i]["d"] == '' ?
                                  applink+"photo/nomage.jpg"
                                      :
                                  applink+"photo/"+widget.getBranch+"/"+snapshot.data[i]["d"],
                                  progressIndicatorBuilder: (context, url,
                                      downloadProgress) =>
                                      CircularProgressIndicator(value:
                                      downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              )),
                        title: Align(alignment: Alignment.centerLeft,
                          child: Text(snapshot.data[i]["a"],
                              style: TextStyle(fontFamily: "VarelaRound",
                                  fontSize: 13,fontWeight: FontWeight.bold)),),
                        subtitle: Align(alignment: Alignment.centerLeft,
                            child:
                            snapshot.data[i]["e"] != 0 ?
                            ResponsiveContainer(
                              widthPercent: 45,
                              heightPercent: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rp "+
                                      NumberFormat.currency(
                                          locale: 'id', decimalDigits: 0, symbol: '').
                                      format(
                                          snapshot.data[i]["c"]), style: new TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontFamily: 'VarelaRound',fontSize: 12),),
                                  Padding(padding: const EdgeInsets.only(left: 5),child:
                                  Text("Rp "+
                                      NumberFormat.currency(
                                          locale: 'id', decimalDigits: 0, symbol: '').
                                      format(
                                          snapshot.data[i]["c"] - double.parse(snapshot.data[i]["f"])),
                                    style: new TextStyle(
                                        fontFamily: 'VarelaRound',fontSize: 12),),)
                                ],
                              ),
                            )
                                :
                            Text("Rp "+
                                NumberFormat.currency(
                                    locale: 'id', decimalDigits: 0, symbol: '').format(
                                    snapshot.data[i]["c"]), style: new TextStyle(
                                fontFamily: 'VarelaRound',fontSize: 12),)
                        ),
                      ),
                    ),
                   // Padding(padding: const EdgeInsets.only(top :10 ))
                  ],
                );
             },
           );
         }
       },
     );
  }


}