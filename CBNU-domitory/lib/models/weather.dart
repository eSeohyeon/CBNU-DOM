class Weather {
  final String temperature;
  final String feelsLike;
  final String description;

  Weather({required this.temperature, required this.feelsLike, required this.description});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['main']['temp'].toString(),
      feelsLike: json['main']['feels_like'].toString(),
      description: json['weather'][0]['description'],
    );
  }
}