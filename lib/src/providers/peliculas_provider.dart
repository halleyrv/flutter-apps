
import 'dart:async';
import 'package:peliculas/src/models/pelicula.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PeliculasProvider {
  String _apiKey    = '6366296bfcd6ca019da1d1988199ab10';
  String _url       = 'api.themoviedb.org';
  String _language  = 'es-ES';
  int _popularesPage = 0;

  List<Pelicula> _populares = new List();
  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  void disposeSteams(){
    _popularesStreamController.close();
  }

  // Getters para obtener stream and sink apunta al stream controller
  Function (List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;
  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;


  Future<List<Pelicula>> _procesarRespuesta(Uri url) async{
     final resp = await http.get(url);
     final decodedData = json.decode(resp.body);
     final peliculas = new Peliculas.fromJsonList(decodedData['results']);
     return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing',{
      'api_key'  : _apiKey,
      'language': _language
    });

    return this._procesarRespuesta(url);

  }

  Future<List<Pelicula>> getPopulares() async {

    _popularesPage++;

    final url = Uri.https(_url,'3/movie/popular', {
      'api_key'  : _apiKey,
      'language' : _language,
      'page'     : _popularesPage.toString()
    });
    final resp = await _procesarRespuesta(url);
    _populares.addAll(resp);
    popularesSink(_populares);
    return resp;
  }
  
}