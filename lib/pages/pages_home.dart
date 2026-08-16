import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

import '../account/account_widget.dart';
import '../auth/auth_service.dart';

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
  String _transcript = '';
  String _lastFinalText = '';

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
      debugPrint('Vosk init error: $e');
    }
  }

  void _onPartial(String partialJson) {
    final text =
        (jsonDecode(partialJson) as Map<String, dynamic>)['partial']
            as String? ??
        '';
    if (text.isNotEmpty) {
      setState(() => _transcript = text);
    }
  }

  void _onResult(String resultJson) {
    final text =
        (jsonDecode(resultJson) as Map<String, dynamic>)['text'] as String? ??
        '';
    // Vosk's endpointing can flush the same finalized chunk more than once
    // around a silence boundary; skip appending an exact repeat.
    if (text.isNotEmpty && text != _lastFinalText) {
      _lastFinalText = text;
      setState(() {
        _transcript = _transcript.isEmpty ? text : '$_transcript $text';
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
      final transcript = _transcript.trim();
      if (transcript.isNotEmpty) {
        await _showConfirmationDialog(transcript);
      }
    } else {
      setState(() {
        _transcript = '';
        _lastFinalText = '';
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
          title: const Text('Add to Google Tasks?'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final taskText = controller.text.trim();
                Navigator.of(dialogContext).pop();
                // TODO: send taskText to Google Tasks (final stage)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Would send: "$taskText"')),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
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

      body: Center(
        child: Text(
          _isListening
              ? (_transcript.isEmpty ? 'Listening...' : _transcript)
              : 'Tap the mic to add a task',
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onMicPressed,
        backgroundColor: _isListening ? Colors.redAccent : null,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
