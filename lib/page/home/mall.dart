import 'package:flutter/material.dart';
import 'package:mall/mywidget/page1.dart';
import 'package:mall/page/home/home_page.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/page/category/category.dart';
import 'package:mall/page/home/cart.dart';
import 'package:mall/page/home/mine.dart';

import 'market.dart';

class MallMainView extends StatefulWidget {
  @override
  _MallMainViewState createState() => _MallMainViewState();
}

class _MallMainViewState extends State<MallMainView> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _list = List();


  @override
  void initState() {
    super.initState();
    String themeMode = "Automatic";
    bool darkOLED = false;
    _list
      ..add(HomePage())
      ..add(CategoryView())
      ..add(CartView())
      ..add(TraceApp(themeMode, darkOLED))
      ..add(MineView());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _list,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text(Strings.HOME),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              title: Text(Strings.CATEGORY),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horizontal_circle),
              title: Text(Strings.SHOP_CAR),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              title: Text(Strings.QUOTES),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text(Strings.MINE),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepOrangeAccent,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
    );
  }
}
