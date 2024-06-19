import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/project/constants/app_style.dart';
import '../../constants/api_key.dart';
import '../../constants/api_request.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  List<String> imgList = [];
  CarouselController buttonCarouselController = CarouselController();

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
          print(detail);
          for (var i = 0; i < detail!["photos"].length; i++) {
            imgList.add(detail!["photos"][i]);
          }
          print(imgList);
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
        title: Text(detail?["name"] ?? 'Loading...', style: AppStyle.bigHeadingFont),
        centerTitle: true
      ),
      body: detail == null
          ? const Center(
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
                  icon: const Icon(CupertinoIcons.heart_solid, color: AppStyle.barBackgroundColor),
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
                          color: AppStyle.barBackgroundColor,
                          onPressed: () {
                            // Handle Facebook share
                          },
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.twitter),
                          color: AppStyle.barBackgroundColor,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => buttonCarouselController.previousPage(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.linear,
                    ),
                    child: const Icon(Icons.arrow_back_ios,color: AppStyle.barBackgroundColor),
                  ),
                  Expanded(
                    child: CarouselSlider(
                      items: imgList.map((item) => Center(
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                          width: 600,
                          height: 600,
                        ),
                      )).toList(),
                      carouselController: buttonCarouselController,
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                        aspectRatio: 1.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => buttonCarouselController.nextPage(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.linear,
                    ),
                    child: const Icon(Icons.arrow_forward_ios,color: AppStyle.barBackgroundColor),

                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

