import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:global_talk_app/screens/chats/chats_screen.dart';
import 'package:global_talk_app/screens/signinOrSignUp/auth_gate.dart';
import '../../constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen for auth changes
      builder: (context, snapshot) {
        // While waiting for the authentication state, show a loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the user is signed in, navigate to the ChatsScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const ChatsScreen(); // Redirect to ChatsScreen if user is signed in
        }

        // If the user is not signed in, show the WelcomeScreen
        return _buildWelcomeScreen(context);
      },
    );
  }

  // Method to build the actual WelcomeScreen UI
  Widget _buildWelcomeScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.asset("assets/images/welcome_image.png"),
            const Spacer(flex: 3),
            Text(
              "Welcome to our Global Talk \nmessaging app",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              "Global talk any person of any \n language.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.64),
              ),
            ),
            const Spacer(flex: 3),
            FittedBox(
              child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthGate(),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Skip",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding / 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.8),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}



