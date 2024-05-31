import 'package:flutter/cupertino.dart';
import 'package:frontend/project/views/auth/sign_in.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import '../../util/validate.dart';
@JsonSerializable()
class FormData {
  String? email;
  String? password;


  FormData({
    this.email,
    this.password,
  });

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}


class SignUpHttp extends StatefulWidget {
  const SignUpHttp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpHttp> {

  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String? password;
  String? confirmPassword;

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
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.black, // Color of the label when not focused
                        ),
                      ),

                      validator: (value) => Validator.validateEmail(value),
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.black, // Color of the label when not focused
                        ),
                      ),
                      obscureText: true,
                      validator: (value) => Validator.validatePassword(value),
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    TextFormField(
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
                      onChanged: (value) {
                        setState(() => confirmPassword = value);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                    child: const Text('Register'),
                    onPressed: () async {
                      if (Validator.validatePasswordsMatch(confirmPassword,password)!=null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                            const SnackBar(content: Text('Passwords do NOT match!')));
                      }
                      else{
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInHttp()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    }),
                    const SizedBox(height: 12.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
FormData _$FormDataFromJson(Map<String, dynamic> json) {
  return FormData(
    email: json['email'] as String?,
    password: json['password'] as String?,
  );
}

Map<String, dynamic> _$FormDataToJson(FormData instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
};
