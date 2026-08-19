import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/helpers/validators.dart';
import 'package:bemestarcem/models/app_user.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:bemestarcem/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'forgot_password_page.dart';
import 'register_page.dart';

class WelcomeBackPage extends StatefulWidget {
  @override
  _WelcomeBackPageState createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _signIn(UserManager userManager) {
    if (!formKey.currentState!.validate()) return;
    userManager.signIn(
      user: AppUser(email: email.text.trim(), password: password.text),
      onSuccess: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainPage()));
      },
      onFail: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao entrar: $e'),
          backgroundColor: Colors.red,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget welcomeBack = Text(
      'Bem-vindo de volta,',
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
          'Entre na sua conta com\nseu e-mail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover)),
          ),
          Container(
            decoration: BoxDecoration(color: transparentYellow),
          ),
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              Widget loginButton = Positioned(
                left: MediaQuery.of(context).size.width / 4,
                bottom: 24,
                child: InkWell(
                  onTap: userManager.loading ? null : () => _signIn(userManager),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 56,
                    child: Center(
                      child: userManager.loading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text("Entrar",
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

              Widget loginForm = Container(
                height: 216,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 160,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 32.0, right: 12.0),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                controller: email,
                                enabled: !userManager.loading,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                style: TextStyle(fontSize: 16.0),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                controller: password,
                                enabled: !userManager.loading,
                                style: TextStyle(fontSize: 16.0),
                                obscureText: true,
                                decoration:
                                    const InputDecoration(hintText: 'Senha'),
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Senha muito curta';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loginButton,
                  ],
                ),
              );

              Widget forgotPassword = Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Esqueceu sua senha? ',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                        fontSize: 14.0,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ForgotPasswordPage())),
                      child: Text(
                        'Redefinir senha',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              // O conteúdo rola quando não cabe (telas baixas ou teclado
              // aberto) e volta a se distribuir com os Spacer quando cabe.
              return SafeArea(
                child: LayoutBuilder(
                  builder: (_, constraints) => SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Spacer(flex: 3),
                              welcomeBack,
                              const SizedBox(height: 12),
                              subTitle,
                              const Spacer(flex: 2),
                              loginForm,
                              const Spacer(),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => RegisterPage())),
                                  child: const Text(
                                    'Não tem conta? Cadastre-se',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              forgotPassword,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
