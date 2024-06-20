Map<String, String> recommendClothing(Map<String, dynamic> weatherData) {
  double temperature = double.parse(weatherData['temperature'].toString());
  int humidity = int.parse(weatherData['humidity'].toString());
  String weatherType = weatherData['weather_type'];

  String recommendation;
  String iconPath;

  if (temperature > 30) {
    recommendation =
        "Wear light and breathable clothing, such as T-shirts and shorts. Stay hydrated.";
    iconPath = "tshirt";
  } else if (temperature > 20) {
    recommendation =
        "Wear lightweight clothing, such as T-shirts and long pants. Consider bringing a light jacket.";
    iconPath = "tshirt";
  } else if (temperature > 10) {
    recommendation =
        "Wear warm clothing, such as sweaters and jackets. Be mindful of the temperature difference between morning and evening.";
    iconPath = "jacket";
  } else {
    recommendation =
        "Wear heavy clothing, such as coats, hats, and gloves. Ensure to stay warm.";
    iconPath = "coat";
  }

  if (humidity > 80) {
    recommendation +=
        " The humidity is high. Choose breathable clothing to stay dry.";
  }

  switch (weatherType) {
    case 'rain':
    case 'shower_rain':
      recommendation +=
          " It is raining. Please bring an umbrella and wear waterproof clothing and shoes.";
      iconPath = "raincoat";
      break;
    case 'snow':
      recommendation +=
          " It is snowing. Wear waterproof and warm clothing. Be cautious of slippery surfaces.";
      iconPath = "snowcoat";
      break;
    case 'thunderstorm':
      recommendation +=
          " There is a thunderstorm. Avoid going outside to ensure safety.";
      iconPath = "thunderstorm";
      break;
    case 'mist':
      recommendation +=
          " There is mist. Drive safely and wear bright-colored clothing to increase visibility.";
      iconPath = "mist";
      break;
    default:
      break;
  }

  return {"recommendation": recommendation, "iconPath": iconPath};
}
