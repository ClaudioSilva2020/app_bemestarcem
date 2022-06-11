import 'package:bemestarcem/helpers/validators.dart';
import 'package:bemestarcem/models/user.dart';
import 'package:bemestarcem/models/user_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {

  final  GlobalKey<FormState>  formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  final AppUser user = AppUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formkey,
            child: Consumer<UserManager>(
              builder: (_, userManager, __){
               return ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                children: <Widget> [
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Nome Completo'),
                    enabled: !userManager.loading,
                    validator: (name){
                      if(name!.isEmpty)
                        return 'Campo obrigatŕio';
                      else if(name.trim().split(' ').length <= 1)
                        return 'Preencha seu nome completo';
                      return null;
                    },
                    onSaved: (name) => user.name = name!,
                  ),
                  const SizedBox(height: 16,),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'E-mail'),
                    enabled: !userManager.loading,
                    keyboardType: TextInputType.emailAddress,
                    validator: (email){
                      if(email!.isEmpty)
                        return 'Campo obrigatório';
                      else if(!emailValid(email))
                        return 'E-mail inválido';
                      return null;
                    },
                    onSaved: (email) => user.email = email!,
                  ),
                  const SizedBox(height: 16,),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Senha'),
                    obscureText: true,
                    enabled: !userManager.loading,
                    validator: (pass){
                      if(pass!.isEmpty)
                        return 'Campo obrigatório';
                      else if(pass.length < 6)
                        return 'Senha muito curta';
                      return null;
                    },
                    onSaved: (pass) => user.password = pass!,
                  ),
                  const SizedBox(height: 16,),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Repita a Senha'),
                    obscureText: true,
                    enabled: !userManager.loading,
                    validator: (pass){
                      if(pass!.isEmpty)
                        return 'Campo obrigatório';
                      else if(pass.length < 6)
                        return 'Senha muito curta';
                      return null;
                    },
                    onSaved: (confirmpass) => user.confirmPassword = confirmpass!,
                  ),
                  const SizedBox(height: 16,),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: userManager.loading ? null :  () {
                        if (formkey.currentState!.validate()){
                          formkey.currentState!.save();

                          if(user.password != user.confirmPassword){
                            scaffoldkey.currentState!.showSnackBar(
                                SnackBar(
                                  content: const Text('Senhas não conincidem'),
                                  backgroundColor: Colors.red,
                                )
                            );
                            debugPrint(user.password);
                            debugPrint("  /n");
                            debugPrint(user.confirmPassword);
                            return;
                          }
                            userManager.signUp(
                            user: user,
                            onSucess: (){
                              debugPrint('Sucesso');
                              Navigator.of(context).pop();
                              scaffoldkey.currentState!.showSnackBar(
                                  SnackBar(
                                    content: const Text('Usuário Cadastrado'),
                                    backgroundColor: Colors.green,
                                  )
                              );
                            },
                            onFail: (e){
                              scaffoldkey.currentState!.showSnackBar(
                                  SnackBar(
                                    content: Text('Falha ao Cadastrar: $e'),
                                    backgroundColor: Colors.red,
                                  )
                              );
                            },
                          );
                        }
                      },
                      child: userManager.loading ?
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                      : const Text(
                        'Criar Conta',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            ),
          ),
        ),
      ),
    );
  }
}
