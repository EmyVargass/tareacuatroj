import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'src/app_state.dart';
import 'src/playlist_details.dart';
import 'src/playlists.dart';

// ID del canal de Flutter Dev en YouTube
const flutterDevAccountId = 'UCwXdFgeE9KYzlDdR7TG9cMw';

// IMPORTANTE: Asegúrate de que esta es tu clave de API de YouTube real
const youTubeApiKey =
    'AIzaSyAG-a49qmGBVHJGTKBEuoX5UDuOqKo79OY'; // Reemplaza con tu clave

final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Playlists();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'playlist/:id',
          builder: (context, state) {
            // CORRECCIÓN: 'queryParams' ahora es 'uri.queryParameters'
            final title = state.uri.queryParameters['title']!;

            // CORRECCIÓN: 'params' ahora es 'pathParameters'
            final id = state.pathParameters['id']!;

            return PlaylistDetails(playlistId: id, playlistName: title);
          },
        ),
      ],
    ),
  ],
);

void main() {
  // Verifica si la clave de API ha sido configurada
  if (youTubeApiKey == 'AIzaNotAnApiKey' || youTubeApiKey == '') {
    print(
      'Error: La youTubeApiKey no ha sido configurada. Por favor, reemplaza el valor con tu clave de API de YouTube real en lib/main.dart',
    );
    exit(1);
  }

  runApp(
    ChangeNotifierProvider<FlutterDevPlaylists>(
      create: (context) => FlutterDevPlaylists(
        flutterDevAccountId: flutterDevAccountId,
        youTubeApiKey: youTubeApiKey,
      ),
      child: const PlaylistsApp(),
    ),
  );
}

class PlaylistsApp extends StatelessWidget {
  const PlaylistsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlutterDev Playlists',
      theme: FlexColorScheme.light(
        scheme: FlexScheme.red,
        useMaterial3: true,
      ).toTheme,
      darkTheme: FlexColorScheme.dark(
        scheme: FlexScheme.red,
        useMaterial3: true,
      ).toTheme,
      themeMode: ThemeMode.dark, // O ThemeMode.System si lo prefieres
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
