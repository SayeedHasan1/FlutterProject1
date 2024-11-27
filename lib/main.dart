import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertest23/Views/login_view.dart';
import 'package:fluttertest23/Views/register_view.dart';
import 'package:fluttertest23/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePgage(),
    ),
  );
}

class HomePgage extends StatelessWidget {
  const HomePgage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            
            if(user?.emailVerified ?? false){
              print("You are email verified.");
            }
            else{
              print("you are not email verified.");
            }
              return const Text("Done");
            default:
              return const Text('Loading');
          }
        },
      ),
    );
  }
}
