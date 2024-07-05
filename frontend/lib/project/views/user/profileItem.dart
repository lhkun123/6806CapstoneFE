import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import 'package:frontend/project/constants/api_request.dart';
import 'package:localstorage/localstorage.dart';

import '../../constants/app_style.dart';
import 'favourites.dart';

class ProfileItem  extends StatefulWidget {
  String title,value;
  IconData icon;
  ProfileItem ({
    super.key, required this.title,required this.value,required  this.icon, required this.changeProfileCallBack
  });
  final ValueChanged<String> changeProfileCallBack;

  @override
  State<ProfileItem > createState() => _ProfileItemState();
}
class _ProfileItemState extends State<ProfileItem> {
  late TextEditingController valueController = TextEditingController();
  late List<bool> selected=[false,false];
  @override
  void initState() {
    super.initState();
    if(widget.title!="gender") {
      setState(() {
        valueController.text = widget.value;
      });
    }else{
      setState(() {

        if(widget.icon==Icons.female){
          selected[1]=true;
        }else{
          selected[0]=true;
        }
      });
    }
  }
  List<Widget> icons = <Widget>[
    const Icon(Icons.male),
    const Icon(Icons.female)
  ];
  ApiRequest apiRequest=ApiRequest();
  late Map<String, dynamic> query = {
    "url": "http://localhost:8080/user-infos",
    "body":{

    },
    "token": localStorage.getItem("token")
  };

  void updateUserInfo() async {
    await apiRequest.putRequest(query).then((response) {
      print(response);
      if (response.data["msg"] == "Success!") {
        widget.changeProfileCallBack(valueController.text.trim());
      }
    });
  }
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
            }else if( widget.title=='Username'){
                _showDialog("Modify your ${widget.title}");
            }else if (widget.title=="Birthday"){
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(1900, 1, 1),
                  maxTime: DateTime.now(), onConfirm: (date) {
                    setState(() {
                      query = {
                        "url": "http://localhost:8080/user-infos",
                        "body":{
                          "birth": date.toString().split(" ")[0],
                        },
                        "token": localStorage.getItem("token")
                      };
                      valueController.text=date.toString().split(" ")[0];
                      updateUserInfo();
                    });
                  }, currentTime: DateTime(int.parse(widget.value.split("-")[0]),int.parse(widget.value.split("-")[1]),int.parse(widget.value.split("-")[2])), locale: LocaleType.en);
            }else if(widget.title=="Gender"){
              _showDialog("Modify your ${widget.title}");
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
              if(widget.title=='Username') {
                setState(() {
                  query = {
                    "url": "http://localhost:8080/user-infos",
                    "body": {
                      "nick": valueController.text.trim(),
                    },
                    "token": localStorage.getItem("token")
                  };
                });
              }else{
                setState(() {
                  query = {
                    "url": "http://localhost:8080/user-infos",
                    "body": {
                      "gender": valueController.text.trim(),
                    },
                    "token": localStorage.getItem("token")
                  };
                });
              }
              updateUserInfo();
              Navigator.of(context).pop();
            },
            child: const Text("OK", style: AppStyle.bodyTextFont),
          ),
        ],
          content:
          widget.title == "Username"
          ? CupertinoTextField(
            controller: valueController,
            enabled: true,
            style: AppStyle.bodyTextFont,
          )
          : ToggleButtons(
          isSelected: selected,
          onPressed: (int index) {
            setState(() {
              selected[index] = true;
              selected[(index+1)%2]=false;
              valueController.text=index.toString();
            });
            print(selected);
          },
          children: const <Widget>[
            Icon(Icons.female),
            Icon(Icons.male),
          ],
        ),
      ),
    );
  }

}
