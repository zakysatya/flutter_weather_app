import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:weather_app/constant.dart';
import 'package:weather_app/ui/detail_page.dart';

import '../components/weather_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _cityController = TextEditingController();
  Constants _constants = Constants();
  static String weatherApi = "e434975d0067424cb4d92602241410";

  String location = 'Seoul';
  String weatherIcon = 'heavycloud.png';
  int temperature =0;
  int windSpeed =0;
  int humidity= 0;
  int cloud=0;
  String currentDate = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';
  String currentWeatherStatusIcon = '';

  // weather api call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=$weatherApi&days=7&q=";

  void fetchWeatherData (String searchText) async {
    try {
      var searchResult = await http.get(Uri.parse(searchWeatherAPI + searchText));

      final weatherData = Map<String, dynamic>.from(
        json.decode(searchResult.body) ?? 'No Data'
      );

      var locationData = weatherData["location"];

      var currentWeather = weatherData["current"];

      setState(() {
        location = getShortLocationName(locationData["name"]);
        print(location);
        
        var parsedDate = DateTime.parse(locationData["localtime"].substring(0, 10));
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;
        print(newDate);

        // cuaca sekarang
        currentWeatherStatus = currentWeather["condition"]["text"];
        currentWeatherStatusIcon = currentWeather["condition"]["icon"];
        weatherIcon = "${currentWeatherStatus.replaceAll(' ', '').toLowerCase()}.png";
        temperature = currentWeather["temp_c"].toInt();
        windSpeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();

        // data forecast
        dailyWeatherForecast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
        print(dailyWeatherForecast);

      });

    } catch (e) {

    }

  }

  // mengambil 2 kata awal lokasi
  static String getShortLocationName (String s) {
    List<String> wordList = s.split(" ");

    if(wordList.isNotEmpty) {
      if(wordList.length > 1) {
        return "${wordList[0]} ${wordList[1]}";
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  initState() {
    fetchWeatherData(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 70, left: 10, right: 10),
        color: _constants.primaryColor.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: size.height * .7,
              decoration: BoxDecoration(
                gradient: _constants.linearGradientBlue,
                boxShadow: [
                  BoxShadow(
                    color: _constants.primaryColor.withOpacity(.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  )
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/menu.png",
                        width: 40,
                        height: 40,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/pin.png",
                            width: 20,
                          ),
                          const SizedBox(width: 2,),
                          Text(location, style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),),
                          IconButton(
                            onPressed: () {
                              _cityController.clear();
                              showMaterialModalBottomSheet(context: context, builder: (context) => SingleChildScrollView(
                                controller: ModalScrollController.of(context),
                                child: Container(
                                  height: size.height * .2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,vertical: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Divider(
                                          thickness: 3.5,
                                          color: _constants.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      TextField(
                                        onChanged: (searchText) {
                                          fetchWeatherData(searchText);
                                        },
                                        controller: _cityController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.search, color: _constants.primaryColor,),
                                            suffixIcon: GestureDetector(
                                              onTap: () => _cityController.clear(),
                                              child: Icon(Icons.close, color: _constants.primaryColor,),
                                            ),
                                            hintText: 'Search city e.g. Seoul',
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: _constants.primaryColor,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              );
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/profile.png",
                          width: 40,
                          height: 40,),
                      )
                    ],
                  ),
                  SizedBox(
                      height: 160,
                      child: weatherIcon.isNotEmpty
                          ? Image.asset("assets/$weatherIcon", fit: BoxFit.contain)
                          : Image.network("http:$currentWeatherStatusIcon", fit: BoxFit.contain)
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(temperature.toString(),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = _constants.shader,
                        ),
                        ),
                      ),
                      Text(
                        '℃',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          foreground:Paint()..shader = _constants.shader,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currentWeatherStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Divider(
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WeatherItem(
                          // text: 'Wind Speed',
                          value: windSpeed.toInt(),
                          unit: 'km/h',
                          imageUrl: 'assets/windspeed.png',
                        ),
                        WeatherItem(
                          // text: 'Humidity',
                          value: humidity.toInt(),
                          unit: '%',
                          imageUrl: 'assets/humidity.png',
                        ),
                        WeatherItem(
                          // text: 'Cloud',
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
              padding: const EdgeInsets.only(top: 10),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailPage(dailyForecastWeather: dailyWeatherForecast,),),
                        ), // open forecast screen
                        child: Text('forecast', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _constants.primaryColor,
                        ),),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                        itemCount: hourlyWeatherForecast.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                        String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
                        String currentHour = currentTime.substring(0,2);

                        String forecastTime = hourlyWeatherForecast[index]["time"].substring(11,16);
                        String forecastHour = hourlyWeatherForecast[index]["time"].substring(11,13);

                        String forecastWeatherName = hourlyWeatherForecast[index]["condition"]["text"];
                        String forecastWeatherIcon = "${forecastWeatherName.replaceAll(' ', '').toLowerCase()}.png";

                        String forecastTemperature = hourlyWeatherForecast[index]["temp_c"].round().toString();

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10,),
                          margin: const EdgeInsets.only(right: 15),
                          width: 65,
                          decoration: BoxDecoration(
                            color: currentHour == forecastHour ? Colors.white : _constants.primaryColor,
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: _constants.primaryColor.withOpacity(.5),
                              )
                            ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(forecastTime, style: TextStyle(
                                fontSize: 17,
                                color: _constants.greyColor,
                                fontWeight: FontWeight.w500,
                              ),),
                              Image.asset('assets/$forecastWeatherIcon', width: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(forecastTemperature, style: TextStyle(
                                    color: _constants.greyColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),),
                                  Text("℃", style: TextStyle(
                                    color: _constants.greyColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [
                                      FontFeature.enable('sups')
                                    ],

                                  ),),
                                ],
                              )
                            ],
                          ),
                        );
                        },
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


