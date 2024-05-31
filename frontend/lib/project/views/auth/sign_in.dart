
// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/views/auth/sign_up.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/project/util/validate.dart';

import '../../constants/app_style.dart';
import '../home/home.dart';


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

class SignInHttp extends StatefulWidget {
  final http.Client? httpClient;

  const SignInHttp({
    this.httpClient,
    super.key,
  });

  @override
  State<SignInHttp> createState() => _SignInHttpDemoState();
}

class _SignInHttpDemoState extends State<SignInHttp> {
  FormData formData = FormData();
  late bool _isObscure=true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('  '),
      ),
      body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) => Validator.validateEmail(value),
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Email',
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
                    onChanged: (value) {
                      formData.email = value;
                    },
                  ),
              TextFormField(
                  obscureText: _isObscure, // 是否显示文字
                  onChanged: (value) {
                    formData.password=value;
                  },
                  validator: (value) {
                      return Validator.validatePassword(value);
                  },
                  decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(
                        color: Colors.black, // Color of the label when not focused
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      // Focused border when the TextField is focused
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ))),
                  TextButton(
                    child: const Text('Sign in'),
                    onPressed: () async {
                      // Use a JSON encoded string to send
                      // var result = await widget.httpClient!.post(
                      //     Uri.parse('https://example.com/signin'),
                      //     body: json.encode(formData.toJson()),
                      //     headers: {'content-type': 'application/json'});
                      _showDialog(switch (200) {
                        200 => 'Successfully signed in.',
                      401 => 'Unable to sign in.',
                      _ => 'Something went wrong. Please try again.'
                    });
                    },
                  ),
                  TextButton(
                    child: const Text('Sign up'),
                    onPressed: () =>Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpHttp(),
                      ),
                    ),
                  ),
                ].expand(
                      (widget) => [
                    widget,
                    const SizedBox(
                      height: 24,
                    )
                  ],
                )
              ],
            ),
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
          CupertinoDialogAction(onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
            );
          },
              child: const Text("OK",
              style:AppStyle.bodyTextFont
              )),
        ],
        content: const Text("Login Successful",
            style:AppStyle.bodyTextFont
        ),
      )
    );
  }
}
// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
