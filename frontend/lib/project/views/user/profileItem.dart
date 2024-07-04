import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../../constants/app_style.dart';
import '../auth/sign_in.dart';
import 'favourites.dart';

class ProfileItem  extends StatefulWidget {
  String title,value;
  IconData icon;
  ProfileItem ({
    super.key, required this.title,required this.value,required  this.icon
  });

  @override
  State<ProfileItem > createState() => _ProfileItemState();
}
class _ProfileItemState extends State<ProfileItem> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            widget.title,
            style: AppStyle.subheadingFont,
          ),
          subtitle: widget.value.isNotEmpty ? Text(widget.value, style: AppStyle.bodyTextFont) : null,
          trailing: Icon(widget.icon, color: Colors.blue),
          onTap: () {
            if (widget.title == "Favorites") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Favourites(),
                ),
              );
            }else if(widget.title=="Birthday" || widget.title=='Gender' || widget.title=='Username'){
                _showDialog("Modify you Profile");
            }
          },
        ),
        const Divider(),
      ],
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
