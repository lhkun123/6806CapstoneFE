import 'package:flutter/material.dart';
import 'package:frontend/project/views/yelp/yelp_detail.dart';
import 'package:frontend/project/views/yelp/yelp_map.dart';
import 'package:frontend/project/views/yelp/yelp_review.dart';
import '../../constants/app_style.dart';

class YelpOverview extends StatefulWidget {
  String alias, title, location;
  double latitude, longitude;
  YelpOverview({super.key, required this.alias,required this.latitude, required this.longitude, required this.title,required this.location});
  @override
  _YelpOverviewState createState() => _YelpOverviewState();
}

class _YelpOverviewState extends State<YelpOverview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppStyle.barBackgroundColor,
          elevation: 0.0,
          title: Text(widget.title, style: AppStyle.barHeadingFont2),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ) ,
      body: DefaultTabController(
        length: 3, // Total number of tabs
        child: Scaffold(
          body: TabBarView(
            children: [
              YelpDetail(alias: widget.alias, title: widget.title), // Content of tab 1
              YelpMap(
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                  location: widget.location,
                  title: widget.title), // Content of tab 2
              YelpReview(alias: widget.alias, title: widget.title), // Content of tab 3
            ],
          ),
          bottomNavigationBar: const Material(
            color: AppStyle.barBackgroundColor,
            child: TabBar(
              labelColor: AppStyle.primaryColor, // Color of the selected tab
              unselectedLabelColor:
                  AppStyle.unselectedLabelColor, // Color of the unselected tab
              indicatorColor: AppStyle.barBackgroundColor,
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
    )
    );
  }
}
