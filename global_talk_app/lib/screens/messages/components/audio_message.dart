

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:global_talk_app/constants.dart';
import 'package:voice_message_package/voice_message_package.dart'; // Make sure to import the necessary package for VoiceMessageView

class AudioMessage extends StatelessWidget {
  final types.FileMessage message;
  final Color colors;

  AudioMessage({super.key, required this.message,required this.colors});

  @override
  Widget build(BuildContext context) {
    dynamic audioURLS = "";

// Log the metadata to debug its structure
    print("arslans metadata: ${message.metadata}");

    if (message.metadata != null && message.metadata!["language"] != null ) {
      final language = message.metadata!["language"];

      // Handle case where "language" might be a map
      String userLanguage = "";
      if (language is String) {
        userLanguage = language; // Directly a string
      } else if (language is Map<String, dynamic>) {
        userLanguage = language["code"] ?? ""; // Extract string value from map
      }

      // Compare extracted language with user language
      audioURLS = userLanguage != user_language
          ? message.metadata!["translated_audio_url"]
          : message.uri;
    } else {
      audioURLS = message.uri;
    }

    print("audioURLS: $audioURLS");
    // dynamic audioURLS= "";
    // print("arslans"+message.metadata!["language"]);
    // if (message.metadata!["language"] ){
    //   audioURLS= message.metadata!["language"]!=user_language? message.metadata!["translated_audio_url"]: message.uri;
    // }
    // else{
    //   audioURLS=message.uri;
    // }
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.blue.withOpacity(0.1),
      ),
      child: VoiceMessageView(
        controller: VoiceController(
          // audioSrc: message.uri, // Use the message URI as the audio source
          audioSrc: audioURLS ,
          onComplete: () {

            // Handle completion of audio playback
            print("Audio playback complete");
          },
          onPause: () {
            // Handle pause event
            print("Audio paused");
          },
          onPlaying: () {
            // Handle playing event
            print("Audio is playing");
          },
          onError: (err) {
            // Handle error during playback
            print("Error during playback: $err");
          },
          maxDuration: const Duration(seconds: 3),
          isFile: false, // Set to true if you are using a local file
        ),


        innerPadding: 12,
        cornerRadius: 20,
        circlesColor: colors,
        activeSliderColor: colors,

      ),
    );
  }
}


//
// import 'package:flutter/material.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:voice_message_package/voice_message_package.dart'; // Ensure this is the correct package
// import 'package:http/http.dart' as http;
// import 'dart:io';
//
// class AudioMessage extends StatefulWidget {
//   final String audioUrl; // Original audio URL from Firestore
//   final String senderLanguage;
//   final String receiverLanguage;
//   final Color colors;
//
//   AudioMessage({
//     required this.audioUrl,
//     required this.senderLanguage,
//     required this.receiverLanguage,
//     required this.colors,
//   });
//
//   @override
//   _AudioMessageState createState() => _AudioMessageState();
// }
//
// class _AudioMessageState extends State<AudioMessage> {
//   String? translatedAudioUrl;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _handleTranslation();
//   }
//
//   Future<void> _handleTranslation() async {
//     if (widget.senderLanguage != widget.receiverLanguage) {
//       setState(() {
//         isLoading = true;
//       });
//
//       // Determine the FastAPI endpoint
//       String apiUrl = '';
//       if (widget.senderLanguage == 'German' && widget.receiverLanguage == 'English') {
//         apiUrl = 'https://api.signvista.online/german-to-english-audio/';
//       } else if (widget.senderLanguage == 'English' && widget.receiverLanguage == 'German') {
//         apiUrl = 'https://api.signvista.online/english-to-german-audio/';
//       }
//
//       if (apiUrl.isNotEmpty) {
//         print("aaa");
//         try {
//           // Fetch the original audio file
//           final response = await http.get(Uri.parse(widget.audioUrl));
//           if (response.statusCode == 200) {
//             final File tempFile = File('${Directory.systemTemp.path}/temp_audio.wav');
//             await tempFile.writeAsBytes(response.bodyBytes);
//
//             // Send the file to FastAPI for translation
//             final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
//               ..headers.addAll({'accept': 'application/json'})
//               ..files.add(await http.MultipartFile.fromPath(
//                 'file',
//                 tempFile.path,
//                 contentType: MediaType('audio', 'wav'),
//               ));
//
//
//             final apiResponse = await request.send();
//             if (apiResponse.statusCode == 200) {
//               final translatedFileBytes = await apiResponse.stream.toBytes();
//               final translatedFile = File('${tempFile.path}_translated.wav');
//               await translatedFile.writeAsBytes(translatedFileBytes);
//
//               // Use translated audio file path for playback
//               setState(() {
//                 translatedAudioUrl = translatedFile.path;
//               });
//             } else {
//               print('Translation failed with status: ${apiResponse.statusCode}');
//             }
//           }
//         } catch (e) {
//           print('Error during translation: $e');
//         } finally {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const CircularProgressIndicator(); // Show loading indicator
//     }
//
//     return VoiceMessageView(
//       controller: VoiceController(
//         audioSrc: translatedAudioUrl ?? widget.audioUrl, // Use translated audio if available
//         onComplete: () {
//           print("Audio playback complete");
//         },
//         onPause: () {
//           print("Audio paused");
//         },
//         onPlaying: () {
//           print("Audio is playing");
//         },
//         onError: (err) {
//           print("Error during playback: $err");
//         },
//         maxDuration: const Duration(seconds: 3),
//         isFile: translatedAudioUrl != null, // Use `true` for local files
//       ),
//       innerPadding: 12,
//       cornerRadius: 20,
//       circlesColor: widget.colors,
//       activeSliderColor: widget.colors,
//     );
//   }
// }
