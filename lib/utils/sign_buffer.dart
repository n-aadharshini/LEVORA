import 'dart:collection';

class SignBuffer {
  final int bufferSize;
  final Queue<String> _buffer = Queue<String>();

  SignBuffer({this.bufferSize = 30});

  void addFrame(String label) {
    _buffer.addLast(label);
    if (_buffer.length > bufferSize) {
      _buffer.removeFirst();
    }
  }

  String getStableSign() {
    if (_buffer.length < bufferSize) return '';

    final counts = <String, int>{};
    for (final label in _buffer) {
      if (label.isNotEmpty) {
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return '';

    final best = counts.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Return sign only if 22 out of 30 frames agree
    if (best.value >= 22) return best.key;
    return '';
  }

  void clear() => _buffer.clear();
}
