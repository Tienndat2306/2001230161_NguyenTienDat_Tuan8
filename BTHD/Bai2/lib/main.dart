import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const PhotoCaptureApp());
}

class PhotoCaptureApp extends StatelessWidget {
  const PhotoCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Capture & Preview',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const PhotoCaptureHome(),
    );
  }
}

class PhotoCaptureHome extends StatefulWidget {
  const PhotoCaptureHome({super.key});

  @override
  _PhotoCaptureHomeState createState() => _PhotoCaptureHomeState();
}

class _PhotoCaptureHomeState extends State<PhotoCaptureHome> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Hàm xin quyền thông minh
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Nếu bị từ chối vĩnh viễn, nhắc người dùng vào cài đặt
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng vào Cài đặt để cấp quyền cho App')),
        );
      }
      openAppSettings();
    }
    return false;
  }

  // Chọn ảnh từ gallery
  Future<void> _pickImageFromGallery() async {
    bool hasPermission = false;

    // Kiểm tra phiên bản Android để xin đúng quyền
    if (Platform.isAndroid) {
      // Android 13 trở lên dùng Permission.photos
      hasPermission = await _requestPermission(Permission.photos);
      // Nếu máy đời cũ (dưới Android 13), dùng Permission.storage
      if (!hasPermission) {
        hasPermission = await _requestPermission(Permission.storage);
      }
    } else {
      hasPermission = await _requestPermission(Permission.photos);
    }

    if (hasPermission) {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Tối ưu dung lượng ảnh
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  // Chụp ảnh từ camera
  Future<void> _captureImageFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (hasPermission) {
      final XFile? capturedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (capturedFile != null) {
        setState(() {
          _imageFile = File(capturedFile.path);
        });
      }
    }
  }

  // Xem trước ảnh toàn màn hình
  void _showFullScreenPreview(BuildContext context) {
    if (_imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(imageFile: _imageFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Capture & Preview'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? const Text('Chưa có ảnh nào được chọn.', style: TextStyle(fontSize: 16))
                : GestureDetector(
              onTap: () => _showFullScreenPreview(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // Bo góc cho đẹp
                child: Image.file(_imageFile!, height: 300, width: 300, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ Gallery'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _captureImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh từ Camera'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;
  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen cho chuyên nghiệp
      appBar: AppBar(
        title: const Text('Xem trước'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer( // Cho phép zoom ảnh
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}