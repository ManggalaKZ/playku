import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  static Future<void> playBackgroundMusic() async {
    await _bgmPlayer.setLoopMode(LoopMode.one);
    await _bgmPlayer
        .setAudioSource(AudioSource.asset("assets/audio/bgmusik2.mp3"));
    await _bgmPlayer.play();
  }

  static Future<void> pauseBackgroundMusic() async {
    await _bgmPlayer.pause();
  }

  static Future<void> resumeBackgroundMusic() async {
    await _bgmPlayer.play();
  }

  static Future<void> playButtonSound() async {
    await _sfxPlayer
        .setAudioSource(AudioSource.asset("assets/audio/click3.mp3"));
    await _sfxPlayer.setVolume(1.8);
    await _sfxPlayer.play();
  }

  static Future<void> acc() async {
    await _sfxPlayer.setAudioSource(AudioSource.asset("assets/audio/acc2.mp3"));
    await _sfxPlayer.setVolume(1.8);
    await _sfxPlayer.play();
  }

  static Future<void> wrong() async {
    await _sfxPlayer
        .setAudioSource(AudioSource.asset("assets/audio/wrong.mp3"));
    await _sfxPlayer.setVolume(1.8);
    await _sfxPlayer.play();
  }
}
