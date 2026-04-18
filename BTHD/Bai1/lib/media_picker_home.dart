import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class MediaPickerHome extends StatefulWidget {
  const MediaPickerHome({super.key});

  @override
  State<MediaPickerHome> createState() => _MediaPickerHomeState();
}

class _MediaPickerHomeState extends State<MediaPickerHome> {
  File? _mediaFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Yêu cầu quyền thông minh hơn
  Future<bool> _handlePermissions(bool isVideo, ImageSource source) async {
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (isVideo) await Permission.microphone.request();
      return cameraStatus.isGranted;
    } else {
      if (Platform.isAndroid) {
        if (isVideo) {
          final status = await Permission.videos.request();
          return status.isGranted;
        } else {
          final status = await Permission.photos.request();
          return status.isGranted;
        }































































































































      }
      return await Permission.photos.request().isGranted;
    }
  }

  Future<void> _handleMediaAction(ImageSource source, bool isVideo) async {
    final hasPermission = await _handlePermissions(isVideo, source);
    if (!hasPermission) {
      _showSnackBar('Cần cấp quyền để thực hiện chức năng này');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        await _processSelectedMedia(File(pickedFile.path), isVideo);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn tệp: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processSelectedMedia(File file, bool isVideo) async {
    // Giải phóng controller cũ
    await _videoController?.dispose();
    _videoController = null;

    setState(() {
      _mediaFile = file;
    });

    if (isVideo || file.path.toLowerCase().endsWith('.mp4')) {
      _videoController = VideoPlayerController.file(file);
      try {
        await _videoController!.initialize();
        setState(() {}); // Để cập nhật tỷ lệ khung hình
        _videoController!.setLooping(true);
        _videoController!.play();
      } catch (e) {
        _showSnackBar('Không thể phát video này');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3), // Màu nền của Amingo
      appBar: AppBar(
        title: Text('Media Picker', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF3A2D00),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Khu vực hiển thị Media
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDBC13), width: 2),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _mediaFile == null
                  ? const Center(child: Text('Chưa có dữ liệu'))
                  : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
                    : Image.file(_mediaFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            // Các nút chức năng
            _buildActionButton(
              icon: Icons.photo_library,
              label: 'Chọn ảnh từ Gallery',
              onTap: () => _handleMediaAction(ImageSource.gallery, false),
            ),
            _buildActionButton(
              icon: Icons.camera_alt,
              label: 'Chụp ảnh từ Camera',
              onTap: () => _handleMediaAction(ImageSource.camera, false),
            ),
            _buildActionButton(
              icon: Icons.video_collection,
              label: 'Chọn video từ Gallery',
              onTap: () => _handleMediaAction(ImageSource.gallery, true),
            ),
            _buildActionButton(
              icon: Icons.videocam,
              label: 'Quay video từ Camera',
              onTap: () => _handleMediaAction(ImageSource.camera, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF775600),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }
}