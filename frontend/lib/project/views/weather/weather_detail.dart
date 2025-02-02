import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../constants/api_request.dart';
import 'weather_detail_item.dart';
import 'clothing_recommendation.dart';
import '../../constants/app_style.dart';

class WeatherDetailPage extends StatefulWidget {
  final Map<String, dynamic> weatherData;

  const WeatherDetailPage({super.key, required this.weatherData});
  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  ApiRequest apiRequest = ApiRequest();
  late Map<String, String> clothingRecommendationData;
  String clothingRecommendation="";
  late String clothingType;
  late String svgString;
  bool loading = false;

  Future<void> _fetchRecommendationFromGPT() async {
    Map<String, dynamic> searchQuery = {
      "url": "http://localhost:8080/weather-recommendation",
      "parameters": {
        "city": "vancouver"
      }
    };
    await apiRequest.getRequest(searchQuery).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        clothingRecommendation = response.data["data"]["recommendation"];
      } else {
        throw Exception('Failed to fetch recommendation');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRecommendationFromGPT();
    setState(() {
      clothingRecommendationData =
          recommendClothing(widget.weatherData);
      clothingType = clothingRecommendationData['iconPath']!;
      svgString = getClothingSvg(clothingType);
    });
  }


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

  String getClothingSvg(String clothingType) {
    switch (clothingType) {
      case 'tshirt':
        return '''
          <svg t="1718390410322" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1538" width="200" height="200"><path d="M341.32992 870.4h341.34016v51.2H341.32992zM648.52992 102.4L512 238.94016 375.47008 102.4zM486.4 285.73696V819.2H307.2V528.09728l-83.27168 152.64768L102.4 614.4l204.8-375.45984h68.27008V174.7968zM716.8 238.94016h-68.27008V174.7968L537.6 285.73696v89.73312h110.92992v51.2H537.6V819.2H716.8V528.09728l83.27168 152.64768L921.6 614.4z" p-id="1539"></path></svg>
        ''';
      case 'jacket':
        return '''
          <svg t="1718390472474" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1693" width="200" height="200"><path d="M799.20128 218.9312c-26.53184-26.53184-79.0016-48.26112-116.5312-48.26112h-102.4c0 37.7344-30.5664 68.25984-68.27008 68.25984s-68.27008-30.52544-68.27008-68.25984h-102.4c-37.5296 0-89.99936 21.72928-116.5312 48.26112L102.4 341.32992l136.52992 136.54016 34.14016-34.14016v409.6h477.85984v-409.6l34.14016 34.14016L921.6 341.32992 799.20128 218.9312z m-116.5312 566.13888H341.32992V716.8h341.34016v68.27008z m0-506.14272v369.60256H341.32992V278.92736l-102.4 102.4-39.99744-39.99744 102.4-102.4h93.07136c18.13504 31.13984 47.93344 54.46656 83.46624 63.7952V409.6h68.25984V302.72512c35.57376-9.32864 65.34144-32.65536 83.46624-63.7952h93.07136l102.4 102.4-39.99744 39.99744-102.4-102.4z" p-id="1694"></path></svg>
        ''';
    // Add cases for other clothing types with their respective SVG strings
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppStyle.barBackgroundColor,
        elevation: 0.0,
        title: const Text(
          'Weather',
          style: AppStyle.barHeadingFont2,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(widget.weatherData['city'], style: AppStyle.tempBigFont,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getWeatherIcon(widget.weatherData['weather_type']),
                  color: AppStyle.barBackgroundColor,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Text(
                    '${double.parse(
                        widget.weatherData['temperature'].toString())}°C',
                    style: AppStyle.tempBigFont
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.weatherData['weather_condition'],
              style: AppStyle.tempFont,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WeatherDetailItem(
                          label: 'Feels like',
                          value: '${double.parse(widget
                              .weatherData['feels_like'].toString())}°C',
                        ),
                        const SizedBox(width: 90),
                        WeatherDetailItem(
                          label: 'Wind speed',
                          value: '${double.parse(widget
                              .weatherData['wind_speed'].toString())} km/h',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WeatherDetailItem(
                          label: 'Sunrise',
                          value: DateFormat('HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(
                                    widget.weatherData['sunrise'].toString()) *
                                    1000),
                          ),
                        ),
                        const SizedBox(width: 90),
                        WeatherDetailItem(
                          label: 'Sunset',
                          value: DateFormat('HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(
                                    widget.weatherData['sunset'].toString()) *
                                    1000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WeatherDetailItem(
                          label: 'Humidity',
                          value: '${int.parse(widget.weatherData['humidity']
                              .toString())}%',
                        ),
                      ],
                    ),
                  ],
                )
            ),
            const SizedBox(height: 32),
            const Text(
              'Clothing Recommendation',
              style: AppStyle.themeHeadingFont,
            ),
            const SizedBox(height: 12),
            svgString.isNotEmpty
                ? SvgPicture.string(
              svgString,
              width: 50,
              height: 50,
              color: AppStyle.barBackgroundColor,
            )
                : Container(),
            const SizedBox(height: 12),

            clothingRecommendation == ''
            ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: AppStyle.barBackgroundColor,
              )
            ): SizedBox(
              width: 320,
              child:Text(
                clothingRecommendation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}