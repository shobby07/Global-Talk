import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'chat_card.dart';
import '../../messages/message_screen.dart';
import '../../../constants.dart';
import '../../../models/chat.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<types.User>>(
      stream: FirebaseChatCore.instance.users(),
      initialData: const [],
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Get the list of users
        final users = snapshot.data ?? [];

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding, 0, kDefaultPadding, kDefaultPadding),
              color: kPrimaryColor,
              child: Row(
                children: [
                  // FillOutlineButton(press: () {}, text: "Recent Message"),
                  // const SizedBox(width: kDefaultPadding),
                  // FillOutlineButton(
                  //   press: () {},
                  //   text: "Active",
                  //   isFilled: false,
                  // ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  print(users);
                  return ChatCard(
                    chat: Chat(
                      name: user.firstName ?? 'Unknown',
                      lastMessage: '', // Optionally, you can add logic to show the last message
                      time: '', // Add time formatting if available

                      image:  user.imageUrl ?? 'assets/images/user_3.png',
                      isActive: true ?? false,
                    ),
                    press: () => _handlePressed(user, context), // Call the new method here
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Create a user with an ID of UID if you don't use `FirebaseChatCore.instance.users()` stream
  void _handlePressed(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);
    print(room);

    // Navigate to the Chat screen, passing the room details if needed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesScreen(room: room), // Pass the room to MessagesScreen
      ),
    );
  }
}
