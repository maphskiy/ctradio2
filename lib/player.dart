import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Player {
  bool urlIsSet = false;
  late AudioPlayer _audioPlayer;
  late String _url;
  Player(String url) {
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
        playerStateNotifier.value = PlayerState.loading;
      } else if (!isPlaying) {
        playerStateNotifier.value = PlayerState.paused;
      } else {
        playerStateNotifier.value = PlayerState.playing;
      }
    });

    _audioPlayer.icyMetadataStream.listen((event) {
      var trackInfo = TrackInfo();
      trackInfo.name = event?.headers?.name;
      trackInfoNotifier.value = trackInfo;
    });
  }

  final playerStateNotifier = ValueNotifier<PlayerState>(PlayerState.paused);
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

enum PlayerState { paused, playing, loading }

class TrackInfo {
  String? name;
}
