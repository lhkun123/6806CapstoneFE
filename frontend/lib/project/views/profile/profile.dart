import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/auth/sign_in.dart';

class Profile extends StatefulWidget {
  const Profile({

    super.key,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: AppStyle.bigheadingFont),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  const ProfileItem(
                    title: 'Username',
                    value: 'name',
                    icon: Icons.edit,
                  ),
                  const ProfileItem(
                    title: 'Email',
                    value: 'name@domain.com',
                    icon: Icons.edit,
                  ),
                  const ProfileItem(
                    title: 'Favorites',
                    value: '',
                    icon: Icons.arrow_forward_ios,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Log Out', style: AppStyle.subheadingFont),
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
          trailing: Icon(icon, color: Colors.blue),
          onTap: () {},
        ),
        const Divider(),
      ],
    );
  }
}

