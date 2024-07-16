import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:localstorage/localstorage.dart';
import '../../constants/app_style.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';

import '../auth/sign_in.dart';

class FieldDetailPage extends StatefulWidget {
  final Map<String, dynamic> field;
  FieldDetailPage({super.key,required this.field});

  @override
  _FieldDetailState createState() => _FieldDetailState();
}

class _FieldDetailState extends State<FieldDetailPage> {

  bool favourite=false;
  List<String> imageUrls = [];
  ApiRequest apiRequest=ApiRequest();
  @override
  void initState() {
    super.initState();
    try {
      _fetchField();
      _fetchFavourite();
    } on Exception catch (e) {
      print('Error: $e');
    }
  }
  Future<void> _fetchFavourite() async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token":localStorage.getItem("token")
    };
    await apiRequest.getRequest(queryFavourite).then((response) {
      if (response.data["code"] =="200") {
        if(response.data["data"]["field"]!=null && response.data["data"]["field"].any((e) => e.toString().contains(widget.field['name']))){
          setState(() {
            favourite=true;
          });
        }
      }else if(response.data["code"] =="555") {
        _showDialog("session expired");
      }
      else {
        throw Exception('Failed to fetch favourite!');
      }
    });
  }
  void _fetchField() async {
    List<String> urls = [];
    if (widget.field['imageUrl'] != null) imageUrls.add(widget.field['imageUrl']);
    if (widget.field['previewImageUrl1'] != null)
      urls.add(widget.field['previewImageUrl1']);
    if (widget.field['previewImageUrl2'] != null)
      urls.add(widget.field['previewImageUrl2']);
    if (widget.field['previewImageUrl3'] != null)
      urls.add(widget.field['previewImageUrl3']);
    if (widget.field['previewImageUrl4'] != null)
      urls.add(widget.field['previewImageUrl4']);
    if (widget.field['previewImageUrl5'] != null)
      urls.add(widget.field['previewImageUrl5']);
    setState(() {
      imageUrls=urls;
    });
  }

  void _addOrRemoveFavorite() async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token":localStorage.getItem("token"),
      "body":{
        "alias":widget.field['name'],
        "category":"field"
      },
      "parameters":{
        "alias":widget.field['name'],
        "category":"field"
      }
    };
    if(!favourite){
      await apiRequest.postRequest(queryFavourite).then((response) {
        if (response.data["code"] =="200") {
          setState(() {
            favourite=true;
          });
        }else if(response.data["code"] =="555") {
          _showDialog("session expired");
        }
        else {
          throw Exception('Failed to add this item to favorite!');
        }
      });
    }else{
      await apiRequest.deleteRequest(queryFavourite).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            favourite=false;
          });
        } else {
          throw Exception('Failed to delete this item from favorite!');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppStyle.barBackgroundColor,
        elevation: 0.0,
        title: Text(widget.field['name'] ?? 'Field Details', style: AppStyle.barHeadingFont2),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrls.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    autoPlay: true,
                  ),
                  items: imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(url, fit: BoxFit.cover),
                        );
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppStyle.barBackgroundColor, size: 21),
                        const SizedBox(width: 5),
                        Flexible(
                          child:
                          Text(widget.field['location'] ?? 'No Location', style: AppStyle.themeTextFont),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        StarScore(
                          score: widget.field['rating'].toDouble(),
                          star: Star(
                              fillColor: Colors.yellow,
                              emptyColor: Colors.grey.withAlpha(88),
                              size: 12
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('${widget.field['distance'] ?? 'No Distance'} km'),
                        const SizedBox(width: 16),
                        Text('${widget.field['difficulty'] ?? 'No Difficulty'}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('Estimated Time: ${widget.field['estimatedTime'] ?? 'No Estimated Time'}'),
                    const SizedBox(height: 32),
                    const Text('Description', style: AppStyle.themeBigTextFont),
                    const SizedBox(height: 5),
                    Text(widget.field['description'] ?? 'No Description', style: AppStyle.bodyTextFont),
                    const SizedBox(height: 16),
                    Center(
                      child: IconButton(
                        onPressed: () {
                          if(favourite){
                            _showDialog("Are you sure to remove this from your favourite list?");
                          }else{
                            _showDialog("${widget.field['name']} has been added to you favourite list!");
                          }
                        },
                        icon: Icon(
                          CupertinoIcons.heart_solid,
                          color: favourite? Colors.red:AppStyle.barBackgroundColor,
                          size: 42,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          if (favourite)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Cancel",
                style: AppStyle.bodyTextFont,
              ),
            ),
          CupertinoDialogAction(
            onPressed: () {
              if(message!="session expired") {
                _addOrRemoveFavorite();
                favourite = !favourite;
                Navigator.of(context).pop();
              }else{
                localStorage.removeItem("token");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInHttp()),
                      (Route<dynamic> route) => false,
                );
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
