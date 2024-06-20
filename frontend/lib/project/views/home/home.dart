import 'package:flutter/material.dart';
import 'package:frontend/project/constants/api_request.dart';
import 'package:frontend/project/constants/app_style.dart';
import 'package:frontend/project/views/profile/profile.dart';
import 'package:frontend/project/views/yelp/yelp_search.dart';
import 'package:frontend/project/views/fields/fields_list_page.dart';
import '../fields/home_field_detail_page.dart';
import '../weather/weather_detail.dart';

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
            weatherData = response.data;
          });
        }
        fetchRecommendationData(response.data['city']);
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
            recommendationData = response.data;
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
        child: Scaffold(
        body: TabBarView(
          children: [
            weatherData == null
                ? const Center(child: CircularProgressIndicator())
                : WeatherHome(
                    weatherData: weatherData!,
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

class WeatherHome extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final Map<String, dynamic>? recommendationData;

  WeatherHome({super.key, required this.weatherData, required this.recommendationData});

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

  const WeatherCard({super.key, required this.weatherData});

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
                          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(
                        getWeatherIcon(weatherData['weather_type']),
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${weatherData['temperature']}°C',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 24, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> location;

  const RecommendationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
