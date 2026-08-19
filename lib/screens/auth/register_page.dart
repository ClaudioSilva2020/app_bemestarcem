import 'package:bemestarcem/app_properties.dart';
import 'package:bemestarcem/helpers/validators.dart';
import 'package:bemestarcem/models/app_user.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:bemestarcem/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AppUser user = AppUser();

  void _signUp(UserManager userManager) {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    if (user.password != user.confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('As senhas não coincidem'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    userManager.signUp(
      user: user,
      onSuccess: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainPage()), (route) => false);
      },
      onFail: (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao cadastrar: $e'),
          backgroundColor: Colors.red,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      'Prazer em te conhecer',
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
          'Crie sua conta para aproveitar todas as vantagens.',
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
              Widget registerButton = Positioned(
                left: MediaQuery.of(context).size.width / 4,
                bottom: 40,
                child: InkWell(
                  onTap: userManager.loading ? null : () => _signUp(userManager),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 80,
                    child: Center(
                      child: userManager.loading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text("Cadastrar",
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

              Widget registerForm = Container(
                height: 300,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 32.0, right: 12.0),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                enabled: !userManager.loading,
                                style: TextStyle(fontSize: 16.0),
                                decoration: const InputDecoration(
                                    hintText: 'Nome completo'),
                                validator: (name) {
                                  if (name == null || name.trim().isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  if (name.trim().split(' ').length <= 1) {
                                    return 'Preencha seu nome completo';
                                  }
                                  return null;
                                },
                                onSaved: (name) => user.name = name?.trim(),
                              ),
                              TextFormField(
                                enabled: !userManager.loading,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                style: TextStyle(fontSize: 16.0),
                                decoration:
                                    const InputDecoration(hintText: 'E-mail'),
                                validator: (email) {
                                  if (email == null || email.trim().isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  if (!emailValid(email.trim())) {
                                    return 'E-mail inválido';
                                  }
                                  return null;
                                },
                                onSaved: (email) => user.email = email?.trim(),
                              ),
                              TextFormField(
                                enabled: !userManager.loading,
                                style: TextStyle(fontSize: 16.0),
                                obscureText: true,
                                decoration:
                                    const InputDecoration(hintText: 'Senha'),
                                validator: (pass) {
                                  if (pass == null || pass.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  if (pass.length < 6) {
                                    return 'Senha muito curta';
                                  }
                                  return null;
                                },
                                onSaved: (pass) => user.password = pass,
                              ),
                              TextFormField(
                                enabled: !userManager.loading,
                                style: TextStyle(fontSize: 16.0),
                                obscureText: true,
                                decoration: const InputDecoration(
                                    hintText: 'Repita a senha'),
                                validator: (pass) {
                                  if (pass == null || pass.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  if (pass.length < 6) {
                                    return 'Senha muito curta';
                                  }
                                  return null;
                                },
                                onSaved: (pass) => user.confirmPassword = pass,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    registerButton,
                  ],
                ),
              );

              return Padding(
                padding: const EdgeInsets.only(left: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Spacer(flex: 3),
                    title,
                    Spacer(),
                    subTitle,
                    Spacer(flex: 2),
                    registerForm,
                    Spacer(flex: 2),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 35,
            left: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
