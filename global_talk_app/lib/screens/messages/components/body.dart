import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import '../../../constants.dart';
import 'message.dart';
import 'chat_input_field.dart';

class Body extends StatelessWidget {
  final types.Room room;

  const Body({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: FirebaseChatCore.instance.messages(room),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final messages = snapshot.data ?? [];

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Message(message: message); // Custom widget for message rendering
                },
              );
            },
          ),
        ),
        ChatInputField(room: room), // Input field for sending new messages
      ],
    );
  }
}
