import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/profile/profile.dart';
import 'package:frontend/project/views/yelp/yelp_search.dart';
import 'package:frontend/project/views/fields/fields_list_page.dart';
import 'package:frontend/project/views/fields/field_detail_page.dart';
import 'package:frontend/project/views/home/home_field_detail_page.dart';

import 'weatherDetail/weather_detail.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

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
      setState(() {
        weatherData = data;
      });
      fetchRecommendationData(data['city']);
    } catch (error) {
      print('Error fetching weather data: $error');
    }
  }

  Future<void> fetchRecommendationData(String city) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/recommendation?city=$city'));
      final data = json.decode(response.body);
      setState(() {
        recommendationData = data;
        print("Recommendation data: $recommendationData");
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
                    recommendationData: recommendationData), // 显示WeatherHome内容
            YelpSearch(), // YelpSearch tab content
            FieldsListPage(), // FieldsListPage tab content
            Profile(), // Profile tab content
          ],
        ),
        bottomNavigationBar: const Material(
          color: AppStyle.BarBackgroundColor,
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

class WeatherHome extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final Map<String, dynamic>? recommendationData;

  WeatherHome({required this.weatherData, required this.recommendationData});

  @override
  Widget build(BuildContext context) {
    bool badWeather =
        recommendationData == null || recommendationData!['fields'].isEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          WeatherCard(weatherData: weatherData),
          const SizedBox(height: 10),
          if (badWeather)
            Column(
              children: [
                const Text("The weather is not good for outdoor activities.",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("You can choose indoor activities.",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Image.asset('assets/image.png'), // 确保你的图片路径正确
              ],
            )
          else
            Column(
              children: [
                const Text("Today's Recommendation",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  recommendationData?['advice'] ??
                      'No recommendations available.',
                  style: const TextStyle(fontSize: 16),
                ),
                if (recommendationData != null)
                  for (var location in recommendationData!['fields'])
                    RecommendationCard(location: location),
              ],
            ),
        ],
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherCard({required this.weatherData});

  IconData getWeatherIcon(String weatherType) {
    switch (weatherType) {
      case 'clear_sky':
        return Icons.wb_sunny;
      case 'few_clouds':
        return Icons.cloud_queue;
      case 'scattered_clouds':
      case 'broken_clouds':
      case 'overcast_clouds':
        return Icons.cloud;
      case 'shower_rain':
      case 'rain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WeatherDetailPage(weatherData: weatherData),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weatherData['city'],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(
                        getWeatherIcon(weatherData['weather_type']),
                        size: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${weatherData['temperature']}°C',
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 24, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> location;

  const RecommendationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(location['image_url'] ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location['name'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(location['location'] ?? 'No Location'),
                Text('Rating: ${location['rating'] ?? 'No Rating'}'),
                Text(
                    'Difficulty: ${location['difficulty'] ?? 'No Difficulty'}'),
                Text('Distance: ${location['distance'] ?? 'No Distance'} km'),
                Text(
                    'Estimated Time: ${location['estimated_time'] ?? 'No Estimated Time'}'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeFieldDetailPage(
                              field: location), // 确保此处导入了HomeFieldDetailPage
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
