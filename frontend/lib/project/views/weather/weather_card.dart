import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/project/views/weather/weather_detail.dart';
import '../../constants/app_style.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherCard({super.key, required this.weatherData});

  IconData getWeatherIcon(String? weatherType) {
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
                  Text(
                    weatherData['city'] ?? 'Unknown city',
                    style: AppStyle.bigHeadingFont,
                  ),
                  Row(
                    children: [
                      Icon(
                        getWeatherIcon(weatherData['weather_type']),
                        size: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${weatherData['temperature'] ?? 'N/A'}°C',
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 24, color: AppStyle.barBackgroundColor),
            ],
          ),
        ),
      ),
    );
  }
}
