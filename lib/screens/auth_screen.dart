import 'dart:io';

import 'package:chat/utils/firebase_error_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginModel = true;
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _email;
  late String _password;
  bool _isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void onSelectImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  void onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLoginModel && _selectedImage == null) {
      showMessage("Please select an image.");
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseAuth = FirebaseAuth.instance;

      if (_isLoginModel) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        showMessage('Login Successfully');
      } else {
        final userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: _email, password: _password);

        await userCredential.user!.updateDisplayName(_name);
        await userCredential.user!.reload();

        final user = userCredential.user;
        if (user == null) {
          throw Exception("User is null");
        }

        final userId = user.uid;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'id': userId,
          'name': _name,
          'email': _email,
        });

        showMessage('Signup Successfully');
      }
    } on FirebaseAuthException catch (e) {
      showMessage(getFirebaseAuthMessage(e));
    } on FirebaseException catch (e) {
      if (e.plugin == 'cloud_firestore') {
        showMessage(getFirestoreMessage(e));
      } else {
        showMessage("Something went wrong.");
      }
    } catch (e) {
      showMessage('Something Went Wrong');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Image.asset('assets/images/chat.png', width: 250),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: .all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: .circular(12),
                    ),
                    child: Column(
                      children: [
                        if (!_isLoginModel) ...[
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : null,
                                child: _selectedImage == null
                                    ? Icon(Icons.person, size: 35)
                                    : null,
                              ),
                              TextButton.icon(
                                onPressed: onSelectImage,
                                icon: Icon(Icons.image),
                                label: Text('Add Image'),
                              ),
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              label: Text('Name'),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name should not be null';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _name = newValue!;
                            },
                          ),
                        ],
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            label: Text('Email'),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email should not be null';
                            }
                            if (!value.contains('@')) {
                              return 'Email must be valid';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _email = newValue!;
                          },
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            label: Text('Password'),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.length < 5) {
                              return 'Password should be at least 6 character.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _password = newValue!;
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: onSave,
                          child: _isLoading
                              ? SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(),
                                )
                              : Text(_isLoginModel ? 'Login' : 'Signup'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginModel = !_isLoginModel;
                            });
                          },
                          child: Text(
                            _isLoginModel
                                ? 'Create an Account'
                                : 'I already have an account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
