import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/views/profile/profile.dart';
import 'package:frontend/project/views/weather/weather.dart';
import '../../constants/app_style.dart';
import '../yelp/yelp_search.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,  // Total number of tabs
        child: Scaffold(
          appBar: AppBar(

          ),
          body: const TabBarView(
            children: [
              Icon(Icons.home),
              YelpSearch(), // Content of tab 1
              Weather(), // Content of tab 2
              Profile(),
            ],
          ),
          bottomNavigationBar: const Material(
            color: AppStyle.BarBackgroundColor,
            child: TabBar(
              labelColor: AppStyle.labelColor, // Color of the selected tab
              unselectedLabelColor: AppStyle.unselectedLabelColor, // Color of the unselected ta
              indicatorColor: AppStyle.indicatorColor,
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.business)),
                Tab(icon: Icon(Icons.sunny_snowing)),
                Tab(icon: Icon(Icons.person)),
              ],
              // Optionally add indicators or labels as needed
            ),
          ),
        ),
      ),
    );
  }
}