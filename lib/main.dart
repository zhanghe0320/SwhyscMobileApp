import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart' hide Router;
import 'package:fluro/fluro.dart';
import 'package:mall/config/routers.dart';
import 'package:mall/config/application.dart';
import 'package:mall/model/user_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:mall/page/home/tabs.dart';

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;

bool shortenOn = false;

List marketListData;
Map portfolioMap;
List portfolioDisplay;
Map totalPortfolioStats;

bool isIOS;
String upArrow = "⬆";
String downArrow = "⬇";

int lastUpdate;

Future<Null> getMarketData() async {
  int pages = 5;
  List tempMarketListData = [];

  Future<Null> _pullData(page) async {
    var response = await http.get(
        Uri.encodeFull("https://min-api.cryptocompare.com/data/top/mktcapfull?tsym=USD&limit=100" +
            "&page=" +
            page.toString()),
        headers: {"Accept": "application/json"});
    print(response);
    List rawMarketListData = new JsonDecoder().convert(response.body)["Data"];
    tempMarketListData.addAll(rawMarketListData);
  }

  List<Future> futures = [];
  for (int i = 0; i < pages; i++) {
    futures.add(_pullData(i));
  }
  await Future.wait(futures);

  marketListData = [];
  // Filter out lack of financial data
  for (Map coin in tempMarketListData) {
    if (coin.containsKey("RAW") && coin.containsKey("CoinInfo")) {
      marketListData.add(coin);
    }
  }

  getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/marketData.json");
    jsonFile.writeAsStringSync(json.encode(marketListData));
  });
  print("Got new market data.");

  lastUpdate = DateTime.now().millisecondsSinceEpoch;
}

numCommaParse(numString) {
  if (shortenOn) {
    String str = num.parse(numString ?? "0").round().toString().replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    List<String> strList = str.split(",");

    if (strList.length > 3) {
      return strList[0] +
          "." +
          strList[1].substring(0, 4 - strList[0].length) +
          "B";
    } else if (strList.length > 2) {
      return strList[0] +
          "." +
          strList[1].substring(0, 4 - strList[0].length) +
          "M";
    } else {
      return num.parse(numString ?? "0").toString().replaceAllMapped(
          new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    }
  }

  return num.parse(numString ?? "0").toString().replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

normalizeNum(num input) {
  if (input == null) {
    input = 0;}
  if (input >= 100000) {
    return numCommaParse(input.round().toString());
  } else if (input >= 1000) {
    return numCommaParse(input.toStringAsFixed(2));
  } else {
    return input.toStringAsFixed(6 - input.round().toString().length);
  }
}

normalizeNumNoCommas(num input) {
  if (input == null) {
    input = 0;}
  if (input >= 1000) {
    return input.toStringAsFixed(2);
  } else {
    return input.toStringAsFixed(6 - input.round().toString().length);
  }
}


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await getApplicationDocumentsDirectory().then((Directory directory) async {
    File jsonFile = new File(directory.path + "/portfolio.json");
    if (jsonFile.existsSync()) {
      portfolioMap = json.decode(jsonFile.readAsStringSync());
    } else {
      jsonFile.createSync();
      jsonFile.writeAsStringSync("{}");
      portfolioMap = {};
    }
    if (portfolioMap == null) {
      portfolioMap = {};
    }
    jsonFile = new File(directory.path + "/marketData.json");
    if (jsonFile.existsSync()) {
      marketListData = json.decode(jsonFile.readAsStringSync());
    } else {
      jsonFile.createSync();
      jsonFile.writeAsStringSync("[]");
      marketListData = [];
      // getMarketData(); ?does this work?
    }
  });

  String themeMode = "Automatic";
  bool darkOLED = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("shortenOn") != null &&
      prefs.getString("themeMode") != null) {
    shortenOn = prefs.getBool("shortenOn");
    themeMode = prefs.getString("themeMode");
    darkOLED = prefs.getBool("darkOLED");
  }

  runApp(ChangeNotifierProvider(
    builder: (context) => UserInfoModel(),
    child: MallApp(),
  ));
}

class MallApp extends StatelessWidget {
  MallApp() {
    final router = FluroRouter();
    Routers.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Application.router.generator,
      theme: ThemeData(
        primaryColor: Colors.blue,

      ),
    );
  }
}
