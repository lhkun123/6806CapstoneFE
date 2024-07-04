import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
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
                _showDialog("Modify your profile");
            }
          },
        ),
        const Divider(),
      ],
    );
  }
  void _showDialog(String message) {
    final TextEditingController _userNameController = TextEditingController();
    ApiRequest apiRequest=ApiRequest();
    late Map<String, dynamic> query = {
      "url": "http://localhost:8080/user-infos",
      "body":{
        "nick": _userNameController.text.trim(),
      },
      "token": localStorage.getItem("token")
    };
    void updateUserInfo() async {
      await apiRequest.putRequest(query).then((response) {
        if (response.data["msg"] == "Success!") {
        }else{

        }
      });
    }
    showDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(message),
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
              updateUserInfo();
              Navigator.of(context).pop();
            },
            child: const Text("OK", style: AppStyle.bodyTextFont),
          ),
        ],
          content: CupertinoTextField(
            controller: _userNameController,
            enabled: true,
            style: AppStyle.bodyTextFont,
          )
      ),
    );
  }
}
