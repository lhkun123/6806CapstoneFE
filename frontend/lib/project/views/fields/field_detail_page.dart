import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../constants/app_style.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';

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

    print(imageUrls);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppStyle.barBackgroundColor,
        elevation: 0.0,
        title: Text(field['name'] ?? 'Field Details', style: AppStyle.barHeadingFont2),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppStyle.barBackgroundColor, size: 21),
                        const SizedBox(width: 5),
                        Text(field['location'] ?? 'No Location', style: AppStyle.themeTextFont),
                      ],
                    ),
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
                    const SizedBox(height: 32),
                    const Text('Description', style: AppStyle.themeBigTextFont),
                    const SizedBox(height: 5),
                    Text(field['description'] ?? 'No Description', style: AppStyle.bodyTextFont),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
