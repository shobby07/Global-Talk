import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../constants.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ChatInputField extends StatefulWidget {
  final types.Room room;

  const ChatInputField({super.key, required this.room});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _recordingStartTime;  // Variable to store the start time of the recording


  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions when the widget is initialized
  }




  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  // Helper function to format the duration in minutes and seconds
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _sendMessage(BuildContext context) async {
    if (_controller.text.isNotEmpty) {
      final lan = await getUserLanguage(FirebaseChatCore.instance.firebaseUser!.uid);
      final message = types.PartialText(text: _controller.text + "///$lan");

      // Send the message using Firebase Chat Core
      FirebaseChatCore.instance.sendMessage(message  , widget.room.id);
      _controller.clear();
    }
  }



  // Future<void> _sendVoiceMessage() async {
  //   if (_isRecording) {
  //     _recordingStartTime = DateTime.now();
  //     final path = await _recorder.stop();
  //     if (path != null) {
  //       final File audioFile = File(path);
  //       final recordingEndTime = DateTime.now();  // Capture the end time
  //       // Get the duration from the recording
  //       // _recordingDuration = await _recorder.getRecordDuration();
  //       final duration = recordingEndTime.difference(_recordingStartTime!).inSeconds;  // Calculate the duration in seconds
  //
  //       if (await audioFile.exists()) {
  //         // print('Audio file exists at: ${audioFile.path}');
  //         // print('Recording duration: $duration seconds');
  //         // final message = types.PartialFile(
  //         //   name: 'voice_message.m4a',
  //         //   size: await audioFile.length(),
  //         //   uri: audioFile.uri.toString(),
  //         // );
  //         setState(() {
  //           _isRecording = false;
  //         });
  //
  //
  //
  //         // Upload the audio file to Firebase Storage
  //         final storageRef = FirebaseStorage.instance
  //             .ref()
  //             .child('audio_messages')
  //             .child('${DateTime.now().millisecondsSinceEpoch}.wav');
  //
  //         final metadata = SettableMetadata(
  //           contentType: 'audio/wav', // Make sure the content type matches the file type
  //         );
  //         // Upload the file and get the download URL
  //         await storageRef.putFile(audioFile,metadata);
  //         final audioUrl = await storageRef.getDownloadURL();
  //         // Set metadata to avoid null issues
  //
  //         // Format the duration in minutes and seconds
  //         // String formattedDuration = _formatDuration(_recordingDuration ?? Duration.zero);
  //
  //
  //         // Create an audio message with the download URL
  //         final message2 = types.PartialFile(
  //           name: 'voice_message.wav',
  //           size: await audioFile.length(),
  //           uri: audioUrl,  // Send the URL from Firebase Storage
  //           metadata: {
  //             // 'duration': formattedDuration,  // Store formatted duration in metadata
  //             'raw_duration': duration,  // Store raw duration in seconds
  //           },
  //
  //         );
  //
  //
  //         // Send the message automatically
  //         try {
  //           FirebaseChatCore.instance.sendMessage(message2, widget.room.id);
  //           // print('Voice message sent successfully.');
  //         } catch (e) {
  //           // print('Error sending voice message: $e');
  //         }
  //       } else {
  //         // print('Audio file does not exist at: ${audioFile.path}');
  //       }
  //     } else {
  //       // print('Recording stopped without a valid path.');
  //     }
  //     setState(() {
  //       _isRecording = false;
  //     });
  //   } else {
  //     final directory = await getApplicationDocumentsDirectory();
  //     await _recorder.start(
  //       const RecordConfig(),
  //       path: '${directory.path}/voice_message.wav',
  //     );
  //     setState(() {
  //       _isRecording = true;
  //     });
  //   }
  // }


  Future<String> getUserLanguage(String userId) async {
    try {
      // Fetch the user's document from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (doc.exists) {
        // Check if the 'metadata' field exists and contains the 'language' key
        final data = doc.data();
        if (data != null && data.containsKey('metadata') && data['metadata'] != null) {

          final metadata = data['metadata'] as Map<String, dynamic>;
          print("language: " + data['metadata']  );
          return metadata['language'] ?? 'English'; // Default to English if not set
        }

        // Fallback to top-level 'language' key if 'metadata.language' is not present
        // return data['language'] ?? 'English'; // Default to English if not set
      }
    } catch (e) {
      print('Error fetching user language: $e');
    }

    // Default to English if something goes wrong
    return 'English';
  }

  Future<void> _sendVoiceMessage() async {
    if (_isRecording) {
      _recordingStartTime = DateTime.now();
      final path = await _recorder.stop();
      if (path != null) {
        final File audioFile = File(path);
        final recordingEndTime = DateTime.now();
        final duration = recordingEndTime.difference(_recordingStartTime!).inSeconds;

        if (await audioFile.exists()) {
          setState(() {
            _isRecording = false;
          });

          // Upload the original audio file to Firebase Storage
          final originalStorageRef = FirebaseStorage.instance
              .ref()
              .child('audio_messages')
              .child('${DateTime.now().millisecondsSinceEpoch}_original.wav');

          final metadata = SettableMetadata(contentType: 'audio/wav');
          await originalStorageRef.putFile(audioFile, metadata);
          final originalAudioUrl = await originalStorageRef.getDownloadURL();

          dynamic apiURL="";
          if(user_language=="English"){
            apiURL='https://api.signvista.online/english-to-german-audio/';
          }
          else{
            apiURL='https://api.signvista.online/german-to-english-audio/';
          }




           final request = http.MultipartRequest(
              'POST',
              Uri.parse(apiURL),
            );
            request.files.add(
              await http.MultipartFile.fromPath(
                'file',
                audioFile.path,
                contentType: MediaType('audio', 'wav'),
              ),
            );


          final response = await request.send();

          if (response.statusCode == 200) {
            print("good yaar");

            // Save response body as a file
            final bytes = await response.stream.toBytes(); // Correct way to handle binary data
            final translatedFile = File('${audioFile.parent.path}/translated_german.wav');
            await translatedFile.writeAsBytes(bytes); // Write bytes to file

            // Upload the translated audio file to Firebase Storage
            final translatedStorageRef = FirebaseStorage.instance
                .ref()
                .child('audio_messages')
                .child('${DateTime.now().millisecondsSinceEpoch}_translated.wav');

            await translatedStorageRef.putFile(translatedFile, metadata);
            final translatedAudioUrl = await translatedStorageRef.getDownloadURL();

            // Create an audio message with both URLs in metadata
            final message2 = types.PartialFile(
              name: 'voice_message.wav',
              size: await audioFile.length(),
              uri: originalAudioUrl,
              metadata: {
                'language': user_language,
                'raw_duration': duration,
                'translated_audio_url': translatedAudioUrl,

              },
            );

            // Send the message automatically
            try {
              FirebaseChatCore.instance.sendMessage(message2, widget.room.id);
            } catch (e) {
              print('Error sending voice message: $e');
            }
          } else {
            print('Error translating audio: ${response.statusCode}');
          }


          // if (response.statusCode == 200) {
          //   print("good yaar");
          //   final responseBody = await response.stream.bytesToString();
          //   final translatedFile = File('${audioFile.parent.path}/translated_german.wav');
          //   translatedFile.writeAsBytesSync(responseBody.codeUnits);
          //
          //   // Upload the translated audio file to Firebase Storage
          //   final translatedStorageRef = FirebaseStorage.instance
          //       .ref()
          //       .child('audio_messages')
          //       .child('${DateTime.now().millisecondsSinceEpoch}_translated.wav');
          //
          //   await translatedStorageRef.putFile(translatedFile, metadata);
          //   final translatedAudioUrl = await translatedStorageRef.getDownloadURL();
          //
          //   // Create an audio message with both URLs in metadata
          //   final message2 = types.PartialFile(
          //     name: 'voice_message.wav',
          //     size: await audioFile.length(),
          //     uri: originalAudioUrl,
          //     metadata: {
          //       'raw_duration': duration,
          //       'translated_audio_url': translatedAudioUrl,
          //     },
          //   );
          //
          //   // Send the message automatically
          //   try {
          //     FirebaseChatCore.instance.sendMessage(message2, widget.room.id);
          //   } catch (e) {
          //     print('Error sending voice message: $e');
          //   }
          // } else {
          //   print('Error translating audio: ${response.statusCode}');
          // }
        } else {
          print('Audio file does not exist at: ${audioFile.path}');
        }
      } else {
        print('Recording stopped without a valid path.');
      }
      setState(() {
        _isRecording = false;
      });
    } else {
      final directory = await getApplicationDocumentsDirectory();
      await _recorder.start(
        const RecordConfig(),
        path: '${directory.path}/voice_message.wav',
      );
      setState(() {
        _isRecording = true;
      });
    }
  }




  Future<void> _sendPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict file picker to PDF files
    );

    if (result != null) {
      final path = result.files.single.path; // Get the selected file path
      if (path != null) {
        final File pdfFile = File(path);

        // Create a reference in Firebase Storage for the PDF
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('pdf_files')
            .child('${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}');

        final metadata = SettableMetadata(
          contentType: 'application/pdf', // Set appropriate content type
        );

        try {
          // Upload the PDF file to Firebase Storage
          await storageRef.putFile(pdfFile, metadata);

          // Get the download URL for the uploaded PDF
          final pdfUrl = await storageRef.getDownloadURL();

          // Create a message with the PDF file information
          final message = types.PartialFile(
            name: result.files.single.name, // File name
            size: pdfFile.lengthSync(), // File size
            uri: pdfUrl, // Download URL
            metadata: {
              'type': 'pdf', // Custom metadata (optional)
            },
          );

          // Send the message
          FirebaseChatCore.instance.sendMessage(message, widget.room.id);

          // Optional: Show a success message
          print('PDF sent successfully!');
        } catch (e) {
          // Handle upload or send errors
          print('Error uploading or sending PDF: $e');
        }
      } else {
        print('No file path found.');
      }
    } else {
      print('File selection canceled.');
    }
  }


  // Future<void> _sendPdfFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //   );
  //
  //   if (result != null) {
  //     final path = result.files.single.path;
  //     if (path != null) {
  //       final File pdfFile = File(path);
  //
  //       final message = types.PartialFile(
  //         name: result.files.single.name,
  //         size: pdfFile.lengthSync(),
  //         uri: pdfFile.uri.toString(),
  //       );
  //       FirebaseChatCore.instance.sendMessage(message, widget.room.id);
  //     }
  //   }
  // }

  @override
  void dispose() {
    _recorder.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: kPrimaryColor),
            onPressed: () => _sendMessage(context),
          ),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: kPrimaryColor,
            ),
            onPressed: _sendVoiceMessage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: kPrimaryColor),
            onPressed: _sendPdfFile,
          ),
        ],
      ),
    );
  }
}



