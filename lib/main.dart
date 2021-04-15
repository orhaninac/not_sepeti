import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:not_sepeti/utils/database_helper.dart';
import 'models/kategori.dart';
import 'models/notlar.dart';
import 'notDetay.dart';
import 'dart:async';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Not Sepeti",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(child: Text("Not Sepeti")),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /*Container(
            color: Colors.red,
            width: 100,
            height: 100,
            child: FloatingActionButton(
              heroTag: "KategoriEkle",
              onPressed: () {
                kategoriEkleDialog(context);
              },
              child: Text("Kategori Ekle"),
              mini: true,
            ),
          ),*/
          ElevatedButton(
            child: Text('Kategori Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              elevation: 5,
            ),
            onPressed: () {
              kategoriEkleDialog(context);
            },
          ),
          ElevatedButton(
            child: Text(
              'Yeni Not Ekle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              elevation: 5,
            ),
            onPressed: () {
              _detaySayfasinaGit(context);
            },
          ),
          /*FloatingActionButton(
            heroTag: "NotEkle",
            onPressed: () {
              _detaySayfasinaGit(context);
            },
            child: Icon(Icons.add),
          ),*/
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String kaydedilecekDeger;
    DataBaseHelper dataBaseHelper = DataBaseHelper();
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (yeniDeger) {
                      kaydedilecekDeger = yeniDeger;
                    },
                    decoration: InputDecoration(
                      labelText: "Kategori Adı Giriniz",
                      border: OutlineInputBorder(),
                    ),
                    // ignore: missing_return
                    validator: (girilenDegerUzunlugu) {
                      if (girilenDegerUzunlugu.length < 3) {
                        return "en az 3 karakter giriniz..";
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  // ignore: deprecated_member_use
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                    child: Text("Vazgeç"),
                  ),

                  // ignore: deprecated_member_use
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        dataBaseHelper.kategoriEkle(Kategori(kaydedilecekDeger)).then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Kayıt Eklendi."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      }
                      Navigator.pop(context);
                    },
                    color: Colors.green,
                    child: Text("Ekle"),
                  )
                ],
              )
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NotDetay(
        baslik: "Yeni Not",
      );
    })).then((value) => setState(() {}));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  var _dataBaseHelper = DataBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ignore: deprecated_member_use
    tumNotlar = List<Not>();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataBaseHelper.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          tumNotlar = snapShot.data;
         // sleep(Duration(milliseconds:500));
          return ListView.builder(
              itemCount: tumNotlar.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                  title: Text(tumNotlar[index].notBaslik),
                  subtitle: Text(tumNotlar[index].kategoriBaslik),
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  tumNotlar[index].notIcerik,
                                  style: TextStyle(color: Colors.pinkAccent, fontSize: 20),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "Oluşturma Tarihi",
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _dataBaseHelper.dateFormat(DateTime.parse(tumNotlar[index].notTarih)),
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                          ButtonBar(
                            children: [
                              FlatButton(
                                  onPressed: () {
                                    _notSil(tumNotlar[index].notID);
                                  },
                                  child: Text(
                                    "SİL",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              FlatButton(
                                  onPressed: () {
                                    _detaySayfasinaGit(context, tumNotlar[index]);
                                  },
                                  child: Text(
                                    "GÜNCELLE",
                                    style: TextStyle(color: Colors.blue),
                                  )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  _detaySayfasinaGit(BuildContext context,Not not) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
     // Not duzenlenecekNot;
      return NotDetay(
        baslik: "Not Güncelle",
        duzenlenecekNot:not,
      );
    })).then((value) => setState(() {}));
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text("Düşük", style: TextStyle(fontSize: 13)),
          backgroundColor: Colors.greenAccent,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "Orta",
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.lightBlueAccent,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text("Yüksek", style: TextStyle(fontSize: 12)),
          backgroundColor: Colors.red,
        );
        break;
    }
  }

  void _notSil(int notID) {
    _dataBaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Not Silindi.")));
      }
      setState(() {
        
      });
    });
  }
}
