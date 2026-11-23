import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../shared/theme/app_theme.dart';

/// Self-update from GitHub Releases. CI publishes a release `v1.0.<N>` with
/// `cardsnap.apk` on every push to main, where N is also the app's build number.
class UpdateInfo {
  UpdateInfo(this.build, this.tag, this.apkUrl, this.notes);
  final int build;
  final String tag;
  final String apkUrl;
  final String notes;
}

class UpdateService {
  static const repo = 'RandomKid24/aureole-cardsnap';
  static const _apkName = 'cardsnap.apk';

  /// Returns the newer release, or null when up to date / offline / not Android.
  static Future<UpdateInfo?> checkForUpdate() async {
    if (!Platform.isAndroid) return null;
    try {
      final current = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
      final res = await http
          .get(Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final tag = (json['tag_name'] as String?) ?? '';
      final build = int.tryParse(tag.split('.').last) ?? 0;
      if (build <= current) return null;
      final assets = (json['assets'] as List?) ?? const [];
      final apk = assets.cast<Map<String, dynamic>>().where((a) => a['name'] == _apkName);
      if (apk.isEmpty) return null;
      return UpdateInfo(build, tag, apk.first['browser_download_url'] as String,
          (json['body'] as String?) ?? '');
    } catch (e) {
      debugPrint('UpdateService: check failed: $e');
      return null; // never block the app on an update check
    }
  }

  /// Downloads the APK (reporting 0..1 progress) and opens the Android installer.
  static Future<void> downloadAndInstall(UpdateInfo u, void Function(double) onProgress) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$_apkName');
    final client = http.Client();
    try {
      final res = await client.send(http.Request('GET', Uri.parse(u.apkUrl)));
      if (res.statusCode != 200) throw 'Download failed (${res.statusCode})';
      final total = res.contentLength ?? 0;
      var got = 0;
      final sink = file.openWrite();
      await for (final chunk in res.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress(got / total);
      }
      await sink.close();
    } finally {
      client.close();
    }
    final r = await OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
    if (r.type != ResultType.done) throw r.message;
  }

  /// Checks once and, if there's a newer build, shows the update dialog.
  static Future<void> checkAndPrompt(BuildContext context) async {
    final u = await checkForUpdate();
    if (u == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _UpdateDialog(info: u),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.info});
  final UpdateInfo info;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double? _progress;
  String? _error;

  Future<void> _start() async {
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await UpdateService.downloadAndInstall(widget.info, (p) {
        if (mounted) setState(() => _progress = p);
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() { _progress = null; _error = '$e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _progress != null;
    return AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: const Text('Update available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A newer version of CardSnap (${widget.info.tag}) is ready.'),
          if (busy) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress == 0 ? null : _progress, color: AppTheme.primaryBlue),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('Later')),
        TextButton(onPressed: busy ? null : _start, child: Text(_error == null ? 'Update now' : 'Retry')),
      ],
    );
  }
}
