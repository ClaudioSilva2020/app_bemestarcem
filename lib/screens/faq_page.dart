import 'package:bemestarcem/app_properties.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  List<Panel> panels = [
    Panel(
        'COMO ALTERO MEU ENDEREÇO DE ENTREGA?',
        'Por padrão, o último endereço de entrega utilizado fica salvo na sua conta Bem Estar Cem. Durante o checkout, o endereço padrão é exibido e você pode alterá-lo se precisar.',
        false),
    Panel(
        'QUANTAS AMOSTRAS GRÁTIS POSSO RESGATAR?',
        'Devido à quantidade limitada, cada conta tem direito a 1 amostra grátis exclusiva. Você pode resgatar até 4 amostras grátis por pedido.',
        false),
    Panel(
        'COMO ACOMPANHO MEUS PEDIDOS E PAGAMENTOS?',
        'Por padrão, o último endereço de entrega utilizado fica salvo na sua conta Bem Estar Cem. Durante o checkout, o endereço padrão é exibido e você pode alterá-lo se precisar.',
        false),
    Panel(
        'QUANTO TEMPO LEVA PARA MEU PEDIDO CHEGAR APÓS O PAGAMENTO?',
        'Por padrão, o último endereço de entrega utilizado fica salvo na sua conta Bem Estar Cem. Durante o checkout, o endereço padrão é exibido e você pode alterá-lo se precisar.',
        false),
    Panel(
        'COMO VOCÊS ENTREGAM MEUS PEDIDOS?',
        'Por padrão, o último endereço de entrega utilizado fica salvo na sua conta Bem Estar Cem. Durante o checkout, o endereço padrão é exibido e você pode alterá-lo se precisar.',
        false),
    Panel(
        'COMO PAGO COM CARTÃO OU PIX? COMO FUNCIONA?',
        'Por padrão, o último endereço de entrega utilizado fica salvo na sua conta Bem Estar Cem. Durante o checkout, o endereço padrão é exibido e você pode alterá-lo se precisar.',
        false)
  ];

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
            padding: const EdgeInsets.only(top: 24.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:24.0,right:24.0,bottom: 16.0),
                  child: Text(
                    'Perguntas Frequentes',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                ),... panels.map((panel)=>ExpansionTile(
                      title: Text(
                        panel.title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600]),
                      ),

                      children: [Container(
                        padding: EdgeInsets.all(16.0),
                          color: Color(0xffFAF1E2),
                          child: Text(
                              panel.content,
                              style:
                              TextStyle(color: Colors.grey, fontSize: 12)))])).toList(),

              ],
            ),
          ),
        ),
    );
  }
}

class Panel {
  String title;
  String content;
  bool expanded;

  Panel(this.title, this.content, this.expanded);
}
