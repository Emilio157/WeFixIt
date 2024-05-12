import 'package:flutter/material.dart';
import 'package:we_fix_it/ui/login_page.dart';
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
      return LoginScreen(
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