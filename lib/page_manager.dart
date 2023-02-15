import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'service_locator.dart';

class PageManager {
  final _audioHandler = getIt<AudioHandler>();
  final playerStateNotifier = ValueNotifier<PlayerState>(PlayerState.paused);
  final trackInfoNotifier = ValueNotifier<TrackInfo>(TrackInfo());

  void init() async {
    _audioHandler.playbackState.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playerStateNotifier.value = PlayerState.loading;
      } else if (!isPlaying) {
        playerStateNotifier.value = PlayerState.paused;
      } else {
        playerStateNotifier.value = PlayerState.playing;
      }
    });

    _audioHandler.mediaItem.listen((mediaEvent) {
      var trackInfo = TrackInfo();
      trackInfo.name = mediaEvent?.title;
      trackInfoNotifier.value = trackInfo;
    });
  }

  void play() => _audioHandler.play();

  void pause() => _audioHandler.pause();

  void stop() => _audioHandler.stop();

  void dispose() => _audioHandler.customAction('dispose');
}

enum PlayerState { paused, playing, loading }

class TrackInfo {
  String? name;
}
