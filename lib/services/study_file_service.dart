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
  final int? pageCount;

  const StudyFileResult({
    required this.fileName,
    required this.mimeType,
    required this.text,
    required this.imageBytes,
    this.pageCount,
  });

  bool get hasReadableText => text.trim().isNotEmpty;
  bool get isImage => imageBytes != null;
}

class StudyFileService {
  static const int maxPdfPages = 2;
  static const int _maxExtractedTextChars = 12000;

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
        pageCount: null,
      );
    }

    String extractedText = "";
    int? pageCount;
    if (extension == "pdf" || mimeType == "application/pdf") {
      final pdfText = _extractTextFromPdf(bytes);
      pageCount = pdfText.pageCount;
      extractedText = pdfText.text;
    } else {
      extractedText = _extractReadableText(bytes);
    }

    return StudyFileResult(
      fileName: file.name,
      mimeType: mimeType,
      text: extractedText,
      imageBytes: null,
      pageCount: pageCount,
    );
  }

  _PdfTextResult _extractTextFromPdf(Uint8List bytes) {
    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final pageCount = document.pages.count;
      if (pageCount > maxPdfPages) {
        throw StudyFileException(
          "PDF upload limit is $maxPdfPages pages. Please choose a shorter PDF.",
        );
      }

      final text = PdfTextExtractor(document).extractText();
      return _PdfTextResult(
        text: _limitText(text),
        pageCount: pageCount,
      );
    } on StudyFileException {
      rethrow;
    } catch (e) {
      return const _PdfTextResult(text: "", pageCount: null);
    } finally {
      document?.dispose();
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

    return _limitText(text);
  }

  String _limitText(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= _maxExtractedTextChars) {
      return trimmed;
    }

    return "${trimmed.substring(0, _maxExtractedTextChars).trim()}\n\n[Only the first $_maxExtractedTextChars characters were added to keep AI requests within the app limit.]";
  }
}

class _PdfTextResult {
  final String text;
  final int? pageCount;

  const _PdfTextResult({
    required this.text,
    required this.pageCount,
  });
}

class StudyFileException implements Exception {
  final String message;

  const StudyFileException(this.message);

  @override
  String toString() => message;
}
