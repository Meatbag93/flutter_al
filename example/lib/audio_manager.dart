import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_al/flutter_al.dart';

class AudioManager {
  late Device device;
  late Context ctx;
  late Buffer buffer;
  late Source source;
  bool isPlaying = false;
  bool isLooping = false;
  double gainValue = 0.5;

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

  void dispose() {
    source.dispose();
    buffer.dispose();
    ctx.dispose();
    device.dispose();
  }

  void togglePlayback() {
    if (isPlaying) {
      source.pause();
    } else {
      source.play();
    }
    isPlaying = !isPlaying;
  }

  void toggleLooping() {
    isLooping = !isLooping;
    source.looping = isLooping;
  }

  void updateGain(double value) {
    gainValue = value;
    source.gain = gainValue;
  }
}
