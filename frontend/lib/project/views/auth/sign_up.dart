import 'package:flutter/cupertino.dart';
import 'package:frontend/project/views/auth/sign_in.dart';
import 'package:flutter/material.dart';

import '../../constants/api_request.dart';
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
  ApiRequest apiRequest=ApiRequest();
  late Map<String, dynamic> query = {
    "url": "http://localhost:8080/users",
    "body":{
      "email": _emailController.text.trim(),
      "password":_passwordController.text.trim()
    }
  };
  void _register() async {
    await apiRequest.postRequest(query).then((response) {
      print(response.data);
      if (response.data["msg"] == "Success!") {
        _showDialog('You have been successfully registered as a new user');
      }else{
        _showDialog(response.data["msg"]);
      }
    });

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
            style: AppStyle.barHeadingFont2,
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 150.0),
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
                      _register();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppStyle.primaryColor,
                    elevation: 2,
                    backgroundColor: AppStyle.barBackgroundColor,
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

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Notification"),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              if(message=='You have benn successfully registered as a new user') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInHttp()),
                      (Route<dynamic> route) => false,
                );
              }else{
                _emailController.text = '';
                _passwordController.text = '';
                _confirmPasswordController.text='';
                Navigator.of(context).pop();
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
