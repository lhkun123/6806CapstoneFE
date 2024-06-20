import 'package:flutter/cupertino.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_key.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/views/yelp/yelp_overview.dart';
import 'package:geolocator/geolocator.dart';

class YelpSearch extends StatefulWidget {
  const YelpSearch({super.key});
  @override
  _YelpSearchState createState() => _YelpSearchState();
}

class _YelpSearchState extends State<YelpSearch> {
  List<dynamic> businesses = [];
  bool autoLocation = false;
  ApiRequest apiRequest = ApiRequest();
  Map<String, dynamic> searchQuery = {
    "url": "https://api.yelp.com/v3/businesses/search",
    "parameters": {
      "sort_by": "best_match",
      "limit": 20,
      "location": "Vancouver"
    },
    "token": ApiKey.YELP_API_KEY
  };

  String selectedSortCategory = "Default";
  String selectedBusinessCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    try {
      _fetchBusinesses();
    } on Exception catch (e) {
      print('Error: $e');
    }
  }

  void _fetchBusinesses() async {
    await apiRequest.getRequest(searchQuery).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          businesses = response.data["businesses"];
        });
      } else {
        throw Exception('Failed to fetch businesses');
      }
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    Map<String, dynamic> locationQuery = {
      "url": "https://maps.googleapis.com/maps/api/geocode/json",
      "parameters": {
        "latlng": "${position.latitude},${position.longitude}",
        "key": ApiKey.GOOGLE_MAP_API_KEY
      },
    };
    await apiRequest.getRequest(locationQuery).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          businesses = [];
          searchQuery["parameters"]["location"] = response.data["results"][0]["formatted_address"].split(',')[0];
        });
        _fetchBusinesses();
      } else {
        throw Exception('Failed to fetch location');
      }
    });
    autoLocation = !autoLocation;
    return position;
  }

  Future<List<String>> _fetchAutocompleteList(String keyword) async {
    List<String> autoCompleteKeywords = [];
    if (keyword.isEmpty) {
      return autoCompleteKeywords;
    }
    Map<String, dynamic> autocompleteQuery = {
      "url": "https://api.yelp.com/v3/autocomplete",
      "parameters": {
        "text": keyword
      },
      "token": ApiKey.YELP_API_KEY
    };
    await apiRequest.getRequest(autocompleteQuery).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          for (var i = 0; i < response.data["categories"].length; i++) {
            autoCompleteKeywords.add(response.data["categories"][i]["title"]);
          }
        });
      } else {
        throw Exception('Failed to fetch businesses suggestions');
      }
    });
    return autoCompleteKeywords;
  }

  void _sortByCategory(String category) {
    setState(() {
      if (category == 'Rating') {
        businesses.sort((a, b) => b['rating'].compareTo(a['rating']));
      } else if (category == 'Reviews') {
        businesses.sort((a, b) => b['review_count'].compareTo(a['review_count']));
      } else if (category == 'Distance') {
        businesses.sort((a, b) => a['distance'].compareTo(b['distance']));
      } else {
        _fetchBusinesses();
      }
      selectedSortCategory = category;
    });
  }

  void _searchByCategory(String category) {
    setState(() {
      searchQuery["parameters"]["categories"] = category;
      _fetchBusinesses();
      selectedBusinessCategory = category;
    });
  }

  void _searchByKeyword(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        searchQuery["parameters"].remove("term");
      } else {
        searchQuery["parameters"]["term"] = keyword;
      }
      _fetchBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> business;
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Entertainment', style: AppStyle.bigHeadingFont),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (!autoLocation) {
                  _determinePosition();
                } else {
                  setState(() {
                    autoLocation = !autoLocation;
                  });
                }
              },
              child: Icon(
                autoLocation ? Icons.location_on : Icons.location_off,
                color: AppStyle.barBackgroundColor,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (!autoLocation) {
                    _showDialog();
                  }
                });
              },
              child: Row(
                children: [
                  Text(searchQuery["parameters"]["location"], style: AppStyle.subheadingFont),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 320, height: 50,
                  child: SearchAnchor(
                    viewBackgroundColor: AppStyle.primaryColor,
                    dividerColor: AppStyle.primaryColor,
                    builder: (BuildContext context, SearchController controller) {
                      return SearchBar(
                        controller: controller,
                        backgroundColor: WidgetStateProperty.all<Color>(AppStyle.primaryColor),
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onTap: () {
                          controller.openView();
                        },
                        onChanged: (keyword) {
                          controller.openView();
                        },
                        leading: const Icon(Icons.search),
                      );
                    },
                    suggestionsBuilder: (BuildContext context, SearchController controller) async {
                      final List<String> options = await _fetchAutocompleteList(
                          controller.text);
                      return options.map((String keyword) => ListTile(
                        title: Text(keyword),
                        onTap: () {
                          setState(() {
                            _searchByKeyword(keyword);
                            controller.closeView(keyword);
                          });
                        },
                      )).toList();
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Sort by:  ', style: AppStyle.bodyTextFont),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            style: AppStyle.bodyTextFont,
                            value: selectedSortCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                _sortByCategory(newValue!);
                              });
                            },
                            items: <String>['Default', 'Rating', 'Distance', 'Reviews']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const Text('Category:  ', style: AppStyle.bodyTextFont),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            style: AppStyle.bodyTextFont,
                            value: selectedBusinessCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                _searchByCategory(newValue!);
                              });
                            },
                            items: <String>["All", 'Food', 'Arts & Entertainment', 'Hotels & Travel', 'Health & Medical']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: businesses.isEmpty
                ? const Center(
              child: CircularProgressIndicator(
                color: AppStyle.indicatorColor,
              ),
            )
                : Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,  // Attach the ScrollController
              child: ListView.builder(
                controller: _scrollController,  // Attach the ScrollController
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  business = businesses[index];
                  return ListTile(
                    leading: Image.network(
                      business['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text("${index + 1}. ${business['name']}"),
                        ),
                        StarScore(
                          score: business['rating'],
                          star: Star(
                              fillColor: Colors.yellow,
                              emptyColor: Colors.grey.withAlpha(88),
                              size: 12
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text('${business['review_count']} reviews', style: AppStyle.bodyTextFont),
                        const SizedBox(width: 10),
                        Text("${(business['distance'] / 1609.0).toStringAsFixed(2)} mi", style: AppStyle.bodyTextFont),
                        const SizedBox(width: 5),
                        business["is_closed"] ? const Icon(Icons.clear_rounded, color: Colors.red,) : const Icon(Icons.check, color: Colors.green,)
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppStyle.barBackgroundColor),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => YelpOverview(alias: businesses[index]["alias"] ?? "", latitude: businesses[index]["coordinates"]["latitude"] ?? 0, longitude: businesses[index]["coordinates"]["longitude"] ?? 0, location: businesses[index]["location"]["address1"], title: businesses[index]["name"],),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _locationController = TextEditingController(
            text: searchQuery["parameters"]["location"]);
        return CupertinoAlertDialog(
          title: const Text("Input Address"),
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
            CupertinoDialogAction(
              onPressed: () {
                setState(() {
                  searchQuery["parameters"]["location"] =
                      _locationController.text;
                });
                Navigator.of(context).pop();
                _fetchBusinesses();
              },
              child: const Text(
                "OK",
                style: AppStyle.bodyTextFont,
              ),
            ),
          ],
          content: CupertinoTextField(
            controller: _locationController,
            enabled: !autoLocation,
            style: AppStyle.bodyTextFont,
          ),
        );
      },
    );
  }
}
