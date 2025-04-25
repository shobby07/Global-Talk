// import 'package:flutter/material.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
// import 'components/body.dart';
//
// class MessagesScreen extends StatelessWidget {
//   final types.Room room;
//
//   const MessagesScreen({super.key, required this.room});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAppBar(),
//       body: Body(room: room), // Pass the room to Body
//     );
//   }
//
//   AppBar buildAppBar() {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       title: const Row(
//         children: [
//           BackButton(),
//           CircleAvatar(
//             backgroundImage: AssetImage("assets/images/user_3.png"),
//           ),
//           SizedBox(width: 10), // Adjusted size
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Chat Room", // You can replace this with dynamic room/user names
//                 style: TextStyle(fontSize: 16),
//               ),
//               Text(
//                 "Active now", // Dynamic status can be handled
//                 style: TextStyle(fontSize: 12),
//               )
//             ],
//           )
//         ],
//       ),
//       actions: [
//         const SizedBox(width: 10),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'components/body.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:global_talk_app/constants.dart';
class MessagesScreen extends StatelessWidget {
  final types.Room room;

  const MessagesScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(room: room), // Pass the room to Body
    );
  }

  AppBar buildAppBar() {
    // Get the other user in the room (assuming a one-on-one chat)
    final otherUser = room.users.firstWhere((u) => u.id != FirebaseChatCore.instance.firebaseUser?.uid);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const BackButton(),
          CircleAvatar(
            backgroundImage: otherUser.imageUrl != null && otherUser.imageUrl!.isNotEmpty
                ? NetworkImage(otherUser.imageUrl!)
                : const AssetImage("assets/images/user_3.png") as ImageProvider, // Fallback to asset if no image URL
          ),
          const SizedBox(width: 10), // Adjusted size
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUser.firstName ?? "Chat Room", // Use the first name dynamically
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                otherUser.updatedAt != null
                    ? "Last seen at ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(otherUser.updatedAt!))} UTC"
                    // ? "Last seen at ${_formatUpdatedAt(otherUser.updatedAt!)}"
                    : "Unknown",
                style: const TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
      actions: const [
        SizedBox(width: 10),
      ],
    );
  }
  String _formatUpdatedAt(int updatedAt) {
    // Initialize timezones
    tz.initializeTimeZones();
    //Welcome image, Datetime and PDF implemented.

    // Get the Pakistan timezone
    final pakistan = tz.getLocation('Asia/Karachi');

    // Convert the updatedAt to DateTime in Pakistan timezone
    final dateTime = tz.TZDateTime.fromMillisecondsSinceEpoch(pakistan, updatedAt * 1000);

    // Format the date and time for display
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
    return formatter.format(dateTime) + ' PKT';
  }
}
