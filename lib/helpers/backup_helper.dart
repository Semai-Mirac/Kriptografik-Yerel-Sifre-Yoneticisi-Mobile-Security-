import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/password_entry.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../constants/oauth_config.dart';
import 'database_helper.dart';
import 'security_helper.dart';

class BackupHelper {
  BackupHelper._();

  static const String _backupFileName = 'cipherguard_backup.enc';

  static Future<void> uploadEncryptedBackup({
    required String masterPassword,
  }) async {
    if (Platform.isIOS && kGoogleIosClientId.trim().isEmpty) {
      throw const FormatException(
        'iOS için kGoogleIosClientId tanımlanmalı (lib/constants/oauth_config.dart).',
      );
    }

    final entries = await DatabaseHelper.instance.getEntries();
    final payload = {
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'entries': entries.map((entry) => entry.toMap()).toList(),
    };

    final encryptedPayload = SecurityHelper.encryptData(
      jsonEncode(payload),
      masterPassword,
    );
    final payloadBytes = utf8.encode(encryptedPayload);

    final signIn = GoogleSignIn(
      scopes: <String>[drive.DriveApi.driveAppdataScope],
      clientId: kGoogleIosClientId.trim().isEmpty ? null : kGoogleIosClientId,
      serverClientId:
          kGoogleWebClientId.trim().isEmpty ? null : kGoogleWebClientId,
    );

    final account = await signIn.signIn();
    if (account == null) {
      throw const FormatException('Google hesabı seçilmedi.');
    }

    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);

    try {
      final driveApi = drive.DriveApi(client);

      final existing = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name='$_backupFileName' and 'appDataFolder' in parents and trashed=false",
        $fields: 'files(id,name)',
      );

      final media = drive.Media(
        Stream<List<int>>.value(payloadBytes),
        payloadBytes.length,
        contentType: 'application/octet-stream',
      );

      final metadata = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder'];

      if (existing.files != null && existing.files!.isNotEmpty) {
        await driveApi.files.update(
          metadata,
          existing.files!.first.id!,
          uploadMedia: media,
        );
      } else {
        await driveApi.files.create(
          metadata,
          uploadMedia: media,
        );
      }
    } finally {
      client.close();
    }
  }

  static Future<void> downloadEncryptedBackup({
    required String masterPassword,
  }) async {
    if (Platform.isIOS && kGoogleIosClientId.trim().isEmpty) {
      throw const FormatException(
        'iOS için kGoogleIosClientId tanımlanmalı.',
      );
    }

    final signIn = GoogleSignIn(
      scopes: <String>[drive.DriveApi.driveAppdataScope],
      clientId: kGoogleIosClientId.trim().isEmpty ? null : kGoogleIosClientId,
      serverClientId:
          kGoogleWebClientId.trim().isEmpty ? null : kGoogleWebClientId,
    );

    final account = await signIn.signIn();
    if (account == null) {
      throw const FormatException('Google hesabı seçilmedi.');
    }

    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);

    try {
      final driveApi = drive.DriveApi(client);

      final existing = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name='\$_backupFileName' and 'appDataFolder' in parents and trashed=false",
        $fields: 'files(id,name)',
      );

      if (existing.files == null || existing.files!.isEmpty) {
        throw const FormatException('Yedek dosyası bulunamadı.');
      }

      final fileId = existing.files!.first.id!;
      final drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataStore = [];
      await for (var data in media.stream) {
        dataStore.addAll(data);
      }

      final encryptedPayload = utf8.decode(dataStore);
      final decryptedPayload = SecurityHelper.decryptData(
        encryptedPayload,
        masterPassword,
      );

      final payload = jsonDecode(decryptedPayload) as Map<String, dynamic>;
      final elements = payload['entries'] as List<dynamic>;

      await DatabaseHelper.instance.clearAllEntries();
      for (var element in elements) {
        final entryMap = element as Map<String, dynamic>;
        final entry = PasswordEntry.fromMap(entryMap);
        await DatabaseHelper.instance.insertEntry(entry);
      }
    } finally {
      client.close();
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
