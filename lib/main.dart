import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = 'Audio Recorder Demo (sonofnos)';
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    audioRecord = Record();
    audioPlayer = AudioPlayer();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "";

// Start recording audio
  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

// Stop recording audio
  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      log(e.toString());
    }
  }

// Play recorded audio
  Future<void> playRecording() async {
    try {
      Source audioUrlSource = UrlSource(audioPath);
      await audioPlayer.play(
        audioUrlSource,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isRecording) ...{
                Text(
                  'Recording...',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 50),
              },

              // Add the button with wave blob here
              // SizedBox(
              //   width: 200,
              //   height: 200,
              //   child: WaveBlob(
              //     blobCount: 3,
              //     circleColors: const [
              //       Colors.pink,
              //       Colors.purple,
              //     ],
              //     amplitude: isRecording ? 10000 : 1,
              //     speed: 10,
              //     scale: 1,
              //     autoScale: true,
              //     centerCircle: true,
              //     child: Container(
              //       width: 200,
              //       height: 200,
              //       decoration: BoxDecoration(
              //         color: Colors.deepPurple,
              //         borderRadius: BorderRadius.circular(100),
              //       ),
              //       child: IconButton(
              //         icon: Icon(
              //           isRecording ? Icons.stop : Icons.mic,
              //           color: Colors.white,
              //           size: 50,
              //         ),
              //         onPressed: isRecording ? stopRecording : startRecording,
              //       ),
              //     ),
              //   ),
              // ),

              ElevatedButton(
                onPressed: isRecording ? stopRecording : startRecording,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(50),
                 backgroundColor: Colors.deepPurple,
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.green,
                  size: 50,
                ),
              ),

              const SizedBox(height: 100),

              if (!isRecording && audioPath.isNotEmpty) ...{
                ElevatedButton(
                  onPressed: playRecording,
                  child: const Text("Play"),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
