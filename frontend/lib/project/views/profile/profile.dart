import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/auth/sign_in.dart';
import 'package:localstorage/localstorage.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Map<String, dynamic> profileInformation={};
  Map<String, dynamic> query = {
    "url": "http://localhost:8080/users",
    "token": localStorage.getItem("token")
  };
  ApiRequest apiRequest=ApiRequest();
  void _fetchProfile() async {
    await apiRequest.getRequest(query).then((response) {
      print(response.data);
      print(response.data["data"]);
      if (response.data["code"] =="200") {
        setState(() {
          profileInformation = response.data["data"];
        });
      } else {
        throw Exception('Failed to fetch profile information');
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: AppStyle.bigHeadingFont),
        centerTitle: true,
      ),
      body: profileInformation.isEmpty
          ? const Center(
        child: CircularProgressIndicator(
          color: AppStyle.indicatorColor,
        ),
      ) :
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg'), // Replace with your image URL
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
                  ),
                  ProfileItem(
                    title: 'Birthday',
                    value: profileInformation["birth"],
                    icon: Icons.cake,
                  ),
                  ProfileItem(
                    title: 'Gender',
                    value: '',
                    icon: profileInformation["gender"]=="0" ? Icons.female:Icons.male,
                  ),
                  const ProfileItem(
                    title: 'Favorites',
                    value: '',
                    icon: Icons.favorite,
                  ),
                  const ProfileItem(
                    title: 'About',
                    value: '',
                    icon: Icons.arrow_forward_ios,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async{
                      _showDialog(
                        'Are you sure to exit the system?'
                    );
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
                    child: const Text('Log Out'),
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
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Cancel",
                style: AppStyle.bodyTextFont,
              ),
            ),
            CupertinoDialogAction(onPressed: (){
              localStorage.removeItem("token");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInHttp()),
                    (Route<dynamic> route) => false,
              );
            },
                child: const Text("OK",
                    style:AppStyle.bodyTextFont
                )),
          ],
          content: Text(message,
              style:AppStyle.bodyTextFont
          ),
        )
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String title;
  final String value;

  final IconData icon;

  const ProfileItem({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: AppStyle.subheadingFont,
          ),
          subtitle: value.isNotEmpty ? Text(value, style: AppStyle.bodyTextFont) : null,
          trailing:  Icon(icon, color: Colors.blue),
          onTap: () {

          },
        ),
        const Divider(),
      ],
    );
  }
}

