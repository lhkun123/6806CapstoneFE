import 'package:flutter/cupertino.dart';
import 'package:frontend/project/views/auth/sign_in.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import '../../constants/app_style.dart';

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
  bool loading = false;

  // text field state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController=TextEditingController();

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
              backgroundColor: AppStyle.barBackgroundColor,
              elevation: 0.0,
              title: const Text(
                'Sign up',
                style: AppStyle.barHeadingFont,
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.white, // 返回箭头的颜色
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 200.0),
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: AppStyle.systemGreyColor), // Color of the label when not focused
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppStyle.systemGreyColor),
                        ),
                        // Focused border when the TextField is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppStyle.systemGreyColor, width: 1.5),
                        ),
                        errorStyle: AppStyle.errorFont,
                      ),
                      validator: (value) => Validator.validateEmail(value),
                    ),
                    const SizedBox(height: 30.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: AppStyle.systemGreyColor), // Color of the label when not focused
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppStyle.systemGreyColor),
                        ),
                        // Focused border when the TextField is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppStyle.systemGreyColor, width: 1.5),
                        ),
                        errorStyle: AppStyle.errorFont,
                      ),
                      obscureText: true,
                      validator: (value) => Validator.validatePassword(value),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Retype the Password',
                        labelStyle: TextStyle(color: AppStyle.systemGreyColor), // Color of the label when not focused
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppStyle.systemGreyColor),
                        ),
                        // Focused border when the TextField is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppStyle.systemGreyColor, width: 1.5),
                        ),
                        errorStyle: AppStyle.errorFont,
                      ),
                      obscureText: true,
                      validator: (value) => Validator.validatePassword(value),

                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () async {
                        if (Validator.validatePasswordsMatch(_passwordController.text.trim(),_confirmPasswordController.text.trim())!=null) {
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
                      child: const Text('Register', style: AppStyle.bigButtonFont),
                    ),
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
