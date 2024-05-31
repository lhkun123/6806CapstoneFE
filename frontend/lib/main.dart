import 'package:flutter/material.dart';
import 'package:frontend/project/views/auth/sign_up.dart';
import 'package:frontend/project/views/home/home.dart';
import 'project/views/auth/sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        initialRoute:"/signin", //名为"/"的路由作为应用的home(首页)
        //注册路由表

        routes:{
          "/signin":(context) => const SignInHttp(), //注册首页路由
          "/signup":(context)=> const SignUpHttp(),
          "/home":(context)=>const Home()
        }
    );
  }
}
