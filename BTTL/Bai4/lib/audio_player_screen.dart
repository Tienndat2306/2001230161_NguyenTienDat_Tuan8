import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHome extends StatefulWidget {
  final int initialIndex;
  const AudioPlayerHome({super.key, required this.initialIndex});

  @override
  _AudioPlayerHomeState createState() => _AudioPlayerHomeState();
}

class _AudioPlayerHomeState extends State<AudioPlayerHome> {
  late AudioPlayer _audioPlayer;
  late int _currentSongIndex;
  bool _isPlaying = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentSongIndex = widget.initialIndex;
    _audioPlayer = AudioPlayer();

    // Đảm bảo phát nhạc ngay khi vào
    _playSong();

    // 1. Lắng nghe trạng thái Playing/Paused
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    // 2. Lắng nghe tổng thời lượng bài nhạc
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    // 3. Lắng nghe vị trí bài nhạc đang phát
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    try {
      // Lấy đường dẫn từ Model Lesson
      await _audioPlayer.play(AssetSource(amingoLessons[_currentSongIndex].audioPath));
    } catch (e) {
      debugPrint("Lỗi phát audio: $e");
    }
  }

  Future<void> _pauseSong() async => await _audioPlayer.pause();
  Future<void> _stopSong() async => await _audioPlayer.stop();

  void _nextSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % amingoLessons.length;
    });
    _playSong();
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + amingoLessons.length) % amingoLessons.length;
    });
    _playSong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(title: const Text('Amingo Player'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.music_note, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 30),
            Text(
              amingoLessons[_currentSongIndex].title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // --- THANH HIỂN THỊ THỜI GIAN (SLIDER) ---
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              activeColor: const Color(0xFFFDBC13),
              inactiveColor: Colors.orange.shade100,
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position); // Tua nhạc đến đoạn được chọn
              },
            ),

            // Hiển thị số phút/giây bên dưới thanh Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)), // Thời gian hiện tại
                  Text(_formatDuration(_duration)), // Tổng thời gian
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous, size: 40), onPressed: _previousSong),
                const SizedBox(width: 20),
                FloatingActionButton(
                  backgroundColor: const Color(0xFFFDBC13),
                  onPressed: () => _isPlaying ? _pauseSong() : _playSong(),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 35),
                ),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.skip_next, size: 40), onPressed: _nextSong),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class AudioListScreen extends StatelessWidget {
  const AudioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        title: const Text('Lessons'),
        backgroundColor: const Color(0xFFFDBC13),
      ),
      body: ListView.builder(
        itemCount: amingoLessons.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.audiotrack, color: Colors.orange),
            title: Text(amingoLessons[index].title),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioPlayerHome(initialIndex: index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class Lesson {
  final String title;
  final String audioPath;

  Lesson({required this.title, required this.audioPath});
}

final List<Lesson> amingoLessons = [
  Lesson(title: 'Lesson 1: Vocabulary', audioPath: 'audios/audio1.mp3'),
  Lesson(title: 'Lesson 2: First Snowfall', audioPath: 'audios/first_snowfall.mp3'),
  Lesson(title: 'Lesson 3: Pronunciation', audioPath: 'audios/sample3.mp3'),
];