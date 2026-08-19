import 'dart:io';

import 'package:bemestarcem/app_properties.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LegalAboutPage extends StatefulWidget {
  @override
  _LegalAboutPageState createState() => _LegalAboutPageState();
}

class _LegalAboutPageState extends State<LegalAboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.black,
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
          padding: const EdgeInsets.only(top:24.0,left: 24.0, right: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Jurídico e Sobre',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
              Flexible(
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text('Termos de Uso'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text('Política de Privacidade'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text('Licença'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text('Política do Vendedor'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      title: Text('Política de Devolução'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
