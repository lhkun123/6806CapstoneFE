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
import '../fields/field_detail_page.dart';
import '../yelp/yelp_overview.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final ScrollController _entertainmentScrollController = ScrollController();
  final ScrollController _fieldScrollController = ScrollController();
  late List<Map<String, dynamic>> entertainment = [];
  late List<dynamic> entertainmentList = [];
  late List<Map<String, dynamic>> field = [];
  late List<dynamic> fieldList = [];
  ApiRequest apiRequest = ApiRequest();

  Future<void> _fetchFavourite() async {
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token": localStorage.getItem("token")
    };
    await apiRequest.getRequest(queryFavourite).then((response) {
      if (response.data["code"] == "200") {
        setState(() {
          entertainmentList = response.data["data"]["entertainment"] ?? [];
          fieldList = response.data["data"]["field"] ?? [];
        });
        _fetchDetail();
      } else if (response.data["code"] == "555") {
        _showDialog("session expired", 0, "");
      } else {
        throw Exception('Failed to fetch favourite!');
      }
    });
  }

  Future<void> _fetchDetail() async {
    Map<String, dynamic> query;
    List<Map<String, dynamic>> entertainmentResults = List<Map<String, dynamic>>.filled(
        entertainmentList.length, {}, growable: true);
    List<Map<String, dynamic>> fieldResults = List<Map<String, dynamic>>.filled(
        fieldList.length, {}, growable: true);
    for (int i = 0; i < entertainmentList.length; i++) {
      query = {
        "url": "https://api.yelp.com/v3/businesses/${entertainmentList[i]}",
        "token": ApiKey.YELP_API_KEY
      };
      await apiRequest.getRequest(query).then((response) {
        if (response.statusCode == 200) {
          entertainmentResults[i] = {
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
    for (int i = 0; i < fieldList.length; i++) {
      query = {
        "url": "http://localhost:8080/api/field",
        "parameters": {
          "field": fieldList[i]
        },
        "token": ApiKey.YELP_API_KEY
      };
      await apiRequest.getRequest(query).then((response) {
        if (response.statusCode == 200) {
          print(response.data["data"]);
          fieldResults[i] = {
            "rating": response.data["data"]["rating"],
            "name": response.data["data"]["name"],
            "imageUrl": response.data["data"]["imageUrl"],
            "distance": response.data["data"]["distance"],
            "location": response.data["data"]["location"],
            "previewImageUrl1": response.data["data"]["previewImageUrl1"],
            "previewImageUrl2": response.data["data"]["previewImageUrl2"],
            "previewImageUrl3": response.data["data"]["previewImageUrl3"],
            "previewImageUrl4": response.data["data"]["previewImageUrl4"],
            "previewImageUrl5": response.data["data"]["previewImageUrl5"],
            "description": response.data["data"]["description"],
            "difficulty": response.data["data"]["difficulty"],
            "estimated_time": response.data["data"]["estimated_time"]
          };
        } else {
          throw Exception('Failed to fetch detail!');
        }
      });
    }
    setState(() {
      entertainment = entertainmentResults;
      field = fieldResults;
    });
  }

  late Map<String, dynamic> favourite;

  void _removeFavorite(String name, int index) async {
    print(name);
    print(entertainmentList[index]);
    Map<String, dynamic> queryFavourite = {
      "url": "http://localhost:8080/favorites",
      "token": localStorage.getItem("token"),
      "parameters": {
        "alias": name != "field" ? entertainmentList[index] : fieldList[index],
        "category":name
      }
    };
    await apiRequest.deleteRequest(queryFavourite).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          if (name != "field") {
            entertainment.removeAt(index);
            entertainmentList.removeAt(index);
          } else {
            field.removeAt(index);
            fieldList.removeAt(index);
          }
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
      body: entertainmentList.isEmpty && fieldList.isEmpty
          ? const Center(
        child: Text(
          "You have not added any item to your favourite list",
          style: AppStyle.subheadingFont,
        ),
      )
          : Column(
        children: [
          if (entertainmentList.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
              controller: _entertainmentScrollController,
              child: ListView.builder(
                controller: _entertainmentScrollController,
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
                            _showDialog("Are you sure to remove this item from your favourite list?", index, "entertainment");
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
                                  title: favourite["name"],
                                ),
                              ),
                            ).then((value) => _fetchFavourite()
                            );
                          },
                          backgroundColor: AppStyle.barBackgroundColor,
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
          if (fieldList.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Trails",
                  style: AppStyle.subheadingFont,
                ),
              ),
            ),
          Expanded(
            child: fieldList.isEmpty
                ? const Center(
              child: CircularProgressIndicator(
                color: AppStyle.unselectedLabelColor,
              ),
            )
                : Scrollbar(
              thumbVisibility: true,
              controller: _fieldScrollController,
              child: ListView.builder(
                controller: _fieldScrollController,
                itemCount: field.length,
                itemBuilder: (context, index) {
                  favourite = field[index];
                  return Slidable(
                    key: ValueKey(favourite['name']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _showDialog("Are you sure to remove this item from your favourite list?", index, "field");
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
                                  builder: (context) => FieldDetailPage(field: field[index])
                              ),
                            ).then(
                                    (value) => _fetchFavourite()
                            );
                          },
                          backgroundColor: AppStyle.barBackgroundColor,
                          foregroundColor: Colors.white,
                          icon: Icons.details,
                          label: 'Detail',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.network(
                        favourite['imageUrl'],
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
                            score: favourite['rating'].toDouble(),
                            star: Star(
                                fillColor: Colors.yellow,
                                emptyColor: Colors.grey.withAlpha(88),
                                size: 12),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text('${favourite['distance']} mi',
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
        ],
      ),
    );
  }

  void _showDialog(String message, int index, String mode) {
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
              if (message != "session expired") {
                _removeFavorite(mode, index);
              } else {
                localStorage.removeItem("token");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInHttp()),
                      (Route<dynamic> route) => false,
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text("OK", style: AppStyle.bodyTextFont),
          ),
        ],
        content: Text(message, style: AppStyle.bodyTextFont),
      ),
    );
  }
}
