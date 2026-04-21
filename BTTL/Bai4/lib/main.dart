import 'package:flutter/material.dart';
// Đừng quên import file mới tạo
import 'audio_player_screen.dart';

void main() {
  runApp(const SimpleAudioPlayer());
}

class SimpleAudioPlayer extends StatelessWidget {
  const SimpleAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Audio Player',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const AudioListScreen(),
    );
  }
}