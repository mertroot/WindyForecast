import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import [Esasında kullanıyorum.]
import 'package:intl/locale.dart' as intl;
import 'package:windyforecast/constants.dart';
import 'package:windyforecast/weather_item/weather_item.dart';

class DetailPage extends StatefulWidget {
  final dailyForecastWeather;

  const DetailPage({super.key, this.dailyForecastWeather});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Türkçe hava durumu adları
  Map<String, String> weatherTranslations = {
    "Sunny": "Güneşli",
    "Clear": "Açık",
    "Partly Cloudy": "Kısmen Bulutlu",
    "Cloudy": "Bulutlu",
    "Rain": "Yağmur",
    "Moderate rain": "Orta Yağmur", // Çeviri burada
    "Heavy rain": "Şiddetli Yağmur",
    "Light rain": "Hafif Yağmur",
    "Thunderstorm": "Fırtına",
    "Snow": "Kar",
    "Fog": "Sis",
    "Patchy rain nearby": "Yakınlarda Yer Yer Yağmur",
    "Blizzard": "Kar Fırtınası",
    "Drizzle": "Çiseleme",
    "Freezing rain": "Don Yağmuru",
    "Heavy snow": "Şiddetli Kar",
    "Light snow": "Hafif Kar",
    "Showers": "Sağanak Yağış",
    "Sleet": "Çamur Kar",
    "Dust": "Toz",
    "Hail": "Dolu",
    "Windy": "Rüzgarlı",
    "Hot": "Sıcak",
    "Cold": "Soğuk",
    "Very hot": "Çok Sıcak",
    "Very cold": "Çok Soğuk",
    "Partly cloudy with showers": "Kısmen Bulutlu Sağanak Yağışlı",
    "Mostly clear": "Çoğunlukla Açık",
    "Isolated thunderstorms": "Yer Yer Fırtınalar",
    "Partly cloudy with sleet": "Kısmen Bulutlu Çamur Kar",
    "Mostly cloudy": "Çoğunlukla Bulutlu",
    "Light rain shower": "Hafif Yağmur Sağanağı",
    "Heavy thunderstorms": "Şiddetli Fırtınalar",
    "Moderate snow": "Orta Derecede Kar",
    "Thunderstorms with rain": "Yağmurlu Fırtına",
    "Thunderstorms with hail": "Dolu ile Fırtına",
    "Heavy showers": "Şiddetli Sağanak Yağış",
    "Light showers": "Hafif Sağanak Yağış",
    "Partly cloudy with snow": "Kısmen Bulutlu Kar Yağışlı",
    "Scattered thunderstorms": "Dağınık Fırtınalar",
    "Partly cloudy with drizzle": "Kısmen Bulutlu Çiseleme",
  };

  // Hava durumu ismini Türkçeye çeviren fonksiyon
  String translateWeatherName(String weatherName) {
    String normalizedWeatherName = weatherName.trim();
    normalizedWeatherName =
        normalizedWeatherName[0].toUpperCase() +
        normalizedWeatherName.substring(1);

    return weatherTranslations[normalizedWeatherName] ?? weatherName;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var weatherData = widget.dailyForecastWeather;

    // Function to get weather
    Map getForecastWeather(int index) {
      int maxWindSpeed = weatherData[index]["day"]["maxwind_kph"].toInt();
      int avgHumidity = weatherData[index]["day"]["avghumidity"].toInt();
      int chanceOfRain =
          weatherData[index]["day"]["daily_chance_of_rain"].toInt();

      var parsedDate = DateTime.parse(weatherData[index]["date"]);
      var forecastDate = DateFormat(
        'd MMMM EEEE',
        'tr_TR',
      ).format(parsedDate); // Türkçe tarih formatı

      String weatherName = weatherData[index]["day"]["condition"]["text"];
      String weatherIcon =
          "${weatherName.replaceAll(' ', '').toLowerCase()}.png";

      int minTemperature = weatherData[index]["day"]["mintemp_c"].toInt();
      int maxTemperature = weatherData[index]["day"]["maxtemp_c"].toInt();

      var forecastData = {
        'maxWindSpeed': maxWindSpeed,
        'avgHumidity': avgHumidity,
        'chanceOfRain': chanceOfRain,
        'forecastDate': forecastDate,
        'weatherName': translateWeatherName(
          weatherName,
        ), // Hava durumu çevirisi
        'weatherIcon': weatherIcon,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
      };
      return forecastData;
    }

    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text('7 Günlük Hava Durumu'),
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                print("Ayarlar Tıklandı!"); // Türkçe
              },
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * .90,
              width: size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 5), // Burada biraz boşluk ekledim
                  Container(
                    height: 320,
                    width: size.width * .97,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                        colors: [Color(0xffa9c1f5), Color(0xff6696f5)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(.1),
                          offset: const Offset(0, 25),
                          blurRadius: 3,
                          spreadRadius: -10,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 145,
                          child: Image.asset(
                            "assets/" + getForecastWeather(0)["weatherIcon"],
                          ),
                        ),
                        Positioned(
                          top: 170,
                          left: 20,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              getForecastWeather(
                                0,
                              )["weatherName"], // Türkçeleştirilmiş hava durumu
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            width: size.width * .9,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                WeatherItem(
                                  value: getForecastWeather(0)["maxWindSpeed"],
                                  unit: "km/h",
                                  imageUrl: "assets/windspeed.png",
                                ),
                                WeatherItem(
                                  value: getForecastWeather(0)["avgHumidity"],
                                  unit: "%",
                                  imageUrl: "assets/humidity.png",
                                ),
                                WeatherItem(
                                  value: getForecastWeather(0)["chanceOfRain"],
                                  unit: "%",
                                  imageUrl: "assets/lightrain.png",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getForecastWeather(
                                  0,
                                )["maxTemperature"].toString(),
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  foreground:
                                      Paint()..shader = Constants.shader,
                                ),
                              ),
                              Text(
                                'o',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  foreground:
                                      Paint()..shader = Constants.shader,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Aşağıdaki ListView (weather cards)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 7, // Buradaki itemCount'u 7 yapabilirsiniz
                      itemBuilder: (context, index) {
                        final forecast = getForecastWeather(index);
                        return Card(
                          elevation: 3.0,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      forecast["forecastDate"],
                                      style: const TextStyle(
                                        color: Color(0xff6696f5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              forecast["minTemperature"]
                                                  .toString(),
                                              style: TextStyle(
                                                color: Constants.greyColor,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '°',
                                              style: TextStyle(
                                                color: Constants.greyColor,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                                fontFeatures: const [
                                                  FontFeature.enable('sups'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              forecast["maxTemperature"]
                                                  .toString(),
                                              style: TextStyle(
                                                color: Constants.blackColor,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '°',
                                              style: TextStyle(
                                                color: Constants.blackColor,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                                fontFeatures: const [
                                                  FontFeature.enable('sups'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/' + forecast["weatherIcon"],
                                          width: 30,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          forecast["weatherName"], // Türkçeleştirilmiş hava durumu
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${forecast["chanceOfRain"]}%",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Image.asset(
                                          'assets/lightrain.png',
                                          width: 30,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
