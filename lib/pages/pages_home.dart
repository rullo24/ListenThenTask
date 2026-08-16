import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

import '../account/account_widget.dart';
import '../auth/auth_service.dart';
import '../tasks/tasks_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _modelAsset = 'assets/models/vosk-model-small-en-us-0.15.zip';
  static const _sampleRate = 16000;

  SpeechService? _speechService;
  bool _modelReady = false;
  bool _isListening = false;
  String _finalizedText = '';
  String _partialText = '';
  String _lastFinalChunk = '';
  bool _showSuccessTick = false;

  String get _displayText =>
      [_finalizedText, _partialText].where((s) => s.isNotEmpty).join(' ');

  @override
  void initState() {
    super.initState();
    _initVosk();
  }

  Future<void> _initVosk() async {
    try {
      final modelPath = await ModelLoader().loadFromAssets(_modelAsset);
      final vosk = VoskFlutterPlugin.instance();
      final model = await vosk.createModel(modelPath);
      final recognizer = await vosk.createRecognizer(
        model: model,
        sampleRate: _sampleRate,
      );
      final speechService = await vosk.initSpeechService(recognizer);

      speechService.onPartial().listen(_onPartial);
      speechService.onResult().listen(_onResult);

      setState(() {
        _speechService = speechService;
        _modelReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech model failed to load: $e')),
      );
    }
  }

  void _onPartial(String partialJson) {
    final text =
        (jsonDecode(partialJson) as Map<String, dynamic>)['partial']
            as String? ??
        '';
    setState(() => _partialText = text);
  }

  void _onResult(String resultJson) {
    final text =
        (jsonDecode(resultJson) as Map<String, dynamic>)['text'] as String? ??
        '';
    // Vosk can occasionally re-flush the same finalized chunk; skip an
    // exact repeat of the immediately preceding chunk.
    if (text.isNotEmpty && text != _lastFinalChunk) {
      _lastFinalChunk = text;
      setState(() {
        _finalizedText = _finalizedText.isEmpty
            ? text
            : '$_finalizedText $text';
        // This chunk is now finalized; clear the partial so it isn't
        // shown (or appended) again once finalization catches up to it.
        _partialText = '';
      });
    }
  }

  Future<void> _onMicPressed() async {
    if (!_isListening && !AuthService.instance.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use ListenThenTask')),
      );
      return;
    }

    if (!_modelReady || _speechService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech model still loading')),
      );
      return;
    }

    if (_isListening) {
      await _speechService!.stop();
      setState(() => _isListening = false);
      // Use whatever's been recognized so far, including any not-yet-
      // finalized partial — stopping mid-utterance shouldn't drop it.
      final transcript = _displayText.trim();
      if (transcript.isNotEmpty) {
        await _showConfirmationDialog(transcript);
      }
    } else {
      setState(() {
        _finalizedText = '';
        _partialText = '';
        _lastFinalChunk = '';
        _isListening = true;
      });
      await _speechService!.start();
    }
  }

  Future<void> _showConfirmationDialog(String transcript) async {
    final controller = TextEditingController(text: transcript);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add to Google Tasks?',
            style: TextStyle(fontSize: 24),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: null,
            style: const TextStyle(fontSize: 22),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                final taskText = controller.text.trim();
                Navigator.of(dialogContext).pop();
                try {
                  await TasksService.instance.addTask(taskText);
                  if (!mounted) return;
                  _flashSuccessTick();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add task: $e')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _flashSuccessTick() async {
    setState(() => _showSuccessTick = true);
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() => _showSuccessTick = false);
  }

  @override
  void dispose() {
    _speechService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ListenThenTask"),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: AccountWidget(),
          ),
        ],
      ),

      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _isListening
                    ? (_displayText.isEmpty ? 'Listening...' : _displayText)
                    : 'Tap the mic to add a task',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          if (_showSuccessTick)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 120,
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: SizedBox(
        width: 112,
        height: 112,
        child: FloatingActionButton(
          onPressed: _onMicPressed,
          backgroundColor: _isListening ? Colors.redAccent : null,
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 48,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
