import 'dart:io';

import 'package:chat/cubits/auth_state.dart';
import 'package:chat/utils/firebase_error_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthSuccess(message: 'Login Successfully'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: getFirebaseAuthMessage(e)));
    } catch (_) {
      emit(AuthError(message: 'Something went wrong'));
    }
  }

  void signup({
    required String name,
    required String email,
    required String password,
    required File image,
  }) async {
    emit(AuthLoading());
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user == null) throw Exception();

      await user.updateDisplayName(name);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/profile')
          .child('${user.uid}.jpg');

      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(imageUrl);
      await user.reload();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': name,
        'email': email,
        'image_url': imageUrl,
      });

      emit(AuthSuccess(message: 'Signup Successfully'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: getFirebaseAuthMessage(e)));
    } on FirebaseException catch (e) {
      if (e.plugin == 'cloud_firestore') {
        emit(AuthError(message: getFirestoreMessage(e)));
      } else {
        emit(AuthError(message: 'Something went wrong.'));
      }
    } catch (_) {
      emit(AuthError(message: 'Something went wrong'));
    }
  }
}
