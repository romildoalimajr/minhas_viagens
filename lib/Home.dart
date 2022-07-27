import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';

class Home extends StatefulWidget {

  late String idViagem;
  Mapa({idViagem}) {
    // TODO: implement Mapa
    throw UnimplementedError();
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /*List _listaViagens = ["Cristo Redentor","Grande Muralha da China",
		"Taj Mahal","Machu Picchu",	"Coliseu"	];*/

  final _controller = StreamController<QuerySnapshot>.broadcast();

  FirebaseFirestore _db = FirebaseFirestore.instance;

  _abrirMapa(String idViagem) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Mapa(
                idViagem: idViagem
                )));
  }

  _excluirViagem(String idViagem) {
    _db.collection("viagens").doc(idViagem).delete();
  }

  _adicionarLocal() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Mapa()));
  }

  _adicionarListinerViagens() async {
    final stream = _db.collection("viagens").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adicionarListinerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Viagens"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xff0066cc),
        onPressed: () {
          _adicionarLocal();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.done:
                QuerySnapshot<Object?>? querySnapshot = snapshot.data;
                List<DocumentSnapshot> viagens = querySnapshot!.docs.toList();
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: viagens.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot item = viagens[index];
                            String titulo = item["titulo"];
                            String idViagem = item.id;
                            return GestureDetector(
                              onTap: () {
                                _abrirMapa(idViagem);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(titulo),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _excluirViagem(idViagem);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                );
                break;
            }
          }),
    );
  }
}
