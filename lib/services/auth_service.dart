import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ Google Sign-In: User canceled the sign-in process");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, else create new entry
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "uid": userCredential.user!.uid,
          "name": userCredential.user!.displayName ?? "No Name",
          "email": userCredential.user!.email,
          "profilePic": userCredential.user!.photoURL ?? "",
          "createdAt": DateTime.now(),
        });
      }

      print("✅ Google Sign-In successful: ${userCredential.user!.uid}");
      return userCredential.user;
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return null;
    }
  }

  // 🔹 Email/Password Signup
  Future<User?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid, // Add UID for consistency
        "name": name,
        "email": email,
        "profilePic": "",
        "progress": {
          "tamilLessons": [],
        },
        "createdAt": DateTime.now(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.message}");
      return null;
    } on FirebaseException catch (e) {
      print("❌ Firestore Error: ${e.message}");
      return null;
    } catch (e) {
      print("❌ Signup Error: $e");
      return null;
    }
  }

  // 🔹 Email/Password Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("❌ Login Error: $e");
      return null;
    }
  }

  // 🔹 Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("❌ Logout Error: $e");
    }
  }
}
