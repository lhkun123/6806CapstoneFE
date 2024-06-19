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
  State<SignInHttp> createState() => _SignInHttpState();
}

class _SignInHttpState extends State<SignInHttp> {
  FormData formData = FormData();
  late bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('  '),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  ...[
                    const SizedBox(height: 100),
                    const Text('VanLife', style: AppStyle.hugeHeadingFont),
                    const Text('Simplifying Outdoor Fun in Vancouver.', style: AppStyle.sloganFont),
                    TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validator.validateEmail(value),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1), // Color of the label when not focused
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(130, 130, 130, 1)),
                        ),
                        // Focused border when the TextField is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(130, 130, 130, 1), width: 1.5),
                        ),
                        errorStyle: AppStyle.errorFont
                      ),
                      onChanged: (value) {
                        formData.email = value;
                      },
                    ),
                    TextFormField(
                      obscureText: _isObscure, // 是否显示文字
                      onChanged: (value) {
                        formData.password = value;
                      },
                      validator: (value) {
                        return Validator.validatePassword(value);
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1), // Color of the label when not focused
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(130, 130, 130, 1)),
                        ),
                        // Focused border when the TextField is focused
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(130, 130, 130, 1), width: 1.5),
                        ),
                        errorStyle: AppStyle.errorFont,
                        suffixIcon: IconButton(
                          icon: _isObscure ? const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Color.fromRGBO(130, 130, 130, 1),
                            ) : const Icon(
                              Icons.remove_red_eye,
                              color: Color.fromRGBO(130, 130, 130, 1),
                            ),
                          onPressed: () {
                            // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _showDialog(switch (200) {
                            200 => 'Successfully signed in.',
                            401 => 'Unable to sign in.',
                            _ => 'Something went wrong. Please try again.'
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppStyle.buttonForegroundColor,
                        elevation: 2,
                        backgroundColor: AppStyle.buttonBackgroundColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 设置按钮的圆角半径
                        ),
                      ),
                      child: const Text('Sign In', style: AppStyle.bigButtonFont),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignUpHttp(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppStyle.buttonForegroundColor,
                        elevation: 2,
                        backgroundColor: AppStyle.buttonBackgroundColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 设置按钮的圆角半径
                        ),
                      ),
                      child: const Text('Sign Up', style: AppStyle.bigButtonFont),
                    ),
                  ].expand(
                        (widget) => [
                      widget,
                      const SizedBox(
                        height: 18,
                      )
                    ],
                  )
                ],
              ),
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
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
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
