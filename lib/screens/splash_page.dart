import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:bemestarcem/screens/intro_page.dart';
import 'package:bemestarcem/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> opacity;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 2500), vsync: this);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      navigationPage();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void navigationPage() {
    final isLoggedIn = context.read<UserManager>().isLoggedIn;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => isLoggedIn ? MainPage() : IntroPage()));
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background.jpg'), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(color: transparentYellow),
        child: SafeArea(
          child: new Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Opacity(
                      opacity: opacity.value,
                      child: Text(
                        'Bem Estar Cem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkYellow,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
