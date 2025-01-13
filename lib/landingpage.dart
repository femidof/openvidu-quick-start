import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_test/pages/prejoin.dart';
import 'dart:convert';

import 'utils.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _joinRoom() async {
    final roomName = _roomController.text.trim();
    final participantName = _usernameController.text.trim();

    if (roomName.isEmpty || participantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required!')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(backend_server_url + '/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'roomName': roomName,
          'participantName': participantName,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        _showResponseDialog(responseData);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PreJoinPage(
                args: JoinArgs(
                  url: webrtc_server_url,
                  token: responseData['token'],
                ),
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showResponseDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Details'),
        content: Text(json.encode(data)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Join a Room'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 20.0, height: 100.0),
                const Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 43.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20.0, height: 100.0),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'Horizon',
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: true,
                    displayFullTextOnTap: true,
                    repeatForever: true,
                    animatedTexts: [
                      RotateAnimatedText(
                        'Call',
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RotateAnimatedText(
                        'Chat',
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RotateAnimatedText(
                        'Talk',
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(80.00)),
            // const Text(
            //   'Welcome!',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _joinRoom,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}
