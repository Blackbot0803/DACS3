import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';

class PageManager {
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;

  PageManager() {
    _init();
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
    _setInitialPlaylist();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
  }

  // const url = 'assets/songs/2.mp3';

  // TODO: set playlist
  void _setInitialPlaylist() async {
    // const prefix = 'https:url';
    const prefix = 'asset:///song';
    final song1 = Uri.parse("$prefix/1.mp3");
    // final song1 = Uri.parse(
    //     'https://drive.google.com/file/d/1zEDLjR3d4aJ6ZHWVPVwp5yDiPVY2k390/view?usp=sharing');
    final song2 = Uri.parse('$prefix/2.mp3');
    final song3 = Uri.parse('$prefix/3.mp3');
    final song4 = Uri.parse('$prefix/4.mp3');
    final song5 = Uri.parse('$prefix/5.mp3');
    final song6 = Uri.parse('$prefix/6.mp3');
    final song7 = Uri.parse('$prefix/7.mp3');

    // final song3 = Uri.parse('$prefix/SoundHelix-Song-3.mp3');
    _playlist = ConcatenatingAudioSource(children: [
      AudioSource.uri(song1, tag: "Ain't no rest for the wicked"),
      AudioSource.uri(song2, tag: "Ever felt fealt mantic"),
      AudioSource.uri(song3, tag: "Fashion drunk"),
      AudioSource.uri(song4, tag: "Little Pretty"),
      AudioSource.uri(song5, tag: "Short change hero"),
      AudioSource.uri(song6, tag: "Put it on the line"),
      AudioSource.uri(song7, tag: "What make a good man"),

      // AudioSource.uri(song3, tag: 'Song 3'),
    ]);
    await _audioPlayer.setAudioSource(_playlist);
  }

  void _listenForChangesInPlayerState() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInTotalDuration() {
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // TODO: update current song title

      final currentItem = sequenceState.currentSource;
      final title = currentItem?.tag as String?;
      currentSongTitleNotifier.value = title ?? '';

      // TODO: update playlist

      final playlist = sequenceState.effectiveSequence;
      final titles = playlist.map((item) => item.tag as String).toList();
      playlistNotifier.value = titles;

      // TODO: update shuffle mode

      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;

      // TODO: update previous and next buttons

      if (playlist.isEmpty || currentItem == null) {
        isFirstSongNotifier.value = true;
        isLastSongNotifier.value = true;
      } else {
        isFirstSongNotifier.value = playlist.first == currentItem;
        isLastSongNotifier.value = playlist.last == currentItem;
      }
    });
  }

  void play() async {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void onRepeatButtonPressed() {
    // TODO Repeat Button pressed Method
    repeatButtonNotifier.nextState();
    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatState.repeatSong:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  void onPreviousSongButtonPressed() {
    // TODO Previous Song Button pressed method

    _audioPlayer.seekToPrevious();
  }

  void onNextSongButtonPressed() {
    // TODO Next Song Button pressed method
    _audioPlayer.seekToNext();
  }

  void onShuffleButtonPressed() async {
    // TODO Shuffle Button pressed method
    final enable = !_audioPlayer.shuffleModeEnabled;
    if (enable) {
      await _audioPlayer.shuffle();
    }
    await _audioPlayer.setShuffleModeEnabled(enable);
  }

  // void addSong() {
  //   // TODO
  // }

  // void removeSong() {
  //   // TODO
  // }
}
