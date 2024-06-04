import 'package:flutter/material.dart';

import 'package:frontend/project/views/yelp/yelp_detail.dart';
import 'package:frontend/project/views/yelp/yelp_map.dart';
import 'package:frontend/project/views/yelp/yelp_review.dart';
import '../../constants/app_style.dart';
class YelpOverview extends StatefulWidget {
  String alias;
  double latitude, longitude;
  YelpOverview({super.key, required this.alias,required this.latitude, required this.longitude});
  @override
  _YelpOverViewState createState() =>   _YelpOverViewState();
}

class _YelpOverViewState  extends State<YelpOverview> {
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,  // Total number of tabs
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: TabBarView(
            children: [
              YelpDetail(alias: widget.alias), // Content of tab 1
              YelpMap(latitude: widget.latitude,longitude: widget.longitude), // Content of tab 2
              YelpReview(), // Content of tab 3
            ],
          ),
          bottomNavigationBar: const Material(
            child: TabBar(
              labelColor: AppStyle.labelColor, // Color of the selected tab
              unselectedLabelColor: AppStyle.unselectedLabelColor, // Color of the unselected ta
              indicatorColor: AppStyle.indicatorColor,
              tabs: [
                Tab(icon: Icon(Icons.info)),
                Tab(icon: Icon(IconData(0xe3ac, fontFamily: 'MaterialIcons'))),
                Tab(icon: Icon(Icons.reviews)),
              ],
              // Optionally add indicators or labels as needed
            ),
          ),
        ),
      ),
    );
  }
}