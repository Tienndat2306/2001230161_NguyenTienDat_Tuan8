import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHome extends StatefulWidget {
  const AudioPlayerHome({super.key});

  @override
  _AudioPlayerHomeState createState() => _AudioPlayerHomeState();
}

class _AudioPlayerHomeState extends State<AudioPlayerHome> {
  // Bây giờ Flutter đã hiểu AudioPlayer nhờ dòng import trên
  late AudioPlayer _audioPlayer;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  final List<String> _songs = [
    'audios/sample1.mp3',
    'audios/sample2.mp3',
    'audios/sample3.mp3',
  ];

  final List<String> _songTitles = [
    'Vocabulary Lesson 1',
    'Grammar Part 2',
    'Pronunciation 3'
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    try {
      await _audioPlayer.play(AssetSource(_songs[_currentSongIndex]));
    } catch (e) {
      debugPrint("Lỗi phát audio: $e");
    }
  }

  Future<void> _pauseSong() async => await _audioPlayer.pause();
  Future<void> _stopSong() async => await _audioPlayer.stop();

  void _nextSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % _songs.length;
    });
    _playSong();
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + _songs.length) % _songs.length;
    });
    _playSong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        title: const Text('Amingo Audio Player', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade100,
                border: Border.all(color: const Color(0xFFFDBC13), width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 10))
                ],
              ),
              child: Icon(Icons.music_note_rounded, size: 100, color: Colors.orange.shade800),
            ),
            const SizedBox(height: 40),
            Text(
              _songTitles[_currentSongIndex],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
            ),
            const Text('Amingo Learning App', style: TextStyle(color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 50),
                  onPressed: _previousSong,
                  color: const Color(0xFF775600),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _isPlaying ? _pauseSong() : _playSong(),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFFDBC13),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 50),
                  onPressed: _nextSong,
                  color: const Color(0xFF775600),
                ),
              ],
            ),
            const SizedBox(height: 30),
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined, size: 30, color: Colors.grey),
              onPressed: _stopSong,
            ),
          ],
        ),
      ),
    );
  }
}