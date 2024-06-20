import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../fields/home_field_detail_page.dart';

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  const RecommendationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(location['image_url'] ?? '',
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/placeholder.png'); // 使用占位符图片
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location['name'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(location['location'] ?? 'No Location'),
                Text('Rating: ${location['rating'] ?? 'No Rating'}'),
                Text(
                    'Difficulty: ${location['difficulty'] ?? 'No Difficulty'}'),
                Text('Distance: ${location['distance'] ?? 'No Distance'} km'),
                Text(
                    'Estimated Time: ${location['estimated_time'] ?? 'No Estimated Time'}'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeFieldDetailPage(field: location),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
