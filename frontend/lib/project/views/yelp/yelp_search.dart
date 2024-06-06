import 'package:frontend/project/constants/app_style.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_key.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/views/yelp/yelp_overview.dart';

class YelpSearch extends StatefulWidget {
  const YelpSearch({super.key});
  @override
  _YelpSearchState createState() => _YelpSearchState();
}

class _YelpSearchState extends State<YelpSearch> {
  List<dynamic> businesses=[];
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
  Future<List<String>> _fetchAutocompleteList(String keyword) async{
    List<String> autoCompleteKeywords = [];
    if(keyword.isEmpty){
      return autoCompleteKeywords;
    }
    Map<String, dynamic> autocompleteQuery = {
      "url": "https://api.yelp.com/v3/autocomplete",
      "parameters":{
        "text":keyword
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
  void _searchByKeyword(String keyword){
    setState(() {
      if(keyword.isEmpty){
        searchQuery["parameters"].remove("term");
      }else{
        searchQuery["parameters"]["term"]=keyword;
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
        title: const Text('The best match businesses for you in Vancouver', style: AppStyle.headingFont),
          backgroundColor:AppStyle.largeBackgroundColor
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 320, height: 50,
                  child:SearchAnchor(
                    viewBackgroundColor:AppStyle.primaryColor,
                    dividerColor:AppStyle.primaryColor,
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
                    suggestionsBuilder: (BuildContext context, SearchController controller) async{
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
                    }
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
                        const Text('Sort by:', style: AppStyle.bodyTextFont),
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
                        const Text('Category:', style: AppStyle.bodyTextFont),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                        style: AppStyle.bodyTextFont,
                        value: selectedBusinessCategory,
                        onChanged: (String? newValue) {
                        setState(() {
                          _searchByCategory(newValue!);
                        });
                        },
                        items: <String>["All",'Food', 'Arts & Entertainment', 'Hotels & Travel', 'Health & Medical']
                            .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                        );
                        }).toList(),
                        ),
                        ],
                      )]
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
              child: ListView.builder(
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
                    title: Text("${index + 1}. ${business['name']}"),
                    subtitle: Row(
                      children: [
                        Text('${business['rating']}/5.0'),
                        const SizedBox(width: 5),
                        Text('${business['review_count']} reviews'),
                        const SizedBox(width: 10),
                        Text("${(business['distance'] / 1609.0).toStringAsFixed(2)} mi")
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => YelpOverview(alias:  businesses[index]["alias"] ?? "",latitude: businesses[index]["coordinates"]["latitude"] ?? 0,longitude:  businesses[index]["coordinates"]["longitude"]?? 0,location: businesses[index]["location"]["address1"],title: businesses[index]["name"],),
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
}
