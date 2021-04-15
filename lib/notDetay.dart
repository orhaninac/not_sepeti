import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DataBaseHelper dataBaseHelper;
  int kategoriID = 1;
  int secilenOncelik = 0;
  String notBaslik, notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    dataBaseHelper = DataBaseHelper();
    dataBaseHelper.kategorileriGetir().then((kategoriIcerenMapListesi) {
      for (Map okunanMap in kategoriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.baslik),
        ),
        body: tumKategoriler.length <= 0
            ? CircularProgressIndicator()
            : Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Kategori: ",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: kategoriItemleriOlustur(),
                                value: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.kategoriID : 1,
                                onChanged: (secilenKategoriID) {
                                  setState(() {
                                    kategoriID = secilenKategoriID;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          // ignore: missing_return
                          initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notBaslik : "",
                          // ignore: missing_return
                          validator: (text) {
                            if (text.length < 3) {
                              return "en az 3 karakter giriniz..";
                            }
                          },
                          onSaved: (text) {
                            notBaslik = text;
                          },
                          decoration: InputDecoration(
                              hintText: "Not Başlığını Giriniz", labelText: "Başlık", border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notIcerik : "",
                          maxLines: 4,
                          decoration: InputDecoration(
                              hintText: "Not içeriğini Giriniz", labelText: "İçerik", border: OutlineInputBorder()),
                          onSaved: (text) {
                            notIcerik = text;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Öncelik:   ",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: _oncelik.map((oncelik) {
                                  return DropdownMenuItem<int>(
                                    child: Text(oncelik, style: TextStyle(fontSize: 24)),
                                    value: _oncelik.indexOf(oncelik),
                                  );
                                }).toList(),
                                value:
                                    widget.duzenlenecekNot != null ? widget.duzenlenecekNot.notOncelik : secilenOncelik,
                                onChanged: (secilenOncelikID) {
                                  setState(() {
                                    secilenOncelik = secilenOncelikID;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      ButtonBar(
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Vazgeç"),
                            color: Colors.redAccent,
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                formKey.currentState.save();
                                var suan = DateTime.now();
                                if (widget.duzenlenecekNot == null) {
                                  dataBaseHelper
                                      .notEkle(Not(kategoriID, notBaslik, notIcerik, suan.toString(), secilenOncelik))
                                      .then((kaydedilenNotID) {
                                    if (kaydedilenNotID != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                } else {
                                  dataBaseHelper
                                      .notlariGuncelle(Not.withID(widget.duzenlenecekNot.notID, kategoriID, notBaslik,
                                          notIcerik, suan.toString(), secilenOncelik))
                                      .then((kaydedilenNotID) {
                                    if (kaydedilenNotID != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              }
                            },
                            child: Text("Kaydet"),
                            color: Colors.green,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
  }

  kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
            value: kategori.kategoriID,
            child: Text(
              kategori.kategoriBaslik,
              style: TextStyle(fontSize: 24),
            )))
        .toList();
  }
}
