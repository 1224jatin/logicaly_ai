import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class StudyFileResult {
  final String fileName;
  final String mimeType;
  final String text;
  final Uint8List? imageBytes;

  const StudyFileResult({
    required this.fileName,
    required this.mimeType,
    required this.text,
    required this.imageBytes,
  });

  bool get hasReadableText => text.trim().isNotEmpty;
  bool get isImage => imageBytes != null;
}

class StudyFileService {
  Future<StudyFileResult?> pickStudyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const StudyFileException("Could not read the selected file");
    }

    final extension = _fileExtension(file.name);
    final mimeType =
        lookupMimeType(file.name, headerBytes: bytes.take(16).toList()) ??
        _mimeTypeForExtension(extension);

    if (_isAudioOrVideoFile(extension: extension, mimeType: mimeType)) {
      throw const StudyFileException("Audio and video files are not supported");
    }

    if (_isImageFile(extension: extension, mimeType: mimeType)) {
      return StudyFileResult(
        fileName: file.name,
        mimeType: mimeType,
        text: "",
        imageBytes: bytes,
      );
    }

    String extractedText = "";
    if (extension == "pdf" || mimeType == "application/pdf") {
      extractedText = _extractTextFromPdf(bytes);
    } else {
      extractedText = _extractReadableText(bytes);
    }

    return StudyFileResult(
      fileName: file.name,
      mimeType: mimeType,
      text: extractedText,
      imageBytes: null,
    );
  }

  String _extractTextFromPdf(Uint8List bytes) {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      return "";
    }
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf(".");
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return "";
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  bool _isAudioOrVideoFile({
    required String extension,
    required String mimeType,
  }) {
    if (mimeType.startsWith("audio/") || mimeType.startsWith("video/")) {
      return true;
    }

    const blockedExtensions = {
      "3g2",
      "3gp",
      "aac",
      "aiff",
      "amr",
      "avi",
      "flac",
      "m4a",
      "m4v",
      "mkv",
      "mov",
      "mp3",
      "mp4",
      "mpeg",
      "mpg",
      "ogg",
      "opus",
      "wav",
      "webm",
      "wma",
      "wmv",
    };
    return blockedExtensions.contains(extension);
  }

  bool _isImageFile({required String extension, required String mimeType}) {
    if (mimeType.startsWith("image/")) {
      return true;
    }

    const imageExtensions = {
      "bmp",
      "gif",
      "heic",
      "heif",
      "jpeg",
      "jpg",
      "png",
      "webp",
    };
    return imageExtensions.contains(extension);
  }

  String _mimeTypeForExtension(String extension) {
    switch (extension) {
      case "bmp":
        return "image/bmp";
      case "gif":
        return "image/gif";
      case "heic":
        return "image/heic";
      case "heif":
        return "image/heif";
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "png":
        return "image/png";
      case "webp":
        return "image/webp";
      default:
        return "application/octet-stream";
    }
  }

  String _extractReadableText(Uint8List bytes) {
    final text = utf8.decode(bytes, allowMalformed: true).trim();
    if (text.isEmpty) {
      return "";
    }

    final printableCharacters = text.runes.where((rune) {
      return rune == 9 || rune == 10 || rune == 13 || rune >= 32;
    }).length;
    final printableRatio = printableCharacters / text.runes.length;
    if (printableRatio < 0.85) {
      return "";
    }

    return text;
  }
}

class StudyFileException implements Exception {
  final String message;

  const StudyFileException(this.message);

  @override
  String toString() => message;
}
