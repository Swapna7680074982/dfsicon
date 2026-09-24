import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/api_service.dart';
import '../models/summit_document.dart';
import '../utils/custom_logger.dart';

class DocumentsService {
  DocumentsService._();

  /// Dedicated public folder name across iOS and Android
  static const String _folderName = 'DFSICON';

  /// Get the public storage directory on mobile:
  /// - Android: /storage/emulated/0/Download/DFSICON (visible in phone's Files / Downloads app)
  /// - iOS: ApplicationDocumentsDirectory/DFSICON (visible in Files app under 'On My iPhone > DFSICON')
  static Future<Directory?> getDocumentsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // 1. Try public Download folder on Android
        final publicDownload = Directory('/storage/emulated/0/Download/$_folderName');
        if (!await publicDownload.exists()) {
          try {
            await publicDownload.create(recursive: true);
          } catch (_) {}
        }
        if (await publicDownload.exists()) {
          return publicDownload;
        }

        // 2. Try public Documents folder
        final publicDocs = Directory('/storage/emulated/0/Documents/$_folderName');
        if (!await publicDocs.exists()) {
          try {
            await publicDocs.create(recursive: true);
          } catch (_) {}
        }
        if (await publicDocs.exists()) {
          return publicDocs;
        }
      }

      // iOS or fallback: Standard app documents directory (exposed in iOS Files app)
      final baseDir = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${baseDir.path}/$_folderName');
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }
      return documentsDir;
    } catch (e) {
      debugPrint('⚠️ [DocumentsService] getDocumentsDirectory error: $e');
      return null;
    }
  }

  /// Get the full local file path for a given document
  static Future<String> getLocalFilePath(SummitDocument doc) async {
    try {
      final dir = await getDocumentsDirectory();
      if (dir != null) {
        return '${dir.path}/${doc.localFileName}';
      }
    } catch (_) {}
    return doc.localFileName;
  }

  /// Get the local File instance if it exists on the device
  static Future<File?> getLocalFile(SummitDocument doc) async {
    try {
      final primaryDir = await getDocumentsDirectory();
      if (primaryDir != null) {
        final file = File('${primaryDir.path}/${doc.localFileName}');
        if (await file.exists() && (await file.length()) > 0) {
          return file;
        }
      }

      // Check Android main download directory
      if (Platform.isAndroid) {
        final androidDownloadFile = File('/storage/emulated/0/Download/${doc.localFileName}');
        if (await androidDownloadFile.exists() && (await androidDownloadFile.length()) > 0) {
          return androidDownloadFile;
        }
      }

      // Check fallback / app doc directories
      final baseDir = await getApplicationDocumentsDirectory();
      final prevFile = File('${baseDir.path}/DFS_ICON_Documents/${doc.localFileName}');
      if (await prevFile.exists() && (await prevFile.length()) > 0) {
        return prevFile;
      }
      final directFile = File('${baseDir.path}/$_folderName/${doc.localFileName}');
      if (await directFile.exists() && (await directFile.length()) > 0) {
        return directFile;
      }
    } catch (e) {
      debugPrint('⚠️ [DocumentsService] getLocalFile error: $e');
    }
    return null;
  }

  /// Check if the document has already been downloaded to the local path
  static Future<bool> isDocumentDownloaded(SummitDocument doc) async {
    try {
      final file = await getLocalFile(doc);
      return file != null && (await file.exists()) && (await file.length()) > 0;
    } catch (_) {}
    return false;
  }

  /// Fetch all conference documents from API and filter by user role
  static Future<List<SummitDocument>> fetchDocuments({
    required String accessToken,
    required String roleCode,
  }) async {
    try {
      final response = await ApiService.fetchDocuments(accessToken: accessToken);
      debugPrint('📄 [DOCUMENTS API] Status Code: ${response.statusCode}');
      debugPrint('📄 [DOCUMENTS API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] == true) {
          final List rawList = decoded['data'] ?? [];
          final allDocs = rawList
              .map((item) => SummitDocument.fromJson(item as Map<String, dynamic>))
              .toList();

          // Filter by role
          final filtered = allDocs.where((doc) => doc.isVisibleForRole(roleCode)).toList();
          debugPrint('📄 [DOCUMENTS API] Total Docs: ${allDocs.length}, Visible for Role ($roleCode): ${filtered.length}');
          return filtered;
        }
      }
    } catch (e, stack) {
      CustomLogger.logError('fetchDocuments', 'Error fetching documents: $e', stack);
    }
    return [];
  }

  /// Download a document and save to the dedicated mobile directory
  static Future<File?> downloadDocument(
    SummitDocument doc, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      if (doc.documentUrl.isEmpty) return null;

      final dir = await getDocumentsDirectory();
      if (dir == null) return null;
      final filePath = '${dir.path}/${doc.localFileName}';
      final targetFile = File(filePath);

      final uri = Uri.parse(doc.documentUrl);
      final client = http.Client();
      final request = http.Request('GET', uri);
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        final List<int> bytesList = [];

        await for (var chunk in response.stream) {
          bytesList.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0 && onProgress != null) {
            onProgress(receivedBytes / totalBytes);
          }
        }

        await targetFile.writeAsBytes(bytesList);
        CustomLogger.logInfo('Saved ${doc.documentName} to $filePath');

        // On Android, also save a copy directly to /storage/emulated/0/Download/ so the top Downloads category in Google Files shows it instantly
        if (Platform.isAndroid) {
          try {
            final mainDownloadFile = File('/storage/emulated/0/Download/${doc.localFileName}');
            await mainDownloadFile.writeAsBytes(bytesList);
          } catch (_) {}
        }

        return targetFile;
      }
    } catch (e, stack) {
      CustomLogger.logError('downloadDocument', 'Failed to download ${doc.documentName}: $e', stack);
    }
    return null;
  }

  /// Open the downloaded file locally from the DFSICON folder
  static Future<bool> openLocalDocument(BuildContext context, SummitDocument doc) async {
    try {
      final localFile = await getLocalFile(doc);
      if (localFile != null && await localFile.exists()) {
        final result = await OpenFilex.open(localFile.path);
        if (result.type == ResultType.done) {
          return true;
        } else if (result.type == ResultType.noAppToOpen) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No app found to open this file type. Opening online...'),
              ),
            );
            return await openDocument(context, doc);
          }
        } else {
          // Fallback if system failed to open local file directly
          if (context.mounted) {
            return await openDocument(context, doc);
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Local file not found. Opening online...'),
            ),
          );
          return await openDocument(context, doc);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [DocumentsService] openLocalDocument error: $e');
      if (context.mounted) {
        return await openDocument(context, doc);
      }
    }
    return false;
  }

  /// View / Open the document in system PDF viewer / browser
  static Future<bool> openDocument(BuildContext context, SummitDocument doc) async {
    if (doc.documentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid document URL')),
      );
      return false;
    }

    try {
      final uri = Uri.parse(doc.documentUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to in-app browser
        return await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open document: $e')),
      );
      return false;
    }
  }
}
