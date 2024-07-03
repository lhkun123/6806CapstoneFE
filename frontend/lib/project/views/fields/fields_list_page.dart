import 'package:flutter/material.dart';
import '../../constants/api_request.dart';
import 'field_detail_page.dart';
import '../../constants/app_style.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';

class FieldsListPage extends StatefulWidget {
  @override
  _FieldsListPageState createState() => _FieldsListPageState();
}

class _FieldsListPageState extends State<FieldsListPage> {
  List<dynamic> fields = [];
  List<dynamic> filteredFields = [];
  String searchQuery = '';
  String sortBy = 'All';
  bool autoLocation = false;

  @override
  void initState() {
    super.initState();
    try {
      _fetchFields();
    } on Exception catch (e) {
      print('Error: $e');
    }
  }

  ApiRequest apiRequest=ApiRequest();

  Future<void> _fetchFields() async {
    try {
      Map<String, dynamic> query = {
        "url": "http://localhost:8080/api/fields",
      };
      await apiRequest.getRequest(query).then((response) {
        print(response.data["data"]);
        if (response.statusCode==200) {
          setState(() {
            fields = response.data["data"];
            filteredFields = fields;
          });
        } else {
          print('Error: ${response.data['msg']}');
        }

      });
    } catch (error) {
      print('Error fetching fields data: $error');
    }
  }

  Future<List<String>> _fetchAutocompleteList(String keyword) async {
    List<String> autoCompleteKeywords = [];
    if (keyword.isEmpty) {
      return autoCompleteKeywords;
    }
    Map<String, dynamic> autocompleteQuery = {
      "url": "http://localhost:8080/api/fields",
      "parameters": {
        "text": keyword
      },
      // "token": ApiKey.YELP_API_KEY
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

  void filterFields(String query) {
    setState(() {
      searchQuery = query;
      filteredFields = fields
          .where((field) =>
      field['name'] != null && field['name'].toLowerCase().contains(query.toLowerCase())).toList();
      sortFields();
    });
  }

  void sortFields() {
    if (sortBy == 'Rating') {
      filteredFields
          .sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else if (sortBy == 'Difficulty') {
      filteredFields.sort(
              (a, b) => (a['difficulty'] ?? '').compareTo(b['difficulty'] ?? ''));
    } else if (sortBy == 'Estimated Time') {
      filteredFields.sort((a, b) =>
          (a['estimatedTime'] ?? '').compareTo(b['estimatedTime'] ?? ''));
    }
  }

  void _searchByKeyword(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filteredFields = fields;
      } else {
        filteredFields = fields.where((item) {
          return item['name'].toLowerCase().contains(keyword.toLowerCase()) ||
              item['description'].toLowerCase().contains(keyword.toLowerCase());
        }).toList();
      }
      _fetchFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppStyle.barBackgroundColor,
        elevation: 0.0,
        title: const Text(
          'Attractions',
          style: AppStyle.barHeadingFont2,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                        onChanged: filterFields,
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
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
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
                            style: AppStyle.bodyTextFont,
                            value: sortBy,
                            onChanged: (value) {
                              setState(() {
                                sortBy = value!;
                                sortFields();
                              });
                            },
                            items: <String>['All', 'Rating', 'Difficulty', 'Estimated Time']
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
                            style: AppStyle.bodyTextFont,
                            value: 'All',
                            onChanged: (value) {
                              setState(() {
                              });
                            },
                            items: <String>["All"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 20),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredFields.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredFields.length,
              itemBuilder: (context, index) {
                final field = filteredFields[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FieldDetailPage(field: field),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SizedBox(
                              height: 300,
                              width: 380,
                              child: Image.network(field['imageUrl'] ?? '',
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('assets/placeholder.png');
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(field['name'] ?? 'No Name', style: AppStyle.headingFont),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    StarScore(
                                      score: field['rating'],
                                      star: Star(
                                          fillColor: Colors.yellow,
                                          emptyColor: Colors.grey.withAlpha(88),
                                          size: 12
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text('${field['distance'] ?? 'No Distance'} km'),
                                    const SizedBox(width: 16),
                                    Text('${field['difficulty'] ?? 'No Difficulty'}'),

                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text('Estimated Time: ${field['estimated_time'] ?? 'No Estimated Time'}'),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: AppStyle.barBackgroundColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(field['location'] ?? 'No Location'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
