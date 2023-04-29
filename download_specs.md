# Download Specifications

## The `DOWNLOAD` button label

The `DOWNLOAD` button always displays the same label, even if the file is stored and can be opened without downloading.
If the file exists, then it will be attempted to be opened. Changing the text depending on whether the file exists or not
is a bit more difficult to implement, so the text is just a static label for both cases.

## Logic when pressing the `DOWNLOAD` button (mobile)

The following will happen:

1. If the download task status is `DownloadTaskStatus.complete`, it will be attempted to be opened (if it succeeds, the file will start playing, and the flow finishes).
2. If the download task status is `DownloadTaskStatus.complete`, but the file doesn't exist, it will be downloaded.
3. If the download task status is `DownloadTaskStatus.complete`, but errors when opening, an error message will be shown.
4. A download task is considered to be in-progress by looking at the status in its task record (regardless of the existence of the file).
5. If a video has no record, it will be downloaded.
6. For all status values other than "in-progress" and "complete", the file will be downloaded.
7. Before any download, the previous task(s) for that video is cleaned up (both record and file).

## Failure while downloading (mobile)

Sadly nothing can be done after sending the download job to the queue. If the user closes the main app, and leaves only the background process, there's a chance the task will fail. There are two ways to handle failed tasks:

1. When pressing the `DOWNLOAD` button again, the data (record and file) will be cleaned up and the file will be re-downloaded. This will work correctly whether the file was removed automatically or not.
2. If for some reason the task appears as `DownloadTaskStatus.complete`, but the file wasn't downloaded correctly (i.e. it's corrupt), the user can manually press the `Clear data` button to remove its data (both task record and file). Note that the app never checks whether a file is corrupt or not.
