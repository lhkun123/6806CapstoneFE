import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/constants/app_style.dart';

import 'package:frontend/project/views/yelp/yelp_search.dart';
import 'package:frontend/project/views/fields/fields_list_page.dart';
import '../user/profile.dart';
import '../weather/weather_home.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> weatherData={};
  Map<String, dynamic> recommendationData={};
  ApiRequest apiRequest=ApiRequest();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      Map<String, dynamic> query = {
        "url": "http://localhost:8080/weather",
        "parameters":{
            "city":"Vancouver"
        }
      };
      await apiRequest.getRequest(query).then((response) {
        if(response.statusCode == 200){
          setState(() {
            weatherData = response.data["data"];
          });
        }
        fetchRecommendationData(response.data["data"]['city']);
      });

    } catch (error) {
      print('Error fetching weather data: $error');
    }
  }

  Future<void> fetchRecommendationData(String city) async {
    try {
      Map<String, dynamic> query = {
        "url": "http://localhost:8080/recommendation",
        "parameters":{
          "city":city
        }
      };
      await apiRequest.getRequest(query).then((response) {
        if(response.statusCode == 200){
          setState(() {
            recommendationData = response.data["data"];
          });
        }
      });
    } catch (error) {
      print('Error fetching recommendation data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,  // Total number of tabs
        child:  weatherData.isEmpty ? const Center(child: CircularProgressIndicator()) :Scaffold(
        body: TabBarView(
          children: [
                 WeatherHome(
                    weatherData: weatherData,
                    recommendationData: recommendationData), // 显示WeatherHome内容
            const YelpSearch(), // YelpSearch tab content
            FieldsListPage(), // FieldsListPage tab content
            const Profile(), // Profile tab content
          ],
        ),
        bottomNavigationBar: const Material(
          color: AppStyle.barBackgroundColor,
          child: TabBar(
            labelColor: AppStyle.labelColor, // Color of the selected tab
            unselectedLabelColor:
                AppStyle.unselectedLabelColor, // Color of the unselected tab
            indicatorColor: AppStyle.indicatorColor,
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.business)),
              Tab(icon: Icon(Icons.wb_sunny)),
              Tab(icon: Icon(Icons.person)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
