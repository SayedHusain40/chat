import 'dart:io';

import 'package:chat/cubits/auth_cubit.dart';
import 'package:chat/cubits/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    final authCubit = context.read<AuthCubit>();

    if (_isLoginModel) {
      authCubit.login(email: _email, password: _password);
    } else {
      authCubit.signup(
        name: _name,
        email: _email,
        password: _password,
        image: _selectedImage!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showMessage(state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    Image.asset('assets/images/chat.png', width: 250),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const .all(13),
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
                                        ? const Icon(Icons.person, size: 35)
                                        : null,
                                  ),
                                  TextButton.icon(
                                    onPressed: onSelectImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text('Add Image'),
                                  ),
                                ],
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
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
                            const SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
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
                              decoration: const InputDecoration(
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
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: state is AuthLoading ? null : onSave,
                              child: state is AuthLoading?
                                  ? const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(_isLoginModel ? 'Login' : 'Signup'),
                            ),
                            TextButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
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
          );
        },
      ),
    );
  }
}
