import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/error/firebaseauth_exception_error_extension.dart';
import 'package:study_buddy/error/login_response.dart';
import 'package:study_buddy/structure/messaging/message_api.dart';
import 'package:study_buddy/structure/models/user_model.dart';
import 'package:study_buddy/structure/services/university_service.dart';

class AuthService {
  // instance of Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessage _firebaseMessage = FirebaseMessage();
  final UniversityInfo _universityInfo = UniversityInfo();
  // signin
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // add a new document for users in user collection if it does not already exist
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  // signup
  Future<LoginResponse> signUpWithEmailPassword(
    BuildContext context,
    String email,
    String password,
    String firstName,
    String lastName,
    String university,
    String universityId,
    String emailDomain,
    List<String> domains,
  ) async {
    try {
      if (!domains.contains(emailDomain)) {
        // Email does not match the required domain
        await signOut(); // Sign out the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('There is no domain match'),
          ),
        );
        // Return null to indicate failed sign-in attempt
        return LoginResponse(
            isSuccess: false, message: "There is no domain match");
      }
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email + emailDomain,
        password: password,
      );

      final fcmtoken = await _firebaseMessage.getFCMToken();
      UserModel newUserData = UserModel(
        uid: userCredential.user!.uid,
        name: Name(firstName: firstName, lastName: lastName),
        email: email + emailDomain,
        fcmtoken: fcmtoken.toString(),
        imageUrl: userCredential.user!.photoURL.toString(),
        university: university,
        universityId: universityId,
      );

      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUserData.toMap());
      return LoginResponse(isSuccess: true, message: null);
    } on FirebaseAuthException catch (e) {
      return LoginResponse(isSuccess: false, message: e.getErrorMessage());
    }
  }

  // signout
  Future<void> signOut() async {
    await _auth.signOut();
    // sign out from Google
    await GoogleSignIn().signOut();
  }

  // reset password
  Future passwordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message.toString());
    }
  }

// signin with Google account
  Future<UserCredential?> signInWithGoogle(
      BuildContext context, List<String> domains) async {
    try {
      // Begin interactive signin process
      final GoogleSignInAccount? guser = await GoogleSignIn().signIn();

      if (guser != null) {
        // Obtain auth details from request
        final GoogleSignInAuthentication gAuth = await guser.authentication;

        // Create a new credential for user
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        // Sign in with Google
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Get the user's email domain
        final userEmail = userCredential.user!.email!;
        final userDomain = userEmail.split('@').last;

        // Check if the user's domain is in the list of allowed domains
        if (!domains.contains("@$userDomain")) {
          // Email domain is not allowed
          await signOut(); // Sign out the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email domain is not allowed.'),
            ),
          );
          return null; // Return null to indicate failed sign-in attempt
        } else {
          final uni = await _universityInfo.getUniversityId("@$userDomain");
          print("UNIVERSITY ID: $uni");
          final fcmtoken = await _firebaseMessage.getFCMToken();

          // get the uniId where the domain belongs to

          // Add user to Firestore

          await _firestore.collection('institution').doc(uni).update({
            'students': FieldValue.arrayUnion([userCredential.user!.uid]),
          });
          await _firestore
              .collection('institution')
              .doc(uni)
              .collection("students")
              .doc(userCredential.user!.uid)
              .set(
            {
              'uid': userCredential.user!.uid,
              'email': userCredential.user!.email,
              'name': userCredential.user!.displayName,
              'imageUrl': userCredential.user!.photoURL,
              'fcmtoken': fcmtoken,
            },
          );

          return userCredential;
        }
      }
    } catch (error) {
      print(error);
      return null;
    }
    return null;
  }
}
