import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_app/bloc/current_weather_bloc.dart';
import 'package:flutter_weather_app/models/model_current_weather.dart';
import 'package:flutter_weather_app/models/model_hourly_weather_forecast.dart';
import 'package:flutter_weather_app/repositories/current_weather_repository.dart';
import 'package:flutter_weather_app/repositories/hourly_weather_forecast_repository.dart';
import 'package:flutter_weather_app/ui/widget_additional_info.dart';
import 'package:flutter_weather_app/ui/widget_current_weather.dart';
import 'package:flutter_weather_app/ui/widget_hourly_weather_forecast.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: RepositoryProvider<CurrentWeatherRepository>(
        create: (context) => CurrentWeatherRepository(),
        child: BlocProvider(
          lazy: false,
          create: (BuildContext context) => CurrentWeatherBloc(
            currentWeatherRepository: context.read<CurrentWeatherRepository>(),
            location: "Ibi",
          ),
          child: const CurrentWeatherPage(),
        ),
      ),
    );
  }
}

class CurrentWeatherPage extends StatefulWidget {
  const CurrentWeatherPage({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 0, 76, 175), Color.fromARGB(255, 0, 93, 197)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: const Text(
            "Ibi",
            style: TextStyle(color: Colors.white),
          ),
          leading: const IconButton(
            onPressed: null,
            icon: Icon(Icons.gps_fixed_rounded),
            iconSize: 30,
            color: Colors.white,
          ),
          actions: const <Widget>[
            IconButton(
              onPressed: null,
              icon: Icon(Icons.settings),
              iconSize: 30,
              color: Colors.white,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              BlocBuilder<CurrentWeatherBloc, CurrentWeatherState>(
                builder: (BuildContext context, CurrentWeatherState state) {
                  if (state is CurrentWeatherLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is CurrentWeatherLoadedState) {
                    CurrentWeather currentWeather = state.currentWeatherItem;

                    return currentWeatherWidget(currentWeather);
                  }

                  if (state is CurrentWeatherLoadingFailedState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.network_check_rounded,
                            color: Colors.blueAccent,
                            size: 40.0,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            state.errorMessage,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
              const SizedBox(height: 80.0),
              const Divider(
                indent: 20,
                endIndent: 20,
                color: Colors.white24,
              ),
              //WidgetHourlyWeatherForecast(hourlyWeatherForecastList: hourlyWeatherForecastList!),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    context.read<CurrentWeatherBloc>().add(GetCurrentWeatherEvent());
    super.initState();
  }
}

// ==============================================================

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  CurrentWeatherRepository currentWeatherRepository = CurrentWeatherRepository();
  HourlyWeatherForecastRepository hourlyWeatherForecastRepository = HourlyWeatherForecastRepository();
  CurrentWeather? currentWeather;
  List<HourlyWeatherForecast>? hourlyWeatherForecastList;
  String location = "Ibi";

  Future<void> getData() async {
    currentWeather = await currentWeatherRepository.getCurrentWeather(location);
    hourlyWeatherForecastList = await hourlyWeatherForecastRepository.getHourlyWeatherForecast(location);
  }

  Future<void> _selectLocation() async {
    final selectedLocation = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select location'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Madrid');
              },
              child: const Text('Madrid'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Barcelona');
              },
              child: const Text('Barcelona'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'London');
              },
              child: const Text('London'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Ibi');
              },
              child: const Text('Ibi'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Alcoy');
              },
              child: const Text('Alcoy'),
            ),
          ],
        );
      },
    );

    if (selectedLocation != null) {
      setState(() {
        location = selectedLocation;
      });
      await getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 167, 212, 255), Color.fromARGB(255, 2, 90, 255)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: const Text(
            "Weather",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: _selectLocation,
              icon: const Icon(Icons.gps_fixed),
              color: Colors.white,
            )
          ],
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && currentWeather != null && hourlyWeatherForecastList != null) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //currentWeatherWidget(currentWeather!.iconLink, "${currentWeather!.temperature}º"),
                      const SizedBox(height: 40.0),
                      const Divider(),
                      WidgetHourlyWeatherForecast(hourlyWeatherForecastList: hourlyWeatherForecastList!),
                      const SizedBox(height: 40.0),
                      const Text(
                        "Additional Info.",
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      additionalInfo("${currentWeather!.windSpeed}", "${currentWeather!.humidityPercentage}", "${currentWeather!.pressure}", "${currentWeather!.apparentTemperature}"),
                    ],
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
