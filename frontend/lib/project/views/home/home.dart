import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/views/weather/weather.dart';

import '../../constants/app_style.dart';
import '../yelp/yelp_search.dart';



class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,  // Total number of tabs

        child: Scaffold(
          appBar: AppBar(

          ),
          body: const TabBarView(
            children: [
              YelpSearch(), // Content of tab 1
              Weather(), // Content of tab 2
              Icon(Icons.settings), // Content of tab 3
            ],
          ),
          bottomNavigationBar: const Material(
            child: TabBar(
              labelColor: AppStyle.labelColor, // Color of the selected tab
              unselectedLabelColor: AppStyle.unselectedLabelColor, // Color of the unselected ta
              indicatorColor: AppStyle.indicatorColor,
              tabs: [
                Tab(icon: Icon(Icons.business)),
                Tab(icon: Icon(Icons.sunny_snowing)),
                Tab(icon: Icon(Icons.settings)),
              ],
              // Optionally add indicators or labels as needed
            ),
          ),
        ),
      ),
    );
  }
}