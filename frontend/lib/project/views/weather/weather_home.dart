import 'package:flutter/cupertino.dart';
import 'package:frontend/project/views/weather/recommendation_card.dart';
import 'package:frontend/project/views/weather/weather_card.dart';

class WeatherHome extends StatelessWidget {
  Map<String, dynamic> weatherData;
  Map<String, dynamic> recommendationData;

  WeatherHome({super.key, required this.weatherData, required this.recommendationData});

  @override
  Widget build(BuildContext context) {
    bool badWeather =
        recommendationData.isEmpty || recommendationData['fields']==null;

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
                  recommendationData['advice'] ??
                      'No recommendations available.',
                  style: const TextStyle(fontSize: 16),
                ),
                if (recommendationData.isNotEmpty)
                  for (var location in recommendationData['fields'])
                    RecommendationCard(location: location),
              ],
            ),
        ],
      ),
    );
  }
}