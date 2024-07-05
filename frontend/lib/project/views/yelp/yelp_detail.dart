import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:localstorage/localstorage.dart';
import '../../constants/api_key.dart';
import '../../constants/api_request.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';


class YelpDetail extends StatefulWidget {
  String alias, title;
  YelpDetail({super.key, required this.alias, required this.title});

  @override
  _YelpDetailState createState() => _YelpDetailState();
}

class _YelpDetailState extends State<YelpDetail> {
  late Map<String, dynamic> query = {
    "url": "https://api.yelp.com/v3/businesses/${widget.alias}",
    "token": ApiKey.YELP_API_KEY
  };
  ApiRequest apiRequest = ApiRequest();
  Map<String, dynamic>? detail;
  bool favourite=false;
  List<String> imgList = [];
  CarouselController buttonCarouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    try {
      _fetchDetail();
    } on Exception catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    detail?.clear();
    imgList.clear();
    super.dispose();
  }

  Future<void> _fetchFavourite() async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token":localStorage.getItem("token")
    };
    await apiRequest.getRequest(queryFavourite).then((response) {
      if (response.data["code"] =="200") {
          if(response.data["data"]["entertainment"]!=null && response.data["data"]["entertainment"].any((e) => e.toString().contains(widget.alias))){
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
  void _addOrRemoveFavorite() async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token":localStorage.getItem("token"),
      "body":{
        "alias":widget.alias,
        "category":"entertainment"
      },
      "parameters":{
        "alias":widget.alias,
        "category":"entertainment"
      }
    };
    if(!favourite){
      await apiRequest.postRequest(queryFavourite).then((response) {
        if (response.statusCode == 200) {
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
  void _fetchDetail() async {
    await apiRequest.getRequest(query).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          detail = response.data;
          for (var i = 0; i < detail!["photos"].length; i++) {
            imgList.add(detail!["photos"][i]);
          }
        });
        _fetchFavourite();
      } else {
        throw Exception('Failed to fetch detail!');
      }
    });
  }

  Future<void> _shareToFacebook() async {
    final Uri _url = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=https://www.yelp.com/biz/${widget.alias}');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  Future<void> _shareToTwitter() async {
    final Uri _url = Uri.parse('https://twitter.com/intent/tweet?url=https://www.yelp.com/biz/${widget.alias}');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: detail == null
          ? const Center(
        child: CircularProgressIndicator(
          color: AppStyle.barBackgroundColor,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["location"]["display_address"].join(),
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Category',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["categories"][0]["title"],
                          style: AppStyle.bodyTextFont,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phone',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["display_phone"] == "" ? "Not Available" : detail!["display_phone"],
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Price',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["price"],
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["hours"][0]["is_open_now"] ? "Open Now" : "Closed",
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Visit Yelp for more',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          'Business Link',
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: IconButton(
                  onPressed: () {
                    if(favourite){
                      _showDialog("Are you sure to remove this from your favourite list?");
                    }else{
                      _showDialog("${detail?["name"]} has been added to you favourite list!");
                    }
                  },
                   icon: Icon(CupertinoIcons.heart_solid, color: favourite? Colors.red:AppStyle.barBackgroundColor),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Share to:'),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.facebook),
                          color: AppStyle.barBackgroundColor,
                          onPressed: _shareToFacebook,
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.twitter),
                          color: AppStyle.barBackgroundColor,
                          onPressed: _shareToTwitter,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => buttonCarouselController.previousPage(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.linear,
                    ),
                    child: const Icon(Icons.arrow_back_ios,color: AppStyle.barBackgroundColor),
                  ),
                  Expanded(
                    child: CarouselSlider(
                      items: imgList.map((item) => Center(
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                          width: 600,
                          height: 600,
                        ),
                      )).toList(),
                      carouselController: buttonCarouselController,
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                        aspectRatio: 1.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => buttonCarouselController.nextPage(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.linear,
                    ),
                    child: const Icon(Icons.arrow_forward_ios,color: AppStyle.barBackgroundColor),

                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              _addOrRemoveFavorite();
              favourite = !favourite;
              Navigator.of(context).pop();
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

