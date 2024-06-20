import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'field_detail_page.dart';

class FieldsListPage extends StatefulWidget {
  @override
  _FieldsListPageState createState() => _FieldsListPageState();
}

class _FieldsListPageState extends State<FieldsListPage> {
  List<dynamic> fields = [];
  List<dynamic> filteredFields = [];
  String searchQuery = '';
  String sortBy = 'All';

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  Future<void> fetchFields() async {
    try {
      final response =
      await http.get(Uri.parse('http://localhost:8080/api/fields'));
      final data = json.decode(response.body);
      if (data['code'] == '200') {
        setState(() {
          fields = data['data']; // 这里提取data字段
          filteredFields = fields;
        });
      } else {
        print('Error: ${data['msg']}');
      }
    } catch (error) {
      print('Error fetching fields data: $error');
    }
  }

  void filterFields(String query) {
    setState(() {
      searchQuery = query;
      filteredFields = fields
          .where((field) =>
      field['name'] != null &&
          field['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fields List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                ),
                onChanged: filterFields,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sort by:'),
                DropdownButton<String>(
                  value: sortBy,
                  items: [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Rating', child: Text('Rating')),
                    DropdownMenuItem(
                        value: 'Difficulty', child: Text('Difficulty')),
                    DropdownMenuItem(
                        value: 'Estimated Time', child: Text('Estimated Time')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                      sortFields();
                    });
                  },
                ),
                Text('Category:'),
                DropdownButton<String>(
                  value: 'All',
                  items: [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    // Add other categories here
                  ],
                  onChanged: (value) {
                    // Handle category change
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredFields.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredFields.length,
              itemBuilder: (context, index) {
                final field = filteredFields[index];
                return Card(
                  margin: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (field['imageUrl'] != null &&
                            field['imageUrl'].isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(field['imageUrl']),
                          ),
                        SizedBox(height: 8),
                        Text(field['name'] ?? 'No Name',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(field['location'] ?? 'No Location'),
                        Text('Rating: ${field['rating'] ?? 'No Rating'}'),
                        Text(
                            'Difficulty: ${field['difficulty'] ?? 'No Difficulty'}'),
                        Text(
                            'Distance: ${field['distance'] ?? 'No Distance'} km'),
                        Text(
                            'Estimated Time: ${field['estimatedTime'] ?? 'No Estimated Time'}'),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FieldDetailPage(field: field),
                                ),
                              );
                            },
                            child: const Text('View Details'),
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
