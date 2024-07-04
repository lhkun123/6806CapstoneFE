import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/auth/sign_up.dart';
import 'package:frontend/project/views/home/home.dart';
import 'package:localstorage/localstorage.dart';
import 'project/views/auth/sign_in.dart';

Future<void> verifyToken() async {
  if (localStorage.getItem("token") != null) {
    Map<String, dynamic> query = {
      "url": "http://localhost:8080/user-tokens",
      "token": localStorage.getItem("token")
    };
    ApiRequest apiRequest = ApiRequest();
    try {
      await apiRequest.getRequest(query).then((response) {});
    } catch (e) {
      localStorage.removeItem("token");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CloudinaryObject.fromCloudName(cloudName: "dtbg6plsq");
  await initLocalStorage();
  await verifyToken();
  runApp(
    DevicePreview(
      enabled: true, // 启用 DevicePreview
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: localStorage.getItem("token") == null
            ? const SignInHttp()
            : const Home(), //如果token有效则跳转至主页，无效则跳转至登录页(首页)
        theme: ThemeData(
          primaryColor: AppStyle.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white
          ),
        ),
        //注册路由表
        routes:{
          "/signin":(context) => const SignInHttp(), //注册首页路由
          "/signup":(context)=> const SignUpHttp(),
          "/home":(context)=> const Home()
        }

    );
  }
}
