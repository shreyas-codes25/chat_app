import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _from = GlobalKey<FormState>();
  var _entryEmail = "";
  var _entryPassword = "";

  Future<void> _submit() async {
    final isValid = _from.currentState!.validate();

    if (!isValid) {
      return;
    }
    _from.currentState!.save();

    try {
      if (_isLogin) {
        final _userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _entryEmail,
          password: _entryPassword,
        );
        print(_userCredentials);
      } else {
        final _userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _entryEmail,
          password: _entryPassword,
        );
        print(_userCredentials);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?? "Authentication failed"),
        ),
      );
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
                child: Image.asset("assets/images/chat.png"),
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
                            decoration: const InputDecoration(
                                labelText: "Password",
                                suffixIcon: Icon(Icons.remove_red_eye)),
                            obscureText: true,
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
                          ElevatedButton.icon(
                            icon: const Icon(Icons.login),
                            onPressed: _submit,
                            label: Text(_isLogin ? "Login" : "sign up"),
                          ),
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
