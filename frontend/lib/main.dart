import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/auth/sign_up.dart';
import 'package:frontend/project/views/home/home.dart';
import 'project/views/auth/sign_in.dart';
void main() => runApp(
  DevicePreview(
    builder: (context) => const MyApp(), // Wrap your app
  ),
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: const SignInHttp(), //作为应用的home(首页)
        theme: ThemeData(
          primaryColor: AppStyle.primaryColor,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.light,
          ),
        ),
        //注册路由表
        routes:{
          "/signin":(context) => const SignInHttp(), //注册首页路由
          "/signup":(context)=> const SignUpHttp(),
          "/home":(context)=>const Home()
        }

    );
  }
}
