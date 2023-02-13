import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  bool urlIsSet = false;
  late AudioPlayer _audioPlayer;
  late String _url;
  PageManager(String url) {
    _url = url;
    _init();
  }
  void _init() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else {
        buttonNotifier.value = ButtonState.playing;
      }
    });

    _audioPlayer.icyMetadataStream.listen((event) {
      var trackInfo = TrackInfo();
      trackInfo.name = event?.headers?.name;
      trackInfoNotifier.value = trackInfo;
    });
  }

  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final trackInfoNotifier = ValueNotifier<TrackInfo>(TrackInfo());

  void play() {
    if (!urlIsSet) {
      _audioPlayer.setUrl(_url);
      urlIsSet = true;
    }
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void stop() {
    _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }

class TrackInfo {
  String? name;
}
