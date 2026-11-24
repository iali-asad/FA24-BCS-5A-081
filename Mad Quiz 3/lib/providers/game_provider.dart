import 'package:flutter/foundation.dart';
import '../models/bottle.dart';
import '../models/level.dart';
import '../models/move_snapshot.dart';
import '../game/puzzle_generator.dart';
import '../game/puzzle_solver.dart';
import '../services/audio_service.dart';

class GameProvider extends ChangeNotifier {
  final AudioService _audio;

  late LevelConfig _levelConfig;
  List<Bottle> _tubes = [];
  int? _selectedTubeIndex;
  int _moveCount = 0;
  final List<MoveSnapshot> _undoStack = [];

  bool _isWon = false;
  bool _isPaused = false;
  HintMove? _currentHint;
  int _extraTubesAdded = 0;

  // Pouring Animation state
  bool _isAnimatingPour = false;
  int? _animSourceIndex;
  int? _animDestIndex;
  int _animPouredCount = 0;

  GameProvider(this._audio);

  LevelConfig get levelConfig => _levelConfig;
  List<Bottle> get tubes => _tubes;
  int? get selectedTubeIndex => _selectedTubeIndex;
  int get moveCount => _moveCount;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get isWon => _isWon;
  bool get isPaused => _isPaused;
  HintMove? get currentHint => _currentHint;
  int get extraTubesAdded => _extraTubesAdded;

  bool get isAnimatingPour => _isAnimatingPour;
  int? get animSourceIndex => _animSourceIndex;
  int? get animDestIndex => _animDestIndex;
  int get animPouredCount => _animPouredCount;

  void loadLevel(int levelNumber) {
    _levelConfig = PuzzleGenerator.generateLevel(levelNumber);
    _tubes = _levelConfig.initialTubes.map((b) => b.copy()).toList();
    _selectedTubeIndex = null;
    _moveCount = 0;
    _undoStack.clear();
    _isWon = false;
    _isPaused = false;
    _currentHint = null;
    _extraTubesAdded = 0;
    _isAnimatingPour = false;

    notifyListeners();
  }

  void selectTube(int index) {
    if (_isWon || _isPaused || _isAnimatingPour) return;
    if (index < 0 || index >= _tubes.length) return;

    _currentHint = null;

    if (_selectedTubeIndex == null) {
      // Selecting source tube
      if (!_tubes[index].isEmpty) {
        _selectedTubeIndex = index;
        _audio.playSelect();
      } else {
        _audio.playError();
      }
    } else if (_selectedTubeIndex == index) {
      // Deselecting current tube
      _selectedTubeIndex = null;
      _audio.playSelect();
    } else {
      // Destination tube selected -> attempt pour!
      final srcIndex = _selectedTubeIndex!;
      final destIndex = index;
      final src = _tubes[srcIndex];
      final dest = _tubes[destIndex];

      if (src.canPourInto(dest)) {
        executePour(srcIndex, destIndex);
      } else {
        _audio.playError();
        _selectedTubeIndex = null;
      }
    }
    notifyListeners();
  }

  void executePour(int srcIndex, int destIndex) {
    final src = _tubes[srcIndex];
    final dest = _tubes[destIndex];

    final amount = src.pourableAmount(dest);
    if (amount <= 0) return;

    // Save snapshot for undo
    _undoStack.add(MoveSnapshot(
      fromIndex: srcIndex,
      toIndex: destIndex,
      count: amount,
      previousTubesState: _tubes.map((b) => b.copy()).toList(),
      moveCount: _moveCount,
    ));

    // Set animation parameters
    _isAnimatingPour = true;
    _animSourceIndex = srcIndex;
    _animDestIndex = destIndex;
    _animPouredCount = amount;
    _selectedTubeIndex = null;

    _audio.playPour();
    notifyListeners();

    // Complete liquid transfer after animation duration (350ms)
    Future.delayed(const Duration(milliseconds: 350), () {
      final colorToPour = _tubes[srcIndex].colors.last;
      for (int i = 0; i < amount; i++) {
        _tubes[srcIndex].colors.removeLast();
        _tubes[destIndex].colors.add(colorToPour);
      }

      _moveCount++;
      _isAnimatingPour = false;
      _animSourceIndex = null;
      _animDestIndex = null;

      // Check level win state
      checkWinCondition();

      notifyListeners();
    });
  }

  void checkWinCondition() {
    for (final tube in _tubes) {
      if (tube.isEmpty) continue;
      if (!tube.isSolved) {
        _isWon = false;
        return;
      }
    }

    _isWon = true;
    _audio.playWin();
  }

  void undo() {
    if (_isWon || _isPaused || _isAnimatingPour || _undoStack.isEmpty) return;

    final snapshot = _undoStack.removeLast();
    _tubes = snapshot.previousTubesState.map((b) => b.copy()).toList();
    _moveCount = snapshot.moveCount;
    _selectedTubeIndex = null;
    _currentHint = null;

    _audio.playSelect();
    notifyListeners();
  }

  void restart() {
    if (_isPaused || _isAnimatingPour) return;
    loadLevel(_levelConfig.levelNumber);
  }

  void requestHint() {
    if (_isWon || _isPaused || _isAnimatingPour) return;
    _currentHint = PuzzleSolver.findBestHint(_tubes);
    if (_currentHint != null) {
      _audio.playSelect();
    } else {
      _audio.playError();
    }
    notifyListeners();
  }

  void addExtraTube() {
    if (_isWon || _isPaused || _isAnimatingPour || _extraTubesAdded >= 2) return;
    _tubes.add(Bottle(capacity: 4, colors: []));
    _extraTubesAdded++;
    _audio.playSelect();
    notifyListeners();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    _audio.playClick();
    notifyListeners();
  }
}
