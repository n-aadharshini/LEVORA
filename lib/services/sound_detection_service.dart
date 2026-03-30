import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
import 'package:path_provider/path_provider.dart';

class SoundDetectionService {
  static final SoundDetectionService instance = SoundDetectionService._();
  SoundDetectionService._();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;
  bool _isRecording = false;
  final _recorder = AudioRecorder();

  // Callback so UI can update detected label + confidence
  Function(String label, double confidence, String intensity)? onSoundDetected;

  static const int _yamnetInputSize = 15600;

  static const Set<String> _importantKeywords = {
    'siren',
    'alarm',
    'fire alarm',
    'smoke detector',
    'emergency',
    'dog',
    'bark',
    'baby',
    'cry',
    'crying',
    'infant',
    'scream',
    'shout',
    'knock',
    'door',
    'glass',
    'explosion',
    'gunshot',
    'horn',
    'car alarm',
  };

  bool get isLoaded => _isLoaded;
  bool get isRecording => _isRecording;

  // ─────────────────────────────────────────────────────────────
  // 1. Load YAMNet model + labels
  // ─────────────────────────────────────────────────────────────
  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        'assets/models/yamnet.tflite',
        options: options,
      );

      final raw = await rootBundle.loadString(
        'assets/models/yamnet_labels.txt',
      );

      final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();

      if (lines.first.contains(',')) {
        // CSV format: index,mid,display_name
        _labels = lines.map((l) => l.split(',').last.trim()).toList();
      } else {
        // Plain format: one label per line
        _labels = lines.map((l) => l.trim()).toList();
      }

      print('✅ YAMNet loaded! ${_labels.length} labels');
      _isLoaded = true;
    } catch (e) {
      print('❌ YAMNet load error: $e');
      _isLoaded = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Start listening
  // ─────────────────────────────────────────────────────────────
  Future<void> startListening() async {
    if (!_isLoaded || _isRecording) return;

    // FIX 2: Set flag BEFORE loop so loop doesn't exit immediately
    _isRecording = true;
    print('🎙️ Listening started...');
    _recordAndClassifyLoop();
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Stop listening
  // ─────────────────────────────────────────────────────────────
  Future<void> stopListening() async {
    _isRecording = false;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (e) {
      print('⚠️ Stop error: $e');
    }
    print('🛑 Listening stopped');
  }

  // ─────────────────────────────────────────────────────────────
  // 4. Core loop — record 1.5s chunk → classify → repeat
  // ─────────────────────────────────────────────────────────────
  Future<void> _recordAndClassifyLoop() async {
    while (_isRecording) {
      try {
        // FIX 3: Real temp file path (not empty string)
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/audio_chunk.wav';

        // Start recording
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: filePath,
        );

        // Record for 1.5 seconds
        await Future.delayed(const Duration(milliseconds: 1500));

        // Stop and get file
        await _recorder.stop();

        if (!_isRecording) break;

        // Run inference on the chunk
        await _classifyChunk(filePath);
      } catch (e) {
        print('❌ Loop error: $e');
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 5. Classify one audio chunk
  // ─────────────────────────────────────────────────────────────
  Future<void> _classifyChunk(String filePath) async {
    try {
      // FIX 4: Use dart:io File instead of rootBundle
      final file = File(filePath);
      if (!await file.exists()) return;

      final bytes = await file.readAsBytes();

      // WAV files have a 44-byte header — skip it to get raw PCM
      final pcmStart = 44;
      if (bytes.length <= pcmStart) return;

      final pcmBytes = bytes.sublist(pcmStart);
      final rawSamples = pcmBytes.buffer.asInt16List();

      // Normalise to Float32 [-1.0, 1.0] and pad/trim to 15600
      final input = Float32List(_yamnetInputSize);
      final copyLen = math.min(rawSamples.length, _yamnetInputSize);
      for (int i = 0; i < copyLen; i++) {
        input[i] = rawSamples[i] / 32768.0;
      }

      // Calculate intensity (RMS dB)
      final intensity = _calculateIntensity(input);

      // FIX 5: Correct input tensor shape [1, 15600]
      final inputTensor = [input.toList()];

      // Output shape [1, 521]
      final List<List<double>> output = [List.filled(521, 0.0)];

      _interpreter!.run(inputTensor, output);

      // Find top result
      int maxIndex = 0;
      double maxScore = 0.0;
      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIndex = i;
        }
      }

      if (maxScore > 0.15 && maxIndex < _labels.length) {
        final label = _labels[maxIndex];
        print(
            '🔊 Detected: $label (${(maxScore * 100).toStringAsFixed(1)}%) — $intensity');

        // Notify UI
        onSoundDetected?.call(label, maxScore, intensity);

        // Vibrate only for important sounds
        if (_isImportantSound(label)) {
          _triggerVibration(label);
        }
      }
    } catch (e) {
      print('❌ Classification error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 6. Intensity calculation
  // ─────────────────────────────────────────────────────────────
  String _calculateIntensity(Float32List samples) {
    double sumSq = 0.0;
    for (final s in samples) {
      sumSq += s * s;
    }
    final rms = math.sqrt(sumSq / samples.length);
    final db = rms > 0 ? 20.0 * (math.log(rms) / math.ln10) : -90.0;

    if (db > -20.0) return 'High';
    if (db > -40.0) return 'Medium';
    return 'Low';
  }

  // ─────────────────────────────────────────────────────────────
  // 7. Important sound filter
  // ─────────────────────────────────────────────────────────────
  bool _isImportantSound(String label) {
    final lower = label.toLowerCase();
    return _importantKeywords.any((kw) => lower.contains(kw));
  }

  // ─────────────────────────────────────────────────────────────
  // 8. Vibration patterns by sound type
  // ─────────────────────────────────────────────────────────────
  void _triggerVibration(String label) async {
    final l = label.toLowerCase();
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    if (l.contains('siren') || l.contains('alarm') || l.contains('fire')) {
      Vibration.vibrate(pattern: [0, 500, 100, 500, 100, 500]);
    } else if (l.contains('dog') || l.contains('bark')) {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
    } else if (l.contains('knock') || l.contains('door')) {
      Vibration.vibrate(pattern: [0, 300, 200, 300]);
    } else if (l.contains('baby') || l.contains('cry')) {
      Vibration.vibrate(pattern: [0, 400, 100, 400, 100, 400]);
    } else if (l.contains('scream') || l.contains('shout')) {
      Vibration.vibrate(pattern: [0, 200, 80, 200, 80, 200]);
    } else {
      Vibration.vibrate(duration: 300);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 9. Dispose
  // ─────────────────────────────────────────────────────────────
  void dispose() {
    stopListening();
    _interpreter?.close();
    _isLoaded = false;
  }
}
