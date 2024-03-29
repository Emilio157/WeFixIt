import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/LoginPage.dart';
import 'package:we_fix_it/ui/register_page.dart';
class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;
  void togglePages(){
    setState(() {
      showLoginPage=!showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(
        onTap:togglePages,
      );
    }
    else{
      return RegisterPage(
        onTap:togglePages,
      );
    }
  }
}