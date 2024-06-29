import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/views/auth/sign_up.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/project/util/validate.dart';
import 'package:localstorage/localstorage.dart';
import '../../constants/app_style.dart';
import '../home/home.dart';


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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _isObscure = true;
  ApiRequest apiRequest=ApiRequest();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  late Map<String, dynamic> query = {
    "url": "http://localhost:8080/user-tokens",
    "body":{
      "email": _emailController.text.trim(),
      "password":_passwordController.text.trim()
    }
  };

  void _fetchToken() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        query = {
          "url": "http://localhost:8080/user-tokens",
          "body":{
            "email": _emailController.text.trim(),
            "password":_passwordController.text.trim()
          }
        };
      });
      await apiRequest.postRequest(query).then((response) {
        if (response.data["code"] == "200") {
          localStorage.setItem('token', response.data["data"]);
          _showDialog('Successfully signed in.');
        } else {
          _showDialog(response.data["msg"]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const SizedBox(height: 60),
                    Image.asset('assets/logo2.png', height: 100),
                    const Text('Simplifying Outdoor Fun in Vancouver.', style: AppStyle.sloganFont),
                    // Email Input Box
                    TextFormField(
                      controller: _emailController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validator.validateEmail(value),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(130, 130, 130,
                              1), // Color of the label when not focused
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

                    ),

                    // Password Input Box
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        return Validator.validatePassword(value);
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1),
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
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Color.fromRGBO(130, 130, 130, 1),
                          ),
                          onPressed: () {
                            // To modify the internal variables of state and update the interface content
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                    ),

                    // "Sign In" Button
                    TextButton(
                      onPressed: () async {
                        _fetchToken();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppStyle.buttonForegroundColor,
                        elevation: 2,
                        backgroundColor: AppStyle.buttonBackgroundColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Sign In', style: AppStyle.bigButtonFont),
                    ),

                    // "Sign Up" Button
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
                          borderRadius: BorderRadius.circular(10),
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

  // Successful Login Notification
  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Notification"),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              if(message=='Successfully signed in.') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                      (Route<dynamic> route) => false,
                );
              }else{
                _emailController.text = '';
                _passwordController.text = '';
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

