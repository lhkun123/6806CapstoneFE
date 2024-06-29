import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_star/star.dart';
import 'package:flutter_star/star_score.dart';
import 'package:frontend/project/constants/app_style.dart';
import '../../constants/api_key.dart';
import '../../constants/api_request.dart';

class YelpReview extends StatefulWidget {
  final String alias, title;
  const YelpReview({super.key, required this.alias, required this.title});

  @override
  State<YelpReview> createState() => _YelpReviewState();
}

class _YelpReviewState extends State<YelpReview> {
  late Map<String, dynamic> query = {
    "url": "https://api.yelp.com/v3/businesses/${widget.alias}/reviews",
    "parameters": {
      "limit": 20,
      "sort_by": "yelp_sort"
    },
    "token": ApiKey.YELP_API_KEY
  };
  late List<dynamic> reviews = [];
  ApiRequest apiRequest = ApiRequest();

  @override
  void initState() {
    _fetchReviews();
    super.initState();
  }

  void _fetchReviews() async {
    await apiRequest.getRequest(query).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          reviews = response.data["reviews"] ?? [];
        });
      } else {
        throw Exception('Failed to fetch reviews');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reviews.isEmpty
          ? const Center(
        child: Text(
          "No review available",
          style: AppStyle.bodyTextFont,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        review["user"]["image_url"] ?? '',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.account_circle, size: 50),
                      ),
                      const SizedBox(width: 8), // Adjust spacing between image and name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review["user"]["name"] ?? 'Anonymous',
                              style: AppStyle.subheadingFont,
                            ),
                            const SizedBox(height: 4),
                            StarScore(
                              score: review["rating"].toDouble(),
                              star: Star(
                                  fillColor: Colors.yellow,
                                  emptyColor: Colors.grey.withAlpha(88)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review["text"] ?? '',
                    style: AppStyle.bodyTextFont,
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
