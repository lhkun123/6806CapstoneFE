import 'package:flutter/cupertino.dart';
import 'package:frontend/project/views/weather/recommendation_card.dart';
import 'package:frontend/project/views/weather/weather_card.dart';
import '../../constants/app_style.dart';

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
                const Text("The weather is not good for outdoor activities.", style: AppStyle.bigHeadingFont),
                const SizedBox(height: 10),
                const Text("You can choose indoor activities.", style: AppStyle.headingFont),
                const SizedBox(height: 10),
                Image.asset('assets/image.png'),
              ],
            )
          else
            Column(
              children: [
                const Text("Today's Recommendation", style: AppStyle.bigHeadingFont),
                const SizedBox(height: 10),
                Text(
                  recommendationData['advice'] ??
                      'No recommendations available.',
                  style: AppStyle.bodyTextFont,
                ),
                if (recommendationData.isNotEmpty)
                  for (var field in recommendationData['fields'])
                    RecommendationCard(field: field),
              ],
            ),
        ],
      ),
    );
  }
}