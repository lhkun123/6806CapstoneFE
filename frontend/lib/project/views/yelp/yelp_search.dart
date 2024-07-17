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
  bool emptyResult=false;
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
          if(businesses.isEmpty){
            emptyResult=true;
          }else{
            emptyResult=false;
          }
        });
        print(emptyResult);
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
      emptyResult=false;
      if(category=="All"){
        searchQuery["parameters"]["categories"]="All";
      }else if(category=='Food'){
        searchQuery["parameters"]["categories"]="food, All";
      }else if(category=='Arts & Entertainment'){
        searchQuery["parameters"]["categories"]="arts, All";
      }else if (category=='Hotels & Travel'){
        searchQuery["parameters"]["categories"]="hotelstravel, All";
      }else if (category=='Health & Medical'){
        searchQuery["parameters"]["categories"]="health, All";
      }
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
      body: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
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
                  size: 22,
                ),
              ),
              const SizedBox(width: 6),
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
                    Text(searchQuery["parameters"]["location"], style: AppStyle.bodyTextFont),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 340, height: 40,
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
                      textInputAction: TextInputAction.search,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sort by:  ', style: AppStyle.bodyTextFont),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          dropdownColor: Colors.white,
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
                        const SizedBox(width: 16),
                        const Text('Category:  ', style: AppStyle.bodyTextFont),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          dropdownColor: Colors.white,
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
          child:emptyResult ? const Center(
            child: Text("No result available"),  // Show this text when no results are found
          ) :  (businesses.isEmpty && !emptyResult) ? const Center(
              child: CircularProgressIndicator(
                color: AppStyle.barBackgroundColor,
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
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => YelpOverview(
                          alias: businesses[index]["alias"] ?? "",
                          latitude: businesses[index]["coordinates"]["latitude"] ?? 0,
                          longitude: businesses[index]["coordinates"]["longitude"] ?? 0,
                          location: businesses[index]["location"]["address1"],
                          title: businesses[index]["name"],),
                      ),
                    );
                  },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.network(
                      business['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text("${business['name']}", style: AppStyle.subheadingFont),
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
                        Row(
                          children: [
                            Text('${business['review_count']} reviews', style: AppStyle.bodyTextFont),
                            const SizedBox(width: 10),
                            Text("${(business['distance'] / 1000.0).toStringAsFixed(2)} km", style: AppStyle.bodyTextFont),
                            const SizedBox(width: 5)
                          ],
                        ),
                      ],
                    ),
                  ),
                  ],
                  ),
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
