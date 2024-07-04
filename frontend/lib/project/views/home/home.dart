import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/profile/profile.dart';
import 'package:frontend/project/views/yelp/yelp_search.dart';
import 'package:frontend/project/views/fields/fields_list_page.dart';
import '../weather/weather_home.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  Map<String, dynamic> weatherData={};
  Map<String, dynamic> recommendationData={};
  ApiRequest apiRequest=ApiRequest();
  late TabController _tabController;

  final List<String> _titles = [
    'Home',
    'Entertainment',
    'Attractions',
    'Profile'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,  // Total number of tabs
        child:  weatherData.isEmpty ? const Center(child: CircularProgressIndicator()) :
        Scaffold(
          appBar: AppBar(
            backgroundColor: AppStyle.barBackgroundColor,
            elevation: 0.0,
            title: Text(_titles[_tabController.index], style: AppStyle.barHeadingFont2),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            controller: _tabController,
            children: [
              WeatherHome(
                  weatherData: weatherData,
                  recommendationData: recommendationData),
              const YelpSearch(), // YelpSearch tab content
              FieldsListPage(), // FieldsListPage tab content
              const Profile(), // Profile tab content
            ],
          ),
          bottomNavigationBar: Material(
            color: AppStyle.barBackgroundColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppStyle.primaryColor, // Color of the selected tab
              unselectedLabelColor: AppStyle.unselectedLabelColor, // Color of the unselected tab
              indicatorColor: AppStyle.barBackgroundColor,
              tabs: const [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.restaurant)),
                Tab(icon: Icon(Icons.forest)),
                Tab(icon: Icon(Icons.person)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
