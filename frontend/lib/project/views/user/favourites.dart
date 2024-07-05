import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../constants/api_key.dart';
import '../../constants/app_style.dart';
import '../auth/sign_in.dart';
import '../yelp/yelp_overview.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> entertainment = [];
  late List<dynamic> entertainmentList = [];
  ApiRequest apiRequest = ApiRequest();
  Future<void> _fetchFavourite() async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token": localStorage.getItem("token")
    };
    await apiRequest.getRequest(queryFavourite).then((response) {
      print( response.data);
      if (response.data["code"] == "200") {
          setState(() {
            entertainmentList = response.data["data"]["entertainment"] ?? [];
          });
          _fetchDetail();
      } else if (response.data["code"] == "555") {
        _showDialog("session expired",0);
      } else {
        throw Exception('Failed to fetch favourite!');
      }
    });
  }

  Future<void> _fetchDetail() async {
    Map<String, dynamic> query;
    print(entertainmentList.length);
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.filled(
        entertainmentList.length, {}, growable: true);
    for (int i = 0; i < entertainmentList.length; i++) {
      query = {
        "url": "https://api.yelp.com/v3/businesses/${entertainmentList[i]}",
        "token": ApiKey.YELP_API_KEY
      };
      await apiRequest.getRequest(query).then((response) {
        if (response.statusCode == 200) {
          results[i] = {
            "rating": response.data["rating"],
            "name": response.data["name"],
            "image_url": response.data["image_url"],
            "review_count": response.data["review_count"],
            "alias": response.data["alias"],
            "latitude": response.data["coordinates"]["latitude"] ?? 0,
            "longitude": response.data["coordinates"]["longitude"] ?? 0,
            "location": response.data["location"]["address1"],
          };
        } else {
          throw Exception('Failed to fetch detail!');
        }
      });
    }
    setState(() {
      entertainment = results;
    });
  }
  late Map<String, dynamic> favourite;
  void _removeFavorite(int index) async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token":localStorage.getItem("token"),
      "body":{
        "alias":entertainmentList[index],
        "category":"entertainment"
      },
      "parameters":{
        "alias":entertainmentList[index],
        "category":"entertainment"
      }
    };
      await apiRequest.deleteRequest(queryFavourite).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            entertainment.removeAt(index);
            entertainmentList.removeAt(index);
          });
        } else {
          throw Exception('Failed to delete this item from favorite!');
        }
      });
  }
  @override
  void initState() {
    super.initState();
    _fetchFavourite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your favourites", style: AppStyle.headingFont),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Entertainment",
                style: AppStyle.subheadingFont,
              ),
            ),
          ),
          Expanded(
            child: entertainment.isEmpty
                ? const Center(
              child: CircularProgressIndicator(
                color: AppStyle.unselectedLabelColor,
              ),
            )
                : Scrollbar(
              thumbVisibility: true,
              controller: _scrollController, // Attach the ScrollController
              child: ListView.builder(
                controller: _scrollController, // Attach the ScrollController
                itemCount: entertainment.length,
                itemBuilder: (context, index) {
                  favourite = entertainment[index];
                  return Slidable(
                    key: ValueKey(favourite['alias']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                              _showDialog("Are you sure to remove this item from your favourite list?", index);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => YelpOverview(
                                  alias: favourite["alias"] ?? "",
                                  latitude: favourite["latitude"] ?? 0,
                                  longitude: favourite["longitude"] ?? 0,
                                  location: favourite["location"],
                                  title: favourite["name"],),
                              ),
                            ).then(
                                    (value)=>_fetchFavourite()
                            );
                          },
                          backgroundColor: AppStyle.unselectedLabelColor,
                          foregroundColor: Colors.white,
                          icon: Icons.details,
                          label: 'Detail',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.network(
                        favourite['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text("${index + 1}. ${favourite['name']}"),
                          ),
                          StarScore(
                            score: favourite['rating'],
                            star: Star(
                                fillColor: Colors.yellow,
                                emptyColor: Colors.grey.withAlpha(88),
                                size: 12),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text('${favourite['review_count']} reviews',
                              style: AppStyle.bodyTextFont),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),

                  );

                },
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showDialog(String message,int index) {
    showDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Notification"),
          actions: [
            if (message != "session expired")
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
                  if (message != "session expired"){
                        _removeFavorite(index);
                  }else{
                    localStorage.removeItem("token");
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInHttp()),
                          (Route<dynamic> route) => false,
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("OK", style: AppStyle.bodyTextFont)),
          ],
          content: Text(message, style: AppStyle.bodyTextFont),
        ));
  }
}
