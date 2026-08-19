import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/helpers/validators.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController email = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void _resetPassword(UserManager userManager) {
    if (!formKey.currentState!.validate()) return;
    userManager.resetPassword(
      email: email.text.trim(),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enviamos um link de recuperação para seu e-mail.'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      },
      onFail: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao enviar: $e'),
          backgroundColor: Colors.red,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      'Esqueceu sua senha?',
      style: TextStyle(
          color: Colors.white,
          fontSize: 34.0,
          fontWeight: FontWeight.bold,
          shadows: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              offset: Offset(0, 5),
              blurRadius: 10.0,
            )
          ]),
    );

    Widget subTitle = Padding(
        padding: const EdgeInsets.only(right: 56.0),
        child: Text(
          'Informe seu e-mail cadastrado para receber o link de recuperação',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ));

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background.jpg'), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(color: transparentYellow),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: Consumer<UserManager>(
              builder: (_, userManager, __) {
                Widget sendButton = Positioned(
                  left: MediaQuery.of(context).size.width / 4,
                  bottom: 40,
                  child: InkWell(
                    onTap: userManager.loading
                        ? null
                        : () => _resetPassword(userManager),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 80,
                      child: Center(
                        child: userManager.loading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text("Enviar link",
                                style: TextStyle(
                                    color: Color(0xfffefefe),
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 20.0)),
                      ),
                      decoration: BoxDecoration(
                          gradient: mainButton,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.16),
                              offset: Offset(0, 5),
                              blurRadius: 10.0,
                            )
                          ],
                          borderRadius: BorderRadius.circular(9.0)),
                    ),
                  ),
                );

                Widget emailForm = Container(
                  height: 210,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(
                            left: 32.0, right: 12.0, bottom: 30),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.8),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10))),
                        child: Form(
                          key: formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              controller: email,
                              enabled: !userManager.loading,
                              style: TextStyle(fontSize: 16.0),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration:
                                  const InputDecoration(hintText: 'E-mail'),
                              validator: (value) {
                                if (value == null || !emailValid(value.trim())) {
                                  return 'E-mail inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      sendButton,
                    ],
                  ),
                );

                return Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(flex: 3),
                      title,
                      Spacer(),
                      subTitle,
                      Spacer(flex: 2),
                      emailForm,
                      Spacer(flex: 3),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
