import 'package:audioplayers/audioplayers.dart';
import 'package:avara_homepage/assets/assets.dart';
import 'package:avara_homepage/products.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Focus(
              child: Image.asset(
                ImageAssets.avaraLogo,
                width: 120,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned.fill(
            child: Products(player: _player),
          ),
        ],
      ),
    );
  }
}
