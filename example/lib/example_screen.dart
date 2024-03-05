import 'package:flutter/material.dart';
import 'audio_manager.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final AudioManager audioManager = AudioManager();
  late final Future<void> initializedFuture;
  @override
  void initState() {
    initializedFuture = audioManager.initializeAudio();
    super.initState();
  }

  @override
  void dispose() {
    audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter_al Example'),
      ),
      body: Center(
          child: FutureBuilder(
        future: initializedFuture,
        builder: (context, snapshot) => snapshot.connectionState !=
                ConnectionState.done
            ? const CircularProgressIndicator.adaptive(
                semanticsLabel: "Loading...")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Slider(
                    value: audioManager.gainValue,
                    onChanged: audioManager.updateGain,
                    label: 'Gain',
                    min: 0.0,
                    max: 1.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: audioManager.togglePlayback,
                        icon: Icon(audioManager.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        tooltip: (audioManager.isPlaying ? "Pause" : "Play"),
                      ),
                      IconButton(
                        onPressed: () => audioManager.ctx.resetDevice(),
                        tooltip: "Reset device",
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: audioManager.toggleLooping,
                        icon: Icon(audioManager.isLooping
                            ? Icons.repeat
                            : Icons.repeat_one),
                        tooltip: (audioManager.isLooping
                            ? "Disable looping"
                            : "Enable looping"),
                      ),
                      Checkbox(
                        value: audioManager.source.direct,
                        onChanged: (value) {
                          setState(() {
                            audioManager.source.direct = value ?? false;
                          });
                        },
                        semanticLabel: "Direct",
                      ),
                    ],
                  ),
                ],
              ),
      )),
    );
  }
}
