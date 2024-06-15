import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FieldDetailPage extends StatelessWidget {
  final Map<String, dynamic> field;

  FieldDetailPage({required this.field});

  @override
  Widget build(BuildContext context) {
    print('Field Detail Data: $field'); // 添加打印语句

    List<String> imageUrls = [];
    if (field['imageUrl'] != null) imageUrls.add(field['imageUrl']);
    if (field['previewImageUrl1'] != null)
      imageUrls.add(field['previewImageUrl1']);
    if (field['previewImageUrl2'] != null)
      imageUrls.add(field['previewImageUrl2']);
    if (field['previewImageUrl3'] != null)
      imageUrls.add(field['previewImageUrl3']);
    if (field['previewImageUrl4'] != null)
      imageUrls.add(field['previewImageUrl4']);
    if (field['previewImageUrl5'] != null)
      imageUrls.add(field['previewImageUrl5']);

    return Scaffold(
      appBar: AppBar(
        title: Text(field['name'] ?? 'Field Details'),
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
              SizedBox(height: 16),
              Text(field['name'] ?? 'No Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(field['location'] ?? 'No Location'),
              Text('Rating: ${field['rating'] ?? 'No Rating'}'),
              Text('Difficulty: ${field['difficulty'] ?? 'No Difficulty'}'),
              Text('Distance: ${field['distance'] ?? 'No Distance'} km'),
              Text(
                  'Estimated Time: ${field['estimatedTime'] ?? 'No Estimated Time'}'),
              SizedBox(height: 16),
              Text('Description', style: TextStyle(fontSize: 20)),
              Text(field['description'] ?? 'No Description'),
            ],
          ),
        ),
      ),
    );
  }
}
