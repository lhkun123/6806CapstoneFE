import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/views/weather/weather.dart';

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
          bottomNavigationBar: Material(
            color: Theme.of(context).canvasColor,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.food_bank)),
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