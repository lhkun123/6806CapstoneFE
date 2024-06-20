import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/profile/profile.dart';
import 'package:frontend/project/views/yelp/yelp_search.dart';
import 'package:frontend/project/views/fields/fields_list_page.dart';
import '../weather/weather_home.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? recommendationData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/weather?city=Vancouver'));
      final data = json.decode(response.body);
      print('Weather data: $data'); // 添加日志
      setState(() {
        weatherData = data['data'];
      });
      fetchRecommendationData(data['data']['city']);
    } catch (error) {
      print('Error fetching weather data: $error');
    }
  }

  Future<void> fetchRecommendationData(String city) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/recommendation?city=$city'));
      final data = json.decode(response.body);
      print('Recommendation data: $data'); // 添加日志
      setState(() {
        recommendationData = data['data'];
      });
    } catch (error) {
      print('Error fetching recommendation data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Total number of tabs
      child: Scaffold(
        body: TabBarView(
          children: [
            weatherData == null
                ? Center(child: CircularProgressIndicator())
                : WeatherHome(
              weatherData: weatherData!,
              recommendationData: recommendationData,
            ), // 显示WeatherHome内容
            YelpSearch(), // YelpSearch tab content
            FieldsListPage(), // FieldsListPage tab content
            Profile(), // Profile tab content
          ],
        ),
        bottomNavigationBar: const Material(
          color: AppStyle.barBackgroundColor, // 确保引用的颜色值是正确的
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
    );
  }
}


