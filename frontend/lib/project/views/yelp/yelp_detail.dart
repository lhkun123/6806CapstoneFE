import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/project/constants/app_style.dart';
import '../../constants/api_key.dart';
import '../../constants/api_request.dart';

class YelpDetail extends StatefulWidget {
  String alias;
  YelpDetail({super.key, required this.alias});

  @override
  _YelpDetailState createState() => _YelpDetailState();
}

class _YelpDetailState extends State<YelpDetail> {
  late Map<String, dynamic> query = {
    "url": "https://api.yelp.com/v3/businesses/${widget.alias}",
    "token": ApiKey.YELP_API_KEY
  };
  ApiRequest apiRequest = ApiRequest();
  Map<String, dynamic>? detail;

  @override
  void initState() {
    super.initState();
    try {
      print(query);
      _fetchDetail();
    } on Exception catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    detail?.clear();
    super.dispose();
  }

  void _fetchDetail() async {
    await apiRequest.getRequest(query).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          detail = response.data;
        });
      } else {
        throw Exception('Failed to fetch detail!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(detail?["name"] ?? 'Loading...', style: AppStyle.bigheadingFont),
      ),
      body: detail == null
          ? Center(
        child: CircularProgressIndicator(
          color: AppStyle.indicatorColor,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["location"]["display_address"].join(),
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Category',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["categories"][0]["title"],
                          style: AppStyle.bodyTextFont,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phone',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["display_phone"] == "" ? "Not Available" : detail!["display_phone"],
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Price',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["price"],
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          detail!["hours"][0]["is_open_now"] ? "Open Now" : "Closed",
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Visit Yelp for more',
                          style: AppStyle.subheadingFont,
                        ),
                        Text(
                          'Business Link',
                          style: AppStyle.bodyTextFont,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.heart_solid),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Share to:'),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.facebook),
                          color: Colors.blue,
                          onPressed: () {
                            // Handle Facebook share
                          },
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.twitter),
                          color: Colors.blue,
                          onPressed: () {
                            // Handle Twitter share
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
