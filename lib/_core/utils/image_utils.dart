import 'dart:convert';
import 'dart:io'; // 추가
import 'package:flutter/material.dart';

class ImageUtils {
  static Widget buildSafeImage(
    String imageData, {
    double width = 120,
    double height = 120,
    BoxFit fit = BoxFit.cover,
  }) {
    // 1. URL 체크
    if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
      return Image.network(
        imageData,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(width, height),
      );
    }

    // 2. 로컬 파일 경로 체크 (추가!)
    if (imageData.startsWith('/data/') ||
        imageData.startsWith('/storage/') ||
        imageData.startsWith('/')) {
      return Image.file(
        File(imageData),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('로컬 파일 로드 실패: $error');
          return _buildErrorWidget(width, height);
        },
      );
    }

    // 3. Base64 체크
    if (imageData.startsWith('/9j/') || imageData.length > 100) {
      try {
        final bytes = base64Decode(imageData);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('Base64 이미지 메모리 오류: $error');
            return _buildErrorWidget(width, height);
          },
        );
      } catch (e) {
        print('Base64 디코딩 실패: $e');
        return _buildErrorWidget(width, height);
      }
    }

    // 4. Asset 경로 체크
    if (imageData.startsWith('assets/') || imageData.startsWith('images/')) {
      return Image.asset(
        imageData,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(width, height),
      );
    }

    // 5. 모든 경우에 해당하지 않으면 에러 위젯
    return _buildErrorWidget(width, height);
  }

  static Widget _buildErrorWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.red, size: 30),
      ),
    );
  }
}
