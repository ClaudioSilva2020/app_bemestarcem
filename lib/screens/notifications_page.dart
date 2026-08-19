import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/screens/rating/rating_page.dart';
import 'package:bemestarcem/screens/tracking_page.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      child: SafeArea(
        child: Container(
            margin: const EdgeInsets.only(top: kToolbarHeight),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Notificações',
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CloseButton()
                ],
              ),
              Flexible(
                child: ListView(
                  children: <Widget>[
                    // Request amount
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/background.jpg',
                                ),
                                maxRadius: 24,
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: 'Sai Sankar Ram',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          TextSpan(
                                            text: ' solicitou ',
                                          ),
                                          TextSpan(
                                            text: 'R\$45,25',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.blue[700],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text('Pagar',
                                        style:
                                            TextStyle(color: Colors.blue[700])),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.cancel,
                                    size: 14,
                                    color: Color(0xffF94D4D),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text('Recusar',
                                        style: TextStyle(
                                            color: Color(0xffF94D4D))),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Send amount
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/background.jpg',
                                ),
                                maxRadius: 24,
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: 'Sai Sankar Ram',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          TextSpan(
                                            text: ' te enviou ',
                                          ),
                                          TextSpan(
                                            text: 'R\$45,25',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.blue[700],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text('Aceitar',
                                        style:
                                            TextStyle(color: Colors.blue[700])),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.cancel,
                                    size: 14,
                                    color: Color(0xffF94D4D),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text('Recusar',
                                        style: TextStyle(
                                            color: Color(0xffF94D4D))),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Share your feedback.
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              SizedBox(
                                height: 110,
                                width: 110,
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                        height: 90,
                                        width: 90,
                                        child: Image.network(
                                            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=75&fm=jpg&fit=crop',
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Column(children: [
                                  Text(
                                      'Sofá 3 Lugares Veludo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10)),
                                  SizedBox(height:4.0),
                                  Text(
                                      'Seu pedido foi entregue. Obrigado pela compra!',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10))
                                ]),
                              )
                            ]),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => RatingPage())),
                            child: Container(
                                padding: const EdgeInsets.all(14.0),
                                decoration: BoxDecoration(
                                    color: yellow,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0))),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Deixe sua avaliação',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ))),
                          )
                        ],
                      ),
                    ),
                    // Track the product.
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              SizedBox(
                                height: 110,
                                width: 110,
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                        height: 90,
                                        width: 90,
                                        child: Image.network(
                                            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=75&fm=jpg&fit=crop',
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Column(children: [
                                  Text(
                                      'Geladeira Frost Free 400L',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10)),
                                  SizedBox(height:4.0),
                                  Text(
                                      'Seu pedido foi despachado. Você pode acompanhar o rastreio.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10))
                                ]),
                              )
                            ]),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => TrackingPage())),
                            child: Container(
                                padding: const EdgeInsets.all(14.0),
                                decoration: BoxDecoration(
                                    color: yellow,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0))),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Rastrear pedido',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ))),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ])),
      ),
    );
  }
}
