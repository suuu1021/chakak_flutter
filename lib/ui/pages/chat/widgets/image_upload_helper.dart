import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ImageUploadHelper {
  static Future<void> pickAndUploadImage(
    BuildContext context, {
    required Function(String base64Image, String fileName, int fileSize)
        onImageSelected,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85, // 이미지 품질 조절로 파일 크기 최적화
      );

      if (image != null) {
        // 로딩 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('이미지를 업로드하는 중...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        await _processImage(context, image, onImageSelected);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> _processImage(
    BuildContext context,
    XFile image,
    Function(String base64Image, String fileName, int fileSize) onImageSelected,
  ) async {
    try {
      // 이미지 파일을 바이트로 읽기
      final File imageFile = File(image.path);
      final List<int> imageBytes = await imageFile.readAsBytes();

      // Base64로 인코딩
      final String base64Image = base64Encode(imageBytes);

      // 파일 크기 체크 (예: 5MB 제한)
      if (imageBytes.length > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 크기가 너무 큽니다. 5MB 이하의 이미지를 선택해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 콜백 호출
      onImageSelected(base64Image, image.name, imageBytes.length);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지가 전송되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 파일 크기 포맷 함수
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }
}
