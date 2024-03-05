import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_al/flutter_al.dart';

void main() {
  runApp(const FlutterAlExample());
}

class FlutterAlExample extends StatelessWidget {
  const FlutterAlExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late Device device;
  late Context ctx;
  late Buffer buffer;
  late Source source;
  bool isPlaying = false;
  bool isLooping = false;
  bool isDirect = true;
  double gainValue = 0.5;

  @override
  void initState() {
    super.initState();
    initializeAudio();
  }

  Future<void> initializeAudio() async {
    ByteData pcmByteData = await rootBundle.load('assets/test.pcm');
    Uint8List pcmData = Uint8List.sublistView(pcmByteData);
    device = Device();
    ctx = Context(device, attributes: {"hrtf_soft": 1})..makeCurrent();
    buffer = ctx.generateBuffers(1)[0];
    buffer.setData(pcmData, sampleRate: 44100, format: BufferFormat.stereo16);
    source = ctx.generateSources(1)[0];
    source.queueBuffers([buffer]);
    source.looping = isLooping;
    source.gain = gainValue;
    source.direct = true;
  }

  @override
  void dispose() {
    source.dispose();
    buffer.dispose();
    ctx.dispose();
    device.dispose();
    super.dispose();
  }

  void togglePlayback() {
    if (isPlaying) {
      source.pause();
    } else {
      source.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void toggleDirect() {
    setState(() {
      isDirect = !isDirect;
      source.direct = isDirect;
    });
  }

  void toggleLooping() {
    setState(() {
      isLooping = !isLooping;
      source.looping = isLooping;
    });
  }

  void updateGain(double value) {
    setState(() {
      gainValue = value;
      source.gain = gainValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter_al Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slider(
              value: gainValue,
              onChanged: updateGain,
              label: 'Gain',
              min: 0.0,
              max: 1.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: togglePlayback,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  tooltip: (isPlaying ? "Pause" : "Play"),
                ),
                IconButton(
                    onPressed: toggleDirect,
                    icon: Icon(isDirect
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    tooltip: isDirect ? "Disable direct" : "Enable direct"),
                IconButton(
                    onPressed: () => ctx.resetDevice(),
                    tooltip: "Reset device",
                    icon: const Icon(Icons.refresh)),
                IconButton(
                  onPressed: toggleLooping,
                  icon: Icon(isLooping ? Icons.repeat : Icons.repeat_one),
                  tooltip: (isLooping ? "Disable looping" : "Enable looping"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
