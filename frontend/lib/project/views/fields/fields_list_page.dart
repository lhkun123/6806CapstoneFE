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
      setState(() {
        fields = data;
      });
    } catch (error) {
      print('Error fetching fields data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fields.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
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
                                fontSize: 20, fontWeight: FontWeight.bold)),
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
                            child: Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
