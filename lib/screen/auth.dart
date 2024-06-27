import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _from = GlobalKey<FormState>();
  var _entryEmail = "";
  var _entryPassword = "";
  bool _isVisible = true;
  File? _selectedImage;
  bool _isAuthenticating = false;

  Future<void> _submit() async {
    final isValid = _from.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin
              ? "Invalid email or password"
              : isValid
                  ? "Please pick an image"
                  : "Please add email and password"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    _from.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _entryEmail,
          password: _entryPassword,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _entryEmail,
          password: _entryPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredentials.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication failed"),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset(
                  "assets/images/chat.png",
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _from,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (image) {
                                _selectedImage = image;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Email"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _entryEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "Password",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isVisible = !_isVisible;
                                      });
                                    },
                                    icon: Icon(_isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off))),
                            obscureText: _isVisible,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.length < 6) {
                                return "password must be 6 characters long";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _entryPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.login),
                              onPressed: _submit,
                              label: Text(_isLogin ? "Login" : "sign up"),
                            ),
                          if (!_isAuthenticating)
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              label: Text(_isLogin
                                  ? "Create new account"
                                  : "Already have an account"),
                              icon: const Icon(Icons.person_2_outlined),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
