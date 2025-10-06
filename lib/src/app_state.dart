import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart' as http;

class FlutterDevPlaylists extends ChangeNotifier {
  FlutterDevPlaylists({
    required String flutterDevAccountId,
    required String youTubeApiKey,
  }) : _flutterDevAccountId = flutterDevAccountId {
    _api = YouTubeApi(_ApiKeyClient(client: http.Client(), key: youTubeApiKey));
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    // Se agrega un bloque try-catch para "atrapar" cualquier error de la API
    try {
      String? nextPageToken;
      _playlists.clear();

      do {
        final response = await _api.playlists.list(
          ['snippet', 'contentDetails', 'id'],
          channelId: _flutterDevAccountId,
          maxResults: 50,
          pageToken: nextPageToken,
        );

        if (response.items != null) {
          _playlists.addAll(response.items!);
        }

        _playlists.sort(
          (a, b) => a.snippet!.title!.toLowerCase().compareTo(
            b.snippet!.title!.toLowerCase(),
          ),
        );

        // ¡CORRECCIÓN DE BUG! Se actualiza el token para la siguiente página.
        // Sin esto, el código original entraba en un bucle infinito.
        nextPageToken = response.nextPageToken;

        notifyListeners();
      } while (nextPageToken != null);
    } catch (e) {
      // Si ocurre un error, se imprimirá un mensaje claro en la consola de depuración
      print('<<<<<<<<<< ERROR AL CARGAR PLAYLISTS >>>>>>>>>>');
      print('Esto usualmente se debe a una Clave de API mal configurada.');
      print(e);
      print('<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>');
    }
  }

  final String _flutterDevAccountId;
  late final YouTubeApi _api;

  final List<Playlist> _playlists = [];
  List<Playlist> get playlists => UnmodifiableListView(_playlists);

  final Map<String, List<PlaylistItem>> _playlistItems = {};
  List<PlaylistItem> playlistItems({required String playlistId}) {
    if (!_playlistItems.containsKey(playlistId)) {
      _playlistItems[playlistId] = [];
      _retrievePlaylist(playlistId);
    }
    return UnmodifiableListView(_playlistItems[playlistId]!);
  }

  Future<void> _retrievePlaylist(String playlistId) async {
    try {
      String? nextPageToken;
      do {
        var response = await _api.playlistItems.list(
          ['snippet', 'contentDetails'],
          playlistId: playlistId,
          maxResults: 25,
          pageToken: nextPageToken,
        );
        var items = response.items;
        if (items != null) {
          _playlistItems[playlistId]!.addAll(items);
        }
        notifyListeners();
        nextPageToken = response.nextPageToken;
      } while (nextPageToken != null);
    } catch (e) {
      print('<<<<<<<<<< ERROR AL OBTENER VIDEOS DE LA PLAYLIST >>>>>>>>>>');
      print('Playlist ID: $playlistId');
      print(e);
      print('<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>');
    }
  }
}

class _ApiKeyClient extends http.BaseClient {
  _ApiKeyClient({required this.key, required this.client});

  final String key;
  final http.Client client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final url = request.url.replace(
      queryParameters: <String, List<String>>{
        ...request.url.queryParametersAll,
        'key': [key],
      },
    );

    // Esta implementación del tutorial es muy simple, solo copia el método y la URL.
    // Para una app real, se deberían copiar también los headers y el body.
    return client.send(http.Request(request.method, url));
  }
}
