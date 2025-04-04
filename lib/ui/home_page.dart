import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:windyforecast/constants.dart';
import 'package:windyforecast/ui/detail_page.dart';
import 'package:windyforecast/weather_item/weather_item.dart';
import 'package:geolocator/geolocator.dart'; // Geolocator paketini import ettik.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String apiKey = "0aff08d8d56d4e1c8e4143728252303";
  final TextEditingController _citycontroller = TextEditingController();

  Map<String, String> weatherTranslations = {
    "Sunny": "Güneşli",
    "Clear": "Açık",
    "Partly cloudy": "Kısmen Bulutlu",
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

  String location = '';
  String weatherIcon = 'sunny.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';
  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];
  String currentWeatherStatus = '';
  String translatedStatus = '';
  DateTime today = DateTime.now();

  String getFormattedDate(DateTime date, {String locale = 'tr_TR'}) {
    if (isToday(date)) {
      return locale == 'tr_TR' ? 'Bugün' : 'Today'; // Bugün için çeviri
    } else {
      return DateFormat('d MMMM EEEE', locale).format(date);
    }
  }

  bool isToday(DateTime date) {
    // Bugünün tarihini kontrol et
    return date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
  }

  // API Çağırma URL'si
  String searchWeatherAPI =
      "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&days=7&q=";

  String translateWeatherStatus(String weatherStatus) {
    return weatherTranslations[weatherStatus] ?? weatherStatus;
  }

  // Konum bilgisi almak
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisinin etkin olup olmadığını kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Konum servisi kapalıysa kullanıcıya uyarı göster
      print('Konum servisi kapalı');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Konum izni verilmediyse kullanıcıya uyarı göster
        print('Konum izni verilmedi');
        return;
      }
    }

    // Konumu al
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    // Geolocator ile elde edilen konum
    String currentLocation = '${position.latitude},${position.longitude}';
    // Hava durumu verisini o konumla çek
    fetchWeatherData(currentLocation);
  }

  // Hava durumu verilerini çekme
  void fetchWeatherData(String searchText) async {
    try {
      var searchResult = await http.get(
        Uri.parse(searchWeatherAPI + searchText),
      );
      final weatherData = Map<String, dynamic>.from(
        jsonDecode(searchResult.body) ?? 'No Data',
      );

      var locationData = weatherData['location'];
      var currentData = weatherData['current'];

      setState(() {
        location = getShortLocationName(locationData["name"]);
        var parsedDate = DateTime.parse(
          locationData["localtime"].substring(0, 10),
        );
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;

        // Hava durumu verilerini güncelleme
        currentWeatherStatus = currentData["condition"]["text"];
        translatedStatus = translateWeatherStatus(currentWeatherStatus);

        weatherIcon =
            '${currentWeatherStatus.replaceAll(' ', '').toLowerCase()}.png';
        temperature = currentData["temp_c"].toInt();
        windSpeed = currentData["wind_kph"].toInt();
        humidity = currentData["humidity"].toInt();
        cloud = currentData["cloud"].toInt();

        // Forecast Data
        dailyWeatherForecast = weatherData['forecast']['forecastday'];
        hourlyWeatherForecast = dailyWeatherForecast[0]['hour'];
      });
    } catch (e) {
      // Hata durumunda kullanıcıya bildirim göster
      print("Hata: $e");
    }
  }

  // Konum ismini kısaltmak
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");
    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return "${wordList[0]} ${wordList[1]}";
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Uygulama başlatıldığında konum alınacak
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 39, left: 10, right: 10),
        color: Constants.primaryColor.withOpacity(0.1),
        child: Column(
          children: [
            // Hava durumu bilgilerini gösteren Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: size.height * 0.7,
              decoration: BoxDecoration(
                gradient: Constants.linearGradientBlue,
                boxShadow: [
                  BoxShadow(
                    color: Constants.primaryColor.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/menu.png", width: 50, height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/pin.png", width: 20),
                            const SizedBox(width: 2),
                            Text(
                              location,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _citycontroller.clear();
                                showMaterialModalBottomSheet(
                                  context: context,
                                  builder:
                                      (context) => SingleChildScrollView(
                                        controller: ModalScrollController.of(
                                          context,
                                        ),
                                        child: Container(
                                          height: size.height * 0.5,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 20,
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: 70,
                                                child: Divider(
                                                  thickness: 3.5,
                                                  color: Constants.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              TextField(
                                                onChanged: (searchText) {
                                                  fetchWeatherData(searchText);
                                                },
                                                controller: _citycontroller,
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color:
                                                        Constants.primaryColor,
                                                  ),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      _citycontroller.clear();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color:
                                                          Constants
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                  hintText:
                                                      "Şehir Araştırabilirsin Örneğin: 'İzmir' ",
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Constants
                                                                  .primaryColor,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                );
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/user.png",
                            width: 35,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Hava durumu simgesini ve sıcaklık değerini aynı satırda göstermek için Row ekliyorum
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 130, //Değiştirilecek
                        child: Image.asset("assets/$weatherIcon"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              temperature.toString(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = Constants.shader,
                              ),
                            ),
                            Text(
                              '°',
                              style: TextStyle(
                                fontSize: 70,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = Constants.shader,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    translatedStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    getFormattedDate(today, locale: 'tr_TR'),
                    style: const TextStyle(color: Colors.white70),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Divider(color: Colors.white70),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WeatherItem(
                          value: windSpeed.toInt(),
                          unit: 'km/h',
                          imageUrl: 'assets/windspeed.png',
                        ),
                        WeatherItem(
                          value: humidity.toInt(),
                          unit: '%',
                          imageUrl: 'assets/humidity.png',
                        ),
                        WeatherItem(
                          value: cloud.toInt(),
                          unit: '%',
                          imageUrl: 'assets/cloud.png',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.only(top: 20),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Bugün',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => DetailPage(
                                      dailyForecastWeather:
                                          dailyWeatherForecast,
                                    ),
                              ),
                            ),
                        child: Text(
                          '7 Günlük Hava Durumu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: Constants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      itemCount: hourlyWeatherForecast.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String currentTime = DateFormat(
                          'HH:mm:ss',
                        ).format(DateTime.now());
                        String currentHour = currentTime.substring(0, 2);

                        String forecastTime =
                            hourlyWeatherForecast[index]["time"].substring(
                              11,
                              16,
                            );
                        String forecastHour =
                            hourlyWeatherForecast[index]["time"].substring(
                              11,
                              13,
                            );

                        String forecastWeatherName =
                            hourlyWeatherForecast[index]["condition"]["text"];

                        String forecastWeatherIcon =
                            '${forecastWeatherName.replaceAll(' ', '').toLowerCase()}.png';

                        String forecastTemperature =
                            hourlyWeatherForecast[index]["temp_c"]
                                .round()
                                .toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin: const EdgeInsets.only(right: 20),
                          width: 65,
                          decoration: BoxDecoration(
                            color:
                                currentHour == forecastHour
                                    ? Colors.white
                                    : Constants.primaryColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: Constants.primaryColor.withOpacity(.2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                forecastTime,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Constants.greyColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Image.asset(
                                'assets/$forecastWeatherIcon',
                                width: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    forecastTemperature,
                                    style: TextStyle(
                                      color: Constants.greyColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '°',
                                    style: TextStyle(
                                      color: Constants.greyColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      fontFeatures: const [
                                        FontFeature.enable('sups'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
