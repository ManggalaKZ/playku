import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static const String _bgmVolumeKey = 'bgm_volume';
  static const String _sfxVolumeKey = 'sfx_volume';

  static Future<void> saveBgmVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bgmVolumeKey, value);
  }

  static Future<void> saveSfxVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxVolumeKey, value);
  }

  static Future<double> loadBgmVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bgmVolumeKey) ?? 0.1;
  }

  static Future<double> loadSfxVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sfxVolumeKey) ?? 0.1;
  }

  static Future<void> playBackgroundMusic() async {
    final volume = await loadBgmVolume();

    await _bgmPlayer.setVolume(volume);
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
    final volume = await loadSfxVolume();

    await _sfxPlayer.setVolume(volume);
    await _sfxPlayer
        .setAudioSource(AudioSource.asset("assets/audio/click3.mp3"));
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

  static void setBgmVolume(double value) {
    _bgmPlayer.setVolume(value);
  }

  static void setSfxVolume(double value) {
    _sfxPlayer.setVolume(value * 1.5);
  }
}
