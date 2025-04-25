import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:global_talk_app/constants.dart';
import 'package:global_talk_app/screens/chats/chats_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          // User is not signed in, show the sign-in screen
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/global_talk.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to Global Talk, please sign in!')
                    : const Text('Welcome to Global Talk, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/global_talk.png'),
                ),
              );
            },
          );
        } else {
          // User is signed in, check if user profile exists
          final User user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // Wrap async operations inside a Future
                return FutureBuilder<void>(
                  future: _createUserProfile(user),
                  builder: (context, _) {
                    if (_.connectionState == ConnectionState.waiting) {

                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),

                      );
                    }
                    // After user creation, navigate to the ChatsScreen

                    return const ChatsScreen();
                  },
                );
              }

              // User profile exists, navigate to ChatsScreen
              return const ChatsScreen();
            },
          );
        }
      },
    );
  }

  Future<void> _createUserProfile(User user) async {
    // Create user profile in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'username': user.email?.split('@')[0] ?? '',
      'gender': '',
      'language': '',
      'email': user.email ?? '',
    });

    // Create user in FirebaseChatCore
    await FirebaseChatCore.instance.createUserInFirestore(
      types.User(
        firstName: user.email?.split('@')[0] ?? '',
        id: user.uid, // UID from Firebase Authentication
        imageUrl: 'https://i.pravatar.cc/300',
      ),
    );
  }
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