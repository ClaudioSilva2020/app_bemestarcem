import 'package:bemestarcem/app_properties.dart';
import 'package:flutter/material.dart';

class ChangeLanguagePage extends StatefulWidget {
  @override
  _ChangeCountryPageState createState() => _ChangeCountryPageState();
}

class _ChangeCountryPageState extends State<ChangeLanguagePage> {
  List<String> languages = [
    'Chinês',
    'Espanhol',
    'Inglês',
    'Romeno',
    'Alemão',
    'Português',
    'Bengali',
    'Russo',
    'Japonês',
    'Francês',
  ];

  String currentLanguage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          'Configurações',
          style: TextStyle(color: darkGrey),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Idioma',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
              Flexible(
                child: ListView(
                  children: languages
                      .map((l) => ListTile(
                            onTap: () {
                              setState(() {
                                currentLanguage = l;
                              });
                            },
                            title: Text(
                              l,
                              style: TextStyle(fontSize: 14),
                            ),
                            trailing: l == currentLanguage
                                ? Icon(
                                    Icons.check_circle,
                                    color: yellow,
                                    size: 16,
                                  )
                                : SizedBox(),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
