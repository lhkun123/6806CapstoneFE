import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/auth/sign_in.dart';
import 'package:frontend/project/views/user/profileItem.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Map<String, dynamic> profileInformation = {};
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic> query = {
    "url": "http://localhost:8080/users",
    "token": localStorage.getItem("token")
  };
  ApiRequest apiRequest = ApiRequest();
  File? image;
  void _fetchProfile() async {
    await apiRequest.getRequest(query).then((response) {
      if (response.data["code"] == "200") {
        setState(() {
          profileInformation = response.data["data"];
        });
      } else if (response.data["code"] == "555") {
        _showDialog("session expired");
      } else {
        throw Exception('Failed to fetch profile!');
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
          image=File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: profileInformation.isEmpty
          ? const Center(
        child: CircularProgressIndicator(
          color: AppStyle.barBackgroundColor,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      NetworkImage(profileInformation["avatar"])
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      _pickImage();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  ProfileItem(
                    title: 'Username',
                    value: profileInformation["nick"],
                    icon: Icons.verified_user,
                    changeProfileCallBack: (value){
                      setState(() {
                        profileInformation["nick"]=value;
                      });
                    },
                  ),
                  ProfileItem(
                    title: 'Birthday',
                    value: profileInformation["birth"],
                    icon: Icons.cake,
                    changeProfileCallBack: (value){
                      setState(() {
                        profileInformation["birth"]=value;
                      });
                    },
                  ),
                  ProfileItem(
                    title: 'Gender',
                    value: '',
                    icon: profileInformation["gender"] == "0" ? Icons.female : Icons.male,
                    changeProfileCallBack: (value){
                      setState(() {
                        profileInformation["gender"]=value;
                      });
                    },
                  ),
                   ProfileItem(
                    title: 'Favorites',
                    value: '',
                    icon: Icons.favorite,
                     changeProfileCallBack: (value){

                     },
                  ),
                   ProfileItem(
                    title: 'About',
                    value: '',
                    icon: Icons.arrow_forward_ios,
                     changeProfileCallBack: (value){

                     },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      _showDialog('Are you sure to exit the system?');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppStyle.primaryColor,
                      elevation: 2,
                      backgroundColor: AppStyle.barBackgroundColor,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Log Out', style: AppStyle.bigButtonFont),
                  ),
                ],
              ),
            ),
          ],
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
          if (message != "session expired")
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: AppStyle.bodyTextFont,
              ),
            ),
          CupertinoDialogAction(
            onPressed: () {
              localStorage.removeItem("token");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInHttp()),
                    (Route<dynamic> route) => false,
              );
            },
            child: const Text("OK", style: AppStyle.bodyTextFont),
          ),
        ],
        content: Text(message, style: AppStyle.bodyTextFont),
      ),
    );
  }
}
