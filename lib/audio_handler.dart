import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io' show Platform;

const defaultUrl = 'https://live.leproradio.com/tribe.mp3';
const aacUrl = 'https://live.leproradio.com/tribe.aac';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'org.maphskiy.ctradio.channel.audio',
      androidNotificationChannelName: 'Criminal Tribe Radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  bool urlIsSet = false;
  final _player = AudioPlayer();

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _notifyAudioHandlerAboutMetadataEvents();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        //androidCompactActionIndices: const [0],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
      ));
    });
  }

  void _notifyAudioHandlerAboutMetadataEvents() {
    _player.icyMetadataStream.listen((event) {
      mediaItem.value =
          mediaItem.value?.copyWith(title: event?.info?.title ?? '');
    });
  }

  @override
  Future<void> play() {
    if (!urlIsSet) {
      MediaItem item = MediaItem(
        id: Platform.isIOS ? aacUrl : defaultUrl,
        title: '',
      );
      mediaItem.add(item);
      _player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
      urlIsSet = true;
    }
    return _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}
