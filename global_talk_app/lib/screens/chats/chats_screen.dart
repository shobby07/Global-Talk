import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../profile/profile_screen.dart';
import 'components/body.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _selectedIndex = 0; // Set initial index to 0 (Chats)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: const Body(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: kPrimaryColor,
      //   child: const Icon(
      //     Icons.person_add_alt_1,
      //     color: Colors.white,
      //   ),
      // ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
          // Within your BottomNavigationBar's onTap handler
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomProfileScreen(),
              ),
            ).then((_) {
              setState(() {
                _selectedIndex = 0;
              });
            });
          }
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.messenger),
          label: "Chats",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: kPrimaryColor,
      automaticallyImplyLeading: false,
      title: const Text("Chats"),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    );
  }
}
