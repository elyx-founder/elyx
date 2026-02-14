import 'package:just_audio/just_audio.dart';

class VoiceService {
  final player = AudioPlayer();

  Future speak(String reply) async {
    await player.setAsset('assets/audio/test.mp3');
    await player.play();
  }

  Future stop() async {
    await player.stop();
  }
}
