import 'package:flutter/cupertino.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/views/auth/sign_in.dart';
import 'package:flutter/material.dart';

import '../../constants/app_style.dart';
import '../../util/validate.dart';



class SignUpHttp extends StatefulWidget {
  const SignUpHttp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpHttp> {

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController=TextEditingController();
  ApiRequest apiRequest=ApiRequest();
  late Map<String, dynamic> query = {
    "url": "http://localhost:8080/users",
    "body":{
      "email":_emailController.text.trim(),
      "password":_passwordController.text.trim()
    }
  };

  void _register() async {
    await apiRequest.postRequest(query).then((response) {
      _showDialog(switch (response.data["code"]) {
        "200" => 'Successfully registered as a new user',
      "500" => 'Unable to sign in.',
      _ => 'Something went wrong. Please try again.'
    });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: const Text('Sign up to this system'),
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.black, // Color of the label when not focused
                        ),
                      ),
                      validator: (value) => Validator.validateEmail(value),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.black, // Color of the label when not focused
                        ),
                      ),
                      obscureText: true,
                      validator: (value) => Validator.validatePassword(value),
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Retype the Password',
                        labelStyle: TextStyle(
                          color: Colors.black, // Color of the label when not focused
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        // Focused border when the TextField is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) => Validator.validatePassword(value),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                    child: const Text('Register'),
                    onPressed: () async {
                      if (Validator.validatePasswordsMatch(_passwordController.text.trim(),_confirmPasswordController.text.trim())!=null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                            const SnackBar(content: Text('Passwords do NOT match!')));
                      }
                      else{
                        _register();
                      }
                    }),
                  ],
                ),
              ),
            ),
          );
  }
  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Notification"),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              if(message=='Successfully registered as a new user') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInHttp()),
                      (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text(
              "OK",
              style: AppStyle.bodyTextFont,
            ),
          ),
        ],
        content: Text(
          message,
          style: AppStyle.bodyTextFont,
        ),
      ),
    );
  }
}
