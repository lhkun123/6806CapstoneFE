import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeFieldDetailPage extends StatelessWidget {
  final Map<String, dynamic> field;

  HomeFieldDetailPage({required this.field});

  @override
  Widget build(BuildContext context) {
    print('Field Detail Data: $field'); // 添加打印语句

    // 打印所有图片URL
    print('Image URLs:');
    for (int i = 1; i <= 5; i++) {
      final url = field['preview_image_url$i'];
      if (url != null) {
        print(url);
      }
    }

    List<String> imageUrls = [];
    if (field['image_url'] != null) imageUrls.add(field['image_url']);
    for (int i = 1; i <= 5; i++) {
      final url = field['preview_image_url$i'];
      if (url != null) {
        imageUrls.add(url);
      }
    }

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
