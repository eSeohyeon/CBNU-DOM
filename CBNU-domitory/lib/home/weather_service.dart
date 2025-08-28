import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:untitled/themes/colors.dart';

class WeatherData {
  final double temperature;
  final double windSpeed;
  final double humidity;
  final String description;
  final double feelsLike;

  final Color gradientStartColor;
  final Color gradientEndColor;
  final String iconPath;

  // 기상청 encode key : uYw4a9z1phdIEnV5kw1h9yEMUx4hzLfnGj39uqc0uUvR%2B999QeTF8yHecMuc3c9zSvHvcgEl6I027rCYJFYbNQ%3D%3D | 발급일: 2025-08-07

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.description,
    required this.feelsLike,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.iconPath
  });
}

class WeatherService {
  static const String apiKey = 'uYw4a9z1phdIEnV5kw1h9yEMUx4hzLfnGj39uqc0uUvR%2B999QeTF8yHecMuc3c9zSvHvcgEl6I027rCYJFYbNQ%3D%3D';
  static const String baseUrl = 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';
  static const String latitude= '36.6285314873105';
  static const String longitude= '127.45745294696479';
  static const String apiKey2= '644be1f1591bb58fdbda42fa8e9ffef7';

  static Future<WeatherData?> fetchWeather(int nx, int ny) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final ncstTimeStr = _getNcstBaseTime(now);

    final ncstUri = Uri.parse(
      '$baseUrl/getUltraSrtNcst?'
          'serviceKey=$apiKey&numOfRows=100&pageNo=1&dataType=JSON'
          '&base_date=$dateStr&base_time=$ncstTimeStr&nx=$nx&ny=$ny',
    );
    final ncstResponse = await http.get(ncstUri);
    final ncstItems = json.decode(ncstResponse.body)['response']['body']['items']['item'];

    final temp = _getDoubleValue(ncstItems, 'T1H');
    final wind = _getDoubleValue(ncstItems, 'WSD');
    final humidity = _getDoubleValue(ncstItems, 'REH');
    final pty = _getStringValue(ncstItems, 'PTY');
    final response_baseTime = ncstItems[0]['baseTime'];
    final response_baseDate = ncstItems[0]['baseDate'];

    print(temp);
    print(wind);
    print(humidity);
    print(pty);
    print('ncstTimeStr : $ncstTimeStr');
    print('response_baseTime: $response_baseTime');
    print('response_baseDate: $response_baseDate');


    // PTY가 0인 경우에만 sky 정보 조회
    String description;
    Color gradientStartColor;
    Color gradientEndColor;
    String iconPath;
    if(pty!='0'){
      description = _ptyToString(pty);
      gradientStartColor = rainy_start;
      gradientEndColor = rainy_end;
      iconPath = 'assets/rainy.png';
    } else {
      final openWeatherUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$latitude&lon=$longitude&appid=$apiKey2&units=metric&lang=en'
      );
      final openWeatherResponse = await http.get(openWeatherUri);

      if(openWeatherResponse.statusCode == 200){
        final data = json.decode(openWeatherResponse.body);
        description = _skyToString(data['weather'][0]['main']);

        switch(description) {
          case '맑음':
            gradientStartColor = sunny_start;
            gradientEndColor = sunny_end;
            iconPath = 'assets/sunny.png';
            break;
          case '흐림':
            gradientStartColor = cloudy_start;
            gradientEndColor = cloudy_end;
            iconPath = 'assets/cloudy.png';
            break;
          default:
            gradientStartColor = cloudy_start;
            gradientEndColor = cloudy_end;
            iconPath = 'assets/cloudy.png';
        }

        print(data['weather'][0]['main']);
      } else {
        throw Exception('날씨 데이터 불러오기 실패');
      }
    }

    final feelsLike = _calculateFeelsLike(temp, wind, humidity);
    print('feelsLike: $feelsLike');
    print('description: $description');

    return WeatherData(
        temperature: temp,
        windSpeed: wind,
        feelsLike: feelsLike,
        humidity: humidity,
        description: description,
        gradientStartColor: gradientStartColor,
        gradientEndColor: gradientEndColor,
        iconPath: iconPath
    );
  }

  static String _getNcstBaseTime(DateTime now) {
    if(now.minute < 10) {
      final previousHour = now.subtract(const Duration(hours: 1));
      return DateFormat('HH00').format(previousHour);
    } else {
      return DateFormat('HH00').format(now);
    }
  }

  /// 실황 데이터 항목 추출
  static double _getDoubleValue(List<dynamic> items, String category) {
    final item = items.firstWhere((e) => e['category'] == category, orElse: () => null);
    return item != null ? double.tryParse(item['obsrValue'].toString()) ?? 0.0 : 0.0;
  }

  static String _getStringValue(List<dynamic> items, String category) {
    final item = items.firstWhere((e) => e['category'] == category, orElse: () => null);
    return item != null ? item['obsrValue'].toString() : '0';
  }

  ///PTY 코드 → 날씨 설명
  static String _ptyToString(String pty) {
    switch (pty) {
      case '1':
        return '비';
      case '2':
        return '비/눈';
      case '3':
        return '눈';
      case '5':
        return '빗방울';
      case '6':
        return '빗방울눈날림';
      case '7':
        return '눈날림';
      default:
        return '알 수 없음';
    }
  }

  /// SKY 코드 → 날씨 설명
  static String _skyToString(String sky) {
    switch (sky) {
      case 'Clear':
        return '맑음';
      case 'Clouds':
        return '흐림';
      case 'Mist':
      case 'Fog':
      case 'Haze':
        return '안개';
      case 'Rain':
        return '비';
      default:
        return 'null';
    }
  }

  /// 체감기온 계산
  static double _calculateFeelsLike(double temp, double windSpeed, double humidity) {
    if(temp <= 10 && windSpeed >= 4.8){ // 겨울
      return 13.12 +
          0.6215 * temp -
          11.37 * pow(windSpeed, 0.16) +
          0.3965 * temp * pow(windSpeed, 0.16);
    } else if(temp >=27 && humidity >= 40) { // 여름
      double tempF = temp * 9/5 +32;
      double hiF = -42.379 +
          2.04901523 * tempF +
          10.14333127 * humidity -
          0.22475541 * tempF * humidity -
          0.00683783 * pow(tempF, 2) -
          0.05481717 * pow(humidity, 2) +
          0.00122874 * pow(tempF, 2) * humidity +
          0.00085282 * tempF * pow(humidity, 2) -
          0.00000199 * pow(tempF, 2) * pow(humidity, 2);

      return (hiF - 32) * 5/9;
    } else {
      return temp;
    }
  }

}

