import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ImageUploadHelper {
  static Future<void> pickAndUploadImage(
    BuildContext context,
    {
    required Function(String base64Image, String fileName, int fileSize)
        onImageSelected,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (!context.mounted) return;
        
        await _processImage(context, image, onImageSelected);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ImageUploadHelper] 이미지 선택 오류: $e');
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 가져오는 데 실패했습니다: $e')),
      );
    }
  }

  static Future<void> _processImage(
    BuildContext context,
    XFile image,
    Function(String base64Image, String fileName, int fileSize) onImageSelected,
  ) async {
    try {
      final List<int> imageBytes = await image.readAsBytes();
      final String pureBase64 = base64Encode(imageBytes);

      final String fileExtension = image.name.split('.').last.toLowerCase();
      final String mimeType = _getMimeType(fileExtension);

      // 명세서에 맞는 최종 Base64 문자열 생성
      final String finalBase64String = "data:$mimeType;base64,$pureBase64";

      onImageSelected(finalBase64String, image.name, imageBytes.length);

    } catch (e) {
      if (kDebugMode) {
        print('[ImageUploadHelper] 이미지 처리 오류: $e');
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 처리 중 오류가 발생했습니다: $e')),
      );
    }
  }

  static String _getMimeType(String extension) {
    switch (extension) {
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'webp': return 'image/webp';
      default: return 'image/jpeg';
    }
  }
}
