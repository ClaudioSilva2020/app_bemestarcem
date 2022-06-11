import 'package:bemestarcem/models/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      height: 180,
      child: Consumer<UserManager>(
        builder: (_, userManeger, __){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'Bem estar\n Colchões',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Olá, ${userManeger.user?.name ?? ''}',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: (){
                  if(userManeger.isLoggedIn){
                    userManeger.signOut();
                  } else {
                    Navigator.of(context).pushNamed('/login');
                  }
                },
                child: Text(
                  userManeger.isLoggedIn
                      ? 'Sair'
                      : 'Entre ou cadastre-se',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          );
        },
      )
    );
  }
}
