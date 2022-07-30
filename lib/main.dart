import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'page_manager.dart';
import 'theme/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// use GetIt or Provider rather than a global variable in a real project
late final PageManager _pageManager;

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  //------------- App Wrapper

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: black,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CurrentSongTitle(),
              Playlist(),
              // AddRemoveSongButtons(),
              AudioProgressBar(),
              AudioControlButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------Song Title
class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(title,
              style: TextStyle(
                  fontSize: 40, color: white, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

// -------------------------Playlist
class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  '${playlistTitles[index]}',
                  style: TextStyle(color: white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Add and Remove Song Buttons
// class AddRemoveSongButtons extends StatelessWidget {
//   const AddRemoveSongButtons({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           FloatingActionButton(
//             backgroundColor: primary,
//             onPressed: _pageManager.addSong,
//             child: Icon(
//               Icons.add,
//               color: white,
//             ),
//           ),
//           FloatingActionButton(
//             backgroundColor: primary,
//             onPressed: _pageManager.removeSong,
//             child: Icon(
//               Icons.remove,
//               color: white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ----------------------Progress Bar
class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progressBarColor: primary,
          baseBarColor: white,
          thumbColor: primary,
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: _pageManager.seek,
        );
      },
    );
  }
}

// ------------Audio Control Button Widget container
class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

//----------Repeat Button
// --------- 3 State: No Repeat, Repeat 1 song, Repeat playlist
class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: _pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off: // No repeat
            icon = Icon(Icons.repeat, color: white);
            break;
          case RepeatState.repeatSong: //Repeat 1 song
            icon = Icon(
              Icons.repeat_one,
              color: primary,
            );
            break;
          case RepeatState.repeatPlaylist: // Repeat playlist
            icon = Icon(
              Icons.repeat,
              color: primary,
            );
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: _pageManager.onRepeatButtonPressed,
        );
      },
    );
  }
}

//----PReviousSongButton
class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(
            Icons.skip_previous,
            color: isFirst ? grey : white,
          ),
          onPressed:
              (isFirst) ? null : _pageManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

//------------Play/Stop music Button
class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: white,
              ),
              iconSize: 32.0,
              onPressed: _pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(
                Icons.pause,
                color: white,
              ),
              iconSize: 32.0,
              onPressed: _pageManager.pause,
            );
        }
      },
    );
  }
}

//-------------------NextButton
class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Icon(
            Icons.skip_next,
            color: isLast ? grey : white,
          ),
          onPressed: (isLast) ? null : _pageManager.onNextSongButtonPressed,
        );
      },
    );
  }
}

// -------------Shuffle Button
class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? Icon(Icons.shuffle)
              : Icon(Icons.shuffle, color: grey),
          onPressed: _pageManager.onShuffleButtonPressed,
        );
      },
    );
  }
}
