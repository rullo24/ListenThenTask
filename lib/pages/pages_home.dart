import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../account/account_widget.dart';
import '../auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speech = SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _transcript = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech error: ${error.errorMsg}')),
        );
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if ((status == 'done' || status == 'notListening') && _isListening) {
          setState(() => _isListening = false);
          final transcript = _transcript.trim();
          if (transcript.isNotEmpty) {
            _showConfirmationDialog(transcript);
          }
        }
      },
    );
    setState(() => _speechAvailable = available);
  }

  Future<void> _onMicPressed() async {
    if (!_isListening && !AuthService.instance.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use ListenThenTask')),
      );
      return;
    }

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition unavailable')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      // onStatus handles resetting _isListening and showing the dialog.
    } else {
      setState(() {
        _transcript = '';
        _isListening = true;
      });
      await _speech.listen(
        onResult: (result) {
          setState(() => _transcript = result.recognizedWords);
        },
      );
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
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
    _speech.stop();
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
