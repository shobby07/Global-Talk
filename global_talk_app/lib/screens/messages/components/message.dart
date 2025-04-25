import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';
import 'audio_message.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class Message extends StatelessWidget {
  final types.Message message;

  const Message({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Handle text message
    if (message is types.TextMessage) {
      return _buildTextMessage(message as types.TextMessage);
    }

    // Handle image message
    if (message is types.ImageMessage) {
      return _buildImageMessage(message as types.ImageMessage);
    }
    else if (message is types.FileMessage ) {
      // Check if it's an audio file (you can use metadata to ensure it's an audio file)
      // return _buildAudioMessage(message as types.FileMessage); correct
      // return AudioMessage(message: message as types.FileMessage);

      final fileMessage = message as types.FileMessage;
      // Check if the file is a PDF
      if (fileMessage.name.endsWith('.pdf')) {
        return _buildPdfMessage(fileMessage);
      } else {
        return _buildAudioMessage(fileMessage);
      }

    }

    // Handle other message types
    // Add more cases for audio, video, etc., as needed
    return const SizedBox.shrink(); // Placeholder for unhandled message types
  }

  // Widget _buildTextMessage(types.TextMessage message) {
  //
  //   Map<String, String> result = extractMessageAndLanguage(message.text);
  //   var language = result['language'];
  //   var message_text = result['message'];
  //
  //   if (language != user_language) {
  //     if (language == "German") {
  //       message_text = await translateText(message_text!);
  //     }
  //   }
  //
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
  //     child: Row(
  //       mainAxisAlignment: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
  //           ? MainAxisAlignment.end
  //           : MainAxisAlignment.start,
  //       children: [
  //         if (message.author.id != FirebaseChatCore.instance.firebaseUser?.uid)
  //            CircleAvatar(
  //             backgroundImage: message.author.imageUrl != null && message.author.imageUrl!.isNotEmpty
  //                 ? NetworkImage(message.author.imageUrl!)
  //                 : const AssetImage("assets/images/user_2.png") as ImageProvider, // Fallback to asset if no image URL
  //             radius: 12,
  //           ),
  //         const SizedBox(width: kDefaultPadding / 2),
  //         Container(
  //           padding: const EdgeInsets.symmetric(
  //             horizontal: kDefaultPadding * 0.75,
  //             vertical: kDefaultPadding / 2,
  //           ),
  //           decoration: BoxDecoration(
  //             color: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
  //                 ? kPrimaryColor
  //                 : kPrimaryColor.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           child: Text(
  //             message.text,
  //             style: TextStyle(
  //               color: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
  //                   ? Colors.white
  //                   : Colors.blueAccent,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTextMessage(types.TextMessage message) {
    // Extract message and language
    Map<String, String> result = extractMessageAndLanguage(message.text);
    var language = result['language'];
    var messageText = result['message'];

    print("geo");
    // Check if translation is needed
    if (language != user_language && message.author.id != FirebaseChatCore.instance.firebaseUser?.uid ) {
      print("geo1");
      // Use FutureBuilder to handle translation asynchronously
      return FutureBuilder<String>(
        future: translateText(messageText!, language),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Show loading indicator while waiting
            );
          }

          if (snapshot.hasError) {
            return Text(
              'Error translating message',
              style: const TextStyle(color: Colors.red),
            );
          }

          // Use the translated text
          final translatedText = snapshot.data ?? messageText;

          return _buildMessageBubble(message, translatedText);
        },
      );
    }

    // No translation needed, display the message as is
    return _buildMessageBubble(message, messageText!);
  }

  Widget _buildMessageBubble(types.TextMessage message, String messageText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      child: Row(
        mainAxisAlignment: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.author.id != FirebaseChatCore.instance.firebaseUser?.uid)
            CircleAvatar(
              backgroundImage: message.author.imageUrl != null && message.author.imageUrl!.isNotEmpty
                  ? NetworkImage(message.author.imageUrl!)
                  : const AssetImage("assets/images/user_2.png") as ImageProvider,
              radius: 12,
            ),
          const SizedBox(width: kDefaultPadding / 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 0.75,
              vertical: kDefaultPadding / 2,
            ),
            decoration: BoxDecoration(
              color: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
                  ? kPrimaryColor
                  : kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              messageText,
              style: TextStyle(
                color: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
                    ? Colors.white
                    : Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildImageMessage(types.ImageMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      child: Row(
        mainAxisAlignment: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.author.id != FirebaseChatCore.instance.firebaseUser?.uid)
            const CircleAvatar(
              backgroundImage: AssetImage("assets/images/user_2.png"),
              radius: 12,
            ),
          const SizedBox(width: kDefaultPadding / 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              message.uri,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(types.FileMessage message) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        getUserLanguage(message.author.id), // Fetch sender's language
        getUserLanguage(FirebaseChatCore.instance.firebaseUser?.uid ?? ''), // Fetch receiver's language
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Text('Error fetching languages'); // Handle errors
        }

        final senderLanguage = snapshot.data![0];
        final receiverLanguage = snapshot.data![1];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
          child: Row(
            mainAxisAlignment: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (message.author.id != FirebaseChatCore.instance.firebaseUser?.uid)
                CircleAvatar(
                  backgroundImage: message.author.imageUrl != null && message.author.imageUrl!.isNotEmpty
                      ? NetworkImage(message.author.imageUrl!)
                      : const AssetImage("assets/images/user_2.png") as ImageProvider,
                  radius: 12,
                ),
              const SizedBox(width: kDefaultPadding / 2),
              Container(
                decoration: BoxDecoration(
                  color: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
                      ? Colors.green
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: AudioMessage(message: message, colors: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid?  Colors.green: Colors.blueAccent),
                // child: AudioMessage(
                //   audioUrl: message.uri,
                //   senderLanguage: senderLanguage,
                //   receiverLanguage: receiverLanguage,
                //   colors: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
                //       ? Colors.green
                //       : Colors.blueAccent,
                // ),
              ),
            ],
          ),
        );
      },
    );
  }


  // Widget _buildAudioMessage(types.FileMessage message) {
  //
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
  //     child: Row(
  //       mainAxisAlignment: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
  //           ? MainAxisAlignment.end
  //           : MainAxisAlignment.start,
  //       children: [
  //         if (message.author.id != FirebaseChatCore.instance.firebaseUser?.uid)
  //           CircleAvatar(
  //             backgroundImage: message.author.imageUrl != null && message.author.imageUrl!.isNotEmpty
  //                 ? NetworkImage(message.author.imageUrl!)
  //                 : const AssetImage("assets/images/user_2.png") as ImageProvider, // Fallback to asset if no image URL
  //             radius: 12,
  //           ),
  //         const SizedBox(width: kDefaultPadding / 2),
  //         // Using the existing AudioMessage widget
  //         Container(
  //           decoration: BoxDecoration(
  //             color: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
  //                 ? Colors.green
  //                 : Colors.green.withOpacity(0.1), // Custom colors for the bubble
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           child: AudioMessage(audioUrl: message.uri, senderLanguage: getUserLanguage(FirebaseChatCore.instance.firebaseUser?.uid),
  //             colors: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
  //                 ? Colors.green
  //                 : Colors.blueAccent ,), // AudioMessage widget
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> downloadAndOpenPdf(String url, String fileName) async {
    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Download PDF file
      final response = await Dio().download(url, filePath);
      print("downloaded");
      if (response.statusCode == 200) {
        // Open the file with an external PDF viewer
        await OpenFilex.open(filePath);
      } else {
        print('Failed to download PDF');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildPdfMessage(types.FileMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      child: Row(
        mainAxisAlignment: message.author.id == FirebaseChatCore.instance.firebaseUser?.uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.author.id != FirebaseChatCore.instance.firebaseUser?.uid)
            CircleAvatar(
              backgroundImage: message.author.imageUrl != null && message.author.imageUrl!.isNotEmpty
                  ? NetworkImage(message.author.imageUrl!)
                  : const AssetImage("assets/images/user_2.png") as ImageProvider,
              radius: 12,
            ),
          const SizedBox(width: kDefaultPadding / 2),
          GestureDetector(
            onTap: () async {
              // Moeez needs to replace this with message.uri from database after he has implemented it corectly
              downloadAndOpenPdf(message.uri, message.name);

            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.75,
                vertical: kDefaultPadding / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    message.name.length>20? message.name.substring(0,20):message.name,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Map<String, String> extractMessageAndLanguage(String message) {
    if (message.contains("///")) {
      // Split the message at "///"
      List<String> parts = message.split("///");
      return {
        "message": parts[0], // The main message
        "language": parts[1], // The language code
      };
    }
    // If "///" is not found, return the original message and an empty language
    return {
      "message": message,
      "language": "",
    };
  }

  Future<String> translateText(String text, language) async {

    if(language=="English"){
    final url = Uri.parse('https://api.shoaibaziz.online/english-to-german-text/');

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'text': text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['german_sentence']; // Adjust key based on API response
      } else {
        throw Exception('Failed to translate. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return text; // Fallback to original text if translation fails
    }
    }
    else if(language=="German"){
      final url = Uri.parse('https://api.shoaibaziz.online/german-to-english-text/');

      try {
        final response = await http.post(
          url,
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'text': text,
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          return responseData['english_sentence']; // Adjust key based on API response
        } else {
          throw Exception('Failed to translate. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
        return text; // Fallback to original text if translation fails
      }
    }
    return text;

  }



}


