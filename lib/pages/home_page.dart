import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioSourceOption {Network ,Asset}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _setupAudioPlayer(AudioSourceOption.Network);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Player"),
      ),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                   _sourceSelect(),
                  _progressBar(),
                  Row(
                    children: [
                      _controlButtons(),
                      _playbackControlButton(),
                    ],
                  ),
                ],

              )
              )
              ),
    );
  }

  Future<void> _setupAudioPlayer(AudioSourceOption option) async {
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stacktrace) {
      print("A stream error occured: $e");
    });
    try {
      if(option == AudioSourceOption.Network){
          await _player.setAudioSource(AudioSource.uri(Uri.parse(
          "https://orangefreesounds.com/wp-content/uploads/2023/12/Fireworks-ambience-sound-effect.mp3")));

      } else if(option == AudioSourceOption.Asset){
          await _player.setAudioSource(AudioSource.asset("lib/assets/audio/animal_bgm.mp3"));
      }
    
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Widget _sourceSelect(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MaterialButton(
          color: Colors.purple,
          child: Text('Network'),
          onPressed: ()=> _setupAudioPlayer(AudioSourceOption.Network)),
           MaterialButton(
          color: Colors.purple,
          child: Text('Asset'),
          onPressed: ()=> _setupAudioPlayer(AudioSourceOption.Asset))
      ],
    );
  }

  Widget _progressBar() {
    
    return StreamBuilder<Duration>(
        stream: _player.positionStream,
        builder: (context, snapshot) {
          return ProgressBar(
              progress: snapshot.data ?? Duration.zero,
              buffered: _player.bufferedPosition,
              total: _player.duration ?? Duration.zero,
              onSeek: (duration) {
                _player.seek(duration);
              },
              );
        });
  }

  Widget _playbackControlButton() {
    return StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final processingState = snapshot.data?.processingState;
          final playing = snapshot.data?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 64,
              height: 64,
              child: CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return IconButton(
              onPressed: _player.play,
              icon: Icon(Icons.play_arrow),
              iconSize: 64,
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              onPressed: _player.pause,
              icon: Icon(Icons.pause),
              iconSize: 64,
            );
          } else {
            return IconButton(
              onPressed: () => _player.seek(Duration.zero),
              icon: Icon(Icons.replay),
              iconSize: 64,
            );
          }
        });
  }
  Widget _controlButtons(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(stream: _player.speedStream, builder: (context, snapshot){
         return Row(
            children: [
              Icon(Icons.speed
              ),
              Slider(
                min: 1,
                max: 3,
                value: snapshot.data ?? 1,
                divisions: 3,
               onChanged: (value) async {
                await _player.setSpeed(value);
              })
            ],
          );
        }),
         StreamBuilder(stream: _player.volumeStream, builder: (context, snapshot){
         return Row(
            children: [
              Icon(Icons.volume_up
              ),
              Slider(
                min: 0,
                max: 3,
                value: snapshot.data ?? 1,
                divisions: 4,
               onChanged: (value) async {
                await _player.setVolume(value);
              })
            ],
          );
        })
      ],

    );
  }
}
