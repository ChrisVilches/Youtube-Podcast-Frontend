import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import '../services/download_tasks.dart';
import '../services/youtube.dart';
import '../types.dart';
import '../util/storage.dart';
import 'left_right_row.dart';

class VideoDebug extends StatefulWidget {
  const VideoDebug({
    super.key,
    required this.videoId,
    required this.scrollBottom,
  });

  final VideoID videoId;
  final VoidCallback scrollBottom;

  @override
  State<StatefulWidget> createState() => _VideoDebugState();
}

class _VideoDebugState extends State<VideoDebug> {
  bool _loaded = false;
  bool _fileExists = false;
  String? _fileFullPath = '';
  DownloadTask? _task;
  bool _displayDebug = false;
  String? _sha1Local;
  String? _sha1Server;
  bool _sha1ServerLoaded = false;

  Future<void> _loadData() async {
    final DownloadTask? task = await findTask(widget.videoId);

    if (task == null) {
      setState(() {
        _loaded = true;
        _task = null;
      });
      widget.scrollBottom();
      return;
    }

    final Directory dir = await getValidDownloadDir();
    final String saveFilePath = join(dir.path, task.filename);
    // ignore: avoid_slow_async_io
    final bool fileExists = await File(saveFilePath).exists();
    final String sha1 = fileExists ? await getFileSHA1(saveFilePath) : '';

    setState(() {
      _task = task;
      _fileExists = fileExists;
      _fileFullPath = saveFilePath;
      _sha1Local = sha1;
      _loaded = true;
    });

    // ignore: unawaited_futures
    _loadSha1();
    widget.scrollBottom();
  }

  Future<void> _loadSha1() async {
    if (_sha1ServerLoaded) {
      return;
    }

    final Map<String, dynamic> stat = await getVideoFileStat(widget.videoId);
    final Map<String, dynamic> metadata =
        stat['metaData'] as Map<String, dynamic>;

    setState(() {
      _sha1Server = metadata['sha1'] as String;
      _sha1ServerLoaded = true;
    });
  }

  String _formatBool(final bool v) => v ? 'Yes' : 'No';

  String _formatStatus(final DownloadTaskStatus status) {
    final Map<DownloadTaskStatus, String> statusString =
        <DownloadTaskStatus, String>{
      DownloadTaskStatus.complete: 'complete',
      DownloadTaskStatus.canceled: 'canceled',
      DownloadTaskStatus.enqueued: 'enqueued',
      DownloadTaskStatus.failed: 'failed',
      DownloadTaskStatus.paused: 'paused',
      DownloadTaskStatus.running: 'running',
      DownloadTaskStatus.undefined: 'undefined'
    };

    return statusString[status]!;
  }

  @override
  void initState() {
    _displayDebug = usesFlutterDownloader();
    super.initState();
  }

  String _sha1Match() {
    if (_sha1Local == null || _sha1Server == null) {
      return '';
    }

    return _sha1Local == _sha1Server ? '✅' : '❌';
  }

  Widget _getItems(final DownloadTask? task) {
    if (task == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Text('Task does not exist'),
      );
    }

    return Column(
      children: <LeftRightRow>[
        LeftRightRow(
          left: 'Task exists?',
          right: _formatBool(task != null),
        ),
        LeftRightRow(
          left: 'Task status',
          right: _formatStatus(task.status),
        ),
        LeftRightRow(
          left: 'Task progress',
          right: '${task.progress}%',
        ),
        LeftRightRow(left: 'Full path', right: _fileFullPath ?? ''),
        LeftRightRow(left: 'File exists', right: _formatBool(_fileExists)),
        LeftRightRow(
          left: 'SHA1 (local)',
          right: '${_sha1Match()}$_sha1Local',
        ),
        LeftRightRow(
          left: 'SHA1 (server)',
          right: _sha1ServerLoaded ? '${_sha1Match()}$_sha1Server' : '-',
        )
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (!_displayDebug) {
      return Container();
    }

    if (!_loaded) {
      return ElevatedButton.icon(
        onPressed: _loadData,
        icon: const Icon(Icons.bug_report),
        label: const Text('Load debug information'),
      );
    }

    final ElevatedButton button = ElevatedButton.icon(
      onPressed: _loadData,
      icon: const Icon(Icons.refresh),
      label: const Text('Reload'),
    );

    return Column(
      children: <Widget>[button, _getItems(_task)],
    );
  }
}
