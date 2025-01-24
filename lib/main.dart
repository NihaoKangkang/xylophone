import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: XylophoneApp(),
    ),
  ));
}

const List<Color> keyColors = [
  Colors.redAccent,
  Colors.orangeAccent,
  Colors.yellowAccent,
  Colors.greenAccent,
  Colors.lightBlueAccent,
  Colors.blue,
  Colors.purpleAccent,
];

const List<LogicalKeyboardKey> keyBindings = [
  LogicalKeyboardKey.keyA, // note1
  LogicalKeyboardKey.keyS, // note2
  LogicalKeyboardKey.keyD, // note3
  LogicalKeyboardKey.keyF, // note4
  LogicalKeyboardKey.keyJ, // note5
  LogicalKeyboardKey.keyK, // note6
  LogicalKeyboardKey.keyL, // note7
];

class XylophoneApp extends StatefulWidget {
  const XylophoneApp({super.key});

  @override
  State<XylophoneApp> createState() => _XylophoneAppState();
}

class _XylophoneAppState extends State<XylophoneApp> {
  final _audioPlayers = List<AudioPlayer>.generate(
    7,
    (_) => AudioPlayer(),
  );

  int? activeKey;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 7; i++) {
      _audioPlayers[i - 1].setAudioSource(AudioSource.uri(
        Uri.parse('asset:///assets/note$i.wav'),
      ));
    }
    _focusNode.requestFocus(); // 确保键盘事件生效
  }

  Future<void> playTones(int id) async {
    final player = _audioPlayers[id - 1];
    await player.seek(Duration.zero);
    player.play();
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event.runtimeType == KeyDownEvent) {
      final keyIndex = keyBindings.indexOf(event.logicalKey);
      if (keyIndex != -1) {
        final id = keyIndex + 1;
        setState(() {
          activeKey = id;
        });
        playTones(id);
      }
    } else if (event.runtimeType == KeyUpEvent) {
      setState(() {
        activeKey = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal =
            constraints.maxWidth >= constraints.maxHeight; // 检测最长边

        return SafeArea(
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyPress,
            autofocus: true,
            child: isHorizontal
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildKeys(),
                  )
                : Column(
                    verticalDirection: VerticalDirection.up,
                    children: _buildKeys(),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildKeys() {
    return List.generate(7, (index) {
      final id = index + 1;
      final isActive = activeKey == id;
      return Expanded(
        flex: 1,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              activeKey = id;
            });
            playTones(id);
          },
          onTapUp: (_) {
            setState(() {
              activeKey = null;
            });
          },
          onTapCancel: () {
            setState(() {
              activeKey = null;
            });
          },
          child: Container(
            color:
                isActive ? keyColors[index].withAlpha(153) : keyColors[index],
            child: Center(
              child: Text(
                '${keyBindings[index].keyLabel.toUpperCase()} ($id)',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
