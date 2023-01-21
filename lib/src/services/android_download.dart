import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'android_download_tasks.dart';
import 'locator.dart';
import 'snackbar_service.dart';

// TODO: Should be able to cancel downloads (and then be able to trigger them again).
//       (should be done by removing the notification, I guess... does that cancel the task
// /      and remove the file and task entry in the database??)

// TODO: Check how much my implementation differs from the memo (Google Keep) note.

// TODO: (Very low priority) If the downloader converts the name to a valid name, then try removing the
//       "removeSlashes" on the backend. Does it work when downloading a file with / on browser and android?
//       (must add the / manually). If it doesn't work, just leave it as it is.

// TODO: File with 5'2'' gets saved as 5_2_ or something like that, and then the file cannot be opened using the
//       .open method.
//       UPDATE: This is solved. But the catch is that when opening the file, it opens it from a file descriptor (it seems)
//               It doesn't really open the file in VLC Player with its original name, but instead it's like "fd://56"
//               Not sure if I can fix this.
//
//               Ignoring the fd://34 issue, the 5'2" video downloads and opens correctly. The only little detail is that
//               5'2" becomes 52", but 5_2" would be a bit better (not perfect but better). This has to be fixed from the
//               backend, and has no impact in anything else (it's just a String regex replace).

// TODO: Find this directory using a library? Not necessary probably.
const String _DOWNLOAD_DIR = '/storage/emulated/0/Download/';

class AndroidDownloadService {
  AndroidDownloadService() {
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    _port.listen((dynamic data) {
      final String id = (data as List<dynamic>)[0] as String;
      final DownloadTaskStatus status = data[1] as DownloadTaskStatus;
      final int progress = data[2] as int;
      // print(data.toString());
      print('Download status: $id | $status | $progress');
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  final ReceivePort _port = ReceivePort();

  // TODO: Should be called "download or open". Or simplify the scope/responsability of this method
  //       and make it "only download", and then force the caller to open it if it's already downloaded.
  Future<void> downloadVideo(Uri videoUri) async {
    final String url = videoUri.toString();

    final DownloadTask? task = (await allTasks()).firstWhereOrNull(
      (DownloadTask element) => element.url == url,
    );

    if (!(await _shouldTriggerDownload(task))) {
      return;
    }

    final PermissionStatus permission = await Permission.storage.request();

    if (!permission.isGranted) {
      serviceLocator
          .get<SnackbarService>()
          .simpleSnackbar('Cannot get permission to download file');
      return;
    }

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: _DOWNLOAD_DIR,
    );
  }

// TODO: Too spaghetti
  Future<bool> _shouldTriggerDownload(DownloadTask? task) async {
    if (task == null) {
      return true;
    }

    if (task.status == DownloadTaskStatus.running ||
        task.status == DownloadTaskStatus.enqueued) {
      serviceLocator
          .get<SnackbarService>()
          .simpleSnackbar('Already being downloaded (${task.progress}%)');
      return false;
    }

    // TODO: Possible error... if the file is downloaded twice, the name would become "xyz.m4a (2)"
    //       which is an invalid name I guess.

    if (task.status == DownloadTaskStatus.complete) {
      final bool canOpen = await FlutterDownloader.open(taskId: task.taskId);

      if (canOpen) {
        return false;
      } else {
        // print('Error opening file: ${result.message}');
        serviceLocator.get<SnackbarService>().simpleSnackbar(
              'Cannot open the file (trying to download again...)',
            );
        await FlutterDownloader.remove(taskId: task.taskId);
      }
    } else if (task.status == DownloadTaskStatus.canceled ||
        task.status == DownloadTaskStatus.failed ||
        task.status == DownloadTaskStatus.paused) {
      // TODO: What to do in this situation?
      serviceLocator
          .get<SnackbarService>()
          .simpleSnackbar('(TODO) Unhandled status (${task.status})');
      return false;
    }

    return true;
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send(<dynamic>[id, status, progress]);
  }
}
