import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../fields/field_detail_page.dart';
import '../../constants/app_style.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> field;
  const RecommendationCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
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
        elevation: 2.0,
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
  }
}
