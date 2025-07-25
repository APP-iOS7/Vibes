import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FileServices {
  FileServices._singleTon(); // 컴파일러 자동 생성자 차단

  static final FileServices _instance = FileServices._singleTon();
  YoutubeExplode get _yt => YoutubeExplode();

  factory FileServices() {
    return _instance;
  }

  // 문서 path getter
  Future<String> _getDoc() async {
    final doc = await getApplicationDocumentsDirectory();
    print(doc);
    return doc.path;
  }

  // 파일경로 getter
  File _getFile({required String docPath, required String videoId}) {
    return File('$docPath/$videoId.mp3');
  }

  // Public 메서드로 파일 경로 가져오기
  Future<String> getAudioFilePath({required String videoId}) async {
    var dir = await _getDoc();
    return _getFile(docPath: dir, videoId: videoId).path;
  }

  static FileServices get instance => _instance;

  // 파일 다운로드 - 성공/실패 여부를 반환하고 콜백으로 플레이리스트에 추가
  Future<bool> downloadVideo({
    required VideoModel video, 
    Function(VideoModel)? onDownloadComplete
  }) async {
    // 비디오 스트림 가져오기
    IOSink? audioFileStream;
    try {
      print("[FileServices] Starting download for: ${video.title}");
      
      // 해당 비디오의 정보를 가져옵니다.
      var manifest = await _yt.videos.streamsClient.getManifest(video.videoId);
      
      // 오디오 스트림이 없는 경우 체크
      if (manifest.audioOnly.isEmpty) {
        print("[FileServices] No audio stream available for: ${video.videoId}");
        return false;
      }
      
      // 모디오 스트림을 가져오는 코드
      var audioStreamInfo = manifest.audioOnly.first;
      // 문서 생성
      var dir = await _getDoc();

      // 저장할 경로 설정
      var audioFile = _getFile(docPath: dir, videoId: video.videoId!);
      print("[FileServices] File path: ${audioFile.path}");

      // 오디오 파일 스트림 형성
      var audioStream = _yt.videos.streamsClient.get(audioStreamInfo);
      // 오디오 파일 -> 생성한 File 객체어 Write
      audioFileStream = audioFile.openWrite();
      
      // **중요** 해당 함수를 통해 다운로드를 합니다.
      await audioStream.pipe(audioFileStream);
      
      // 다운로드 성공 시에만 정보 설정
      video.audioPath = audioFile.path;
      video.downloadDate = DateTime.now();
      
      print("[FileServices] Download completed successfully for: ${video.title}");
      
      // 콜백이 제공된 경우 실행
      if (onDownloadComplete != null) {
        onDownloadComplete(video);
      }
      
      return true;
      
    } catch (err) {
      print("[FileServices] Download failed for ${video.videoId}: $err");
      
      // 실패 시 audioPath 초기화 (혹시 이전에 설정되어 있을 수 있으므로)
      video.audioPath = null;
      video.downloadDate = null;
      
      return false;
    } finally {
      // audioFileStream가 null이 아닐 때만 닫기
      if (audioFileStream != null) {
        try {
          await audioFileStream.flush();
          await audioFileStream.close();
        } catch (e) {
          print("[FileServices] Error closing file stream: $e");
        }
      }
    }
  }

  Future<bool> isVideoDownloaded({required String videoId}) async {
    // 앱 전용 저장소 경로 가져오기
    var directory = await getApplicationDocumentsDirectory();
    // 읽을 파일 경로
    var filePath = File('${directory.path}/$videoId.mp3');
    // 파일 존재 여부 확인
    return filePath.exists();
  }

  // 파일의 생성 시간을 가져오는 메서드 추가
  Future<DateTime?> getFileCreationDate({required String videoId}) async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      var filePath = File('${directory.path}/$videoId.mp3');
      
      if (await filePath.exists()) {
        final fileStat = await filePath.stat();
        return fileStat.modified; // 수정 시간을 생성 시간으로 사용
      }
      return null;
    } catch (e) {
      print('Error getting file creation date for $videoId: $e');
      return null;
    }
  }

  Future<void> readAudioFile({required String videoId}) async {
    // 앱 전용 저장소 경로 가져오기
    var directory = await getApplicationDocumentsDirectory();

    // 읽을 파일 경로
    var filePath = '${directory.path}/$videoId.mp3';
    print(filePath);
    // 파일 존재 여부 확인
    var file = File(filePath);

    if (await file.exists()) {
      // 오디오 파일을 바이트 배열로 읽기
      var fileBytes = await file.readAsBytes();

      // 오디오 파일 처리 예시 (여기서는 바이트 배열의 크기를 출력)
      print('파일 크기: ${fileBytes.length} bytes');
      print('파일 읽어드리기 : ${fileBytes.toString()}');
    } else {
      print('파일이 존재하지 않습니다.');
    }
  }

  Future<void> playSoundinFile(AudioPlayer audioPlayer) async {
    // 앱 전용 저장소 경로 가져오기
    var directory = await getApplicationDocumentsDirectory();

    // 읽을 파일 경로
    var filePath = '${directory.path}/audio.mp3';

    // 파일 존재 여부 확인
    var file = File(filePath);

    if (await file.exists()) {
      // 오디오 파일을 just_audio로 실행하기( 둘 다 사용하지 못함 하나만 사용해야 합니다)
      // await audioPlayer.setFilePath(file.path);

      // 로컬 파일 경로를 AudioSource.file로 로드합니다.
      final audioSource = AudioSource.file(
        file.path,
        tag: MediaItem(
          id: '1', // 고유 ID
          album: "Album Name", // 앨범 이름
          title: "Song Title", // 곡 제목
          artUri: Uri.parse(
            'https://img.youtube.com/vi/2A8G_VsQqDI/hqdefault.jpg',
          ), // 앨범 아트 이미지
        ),
      );

      await audioPlayer.setAudioSource(audioSource);

      await audioPlayer.play();
    } else {
      print('파일이 존재하지 않습니다.');
    }
  }

  Future<void> pauseSoundinFile(AudioPlayer audioPlayer) async {
    // 앱 전용 저장소 경로 가져오기
    var directory = await getApplicationDocumentsDirectory();

    // 읽을 파일 경로
    var filePath = '${directory.path}/audio.mp3';

    // 파일 존재 여부 확인
    var file = File(filePath);

    if (await file.exists()) {
      // 오디오 파일을 just_audio로 실행하기
      await audioPlayer.setFilePath(file.path);

      await audioPlayer.pause();
    } else {
      print('파일이 존재하지 않습니다.');
    }
  }

  // 제거 함수
  Future<void> deleteVideo({required String videoId}) async {
    // 내부 파일 경로 가져오기
    var docPath = await _getDoc();
    File file = _getFile(docPath: docPath, videoId: videoId);

    file.delete();
  }
}
