import 'package:audioplayers/audioplayers.dart';

import '../models/story_models.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  AudioMood? _currentMood;

  static const Map<AudioMood, String> _musicAssets = {
    AudioMood.menu: 'audio/menu_loop.wav',
    AudioMood.house: 'audio/house_ambient.wav',
    AudioMood.road: 'audio/road_ambient.wav',
    AudioMood.interlude: 'audio/interlude_bell.wav',
    AudioMood.aquarium: 'audio/aquarium_ambient.wav',
    AudioMood.lighthouse: 'audio/lighthouse_ambient.wav',
    AudioMood.finalRoom: 'audio/final_room.wav',
    AudioMood.endingHope: 'audio/ending_hope.wav',
    AudioMood.endingLoop: 'audio/ending_loop.wav',
    AudioMood.endingBreak: 'audio/ending_break.wav',
    AudioMood.endingObserver: 'audio/ending_observer.wav',
    AudioMood.silence: 'audio/symbol_ping.wav',
  };

  Future<void> init() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.55);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setVolume(0.75);
    } catch (_) {}
  }

  Future<void> playMood(AudioMood mood) async {
    if (_currentMood == mood) return;
    _currentMood = mood;
    final asset = _musicAssets[mood];
    if (asset == null) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> playSymbolPulse() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/symbol_ping.wav'));
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _musicPlayer.dispose();
      await _sfxPlayer.dispose();
    } catch (_) {}
  }
}
