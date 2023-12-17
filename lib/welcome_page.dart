import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_take/stock_count.dart';
import 'package:stock_take/test.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'config.dart';
import 'db_config.dart';


class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController batchController = TextEditingController();
  FocusNode passwordFocusController = FocusNode();
  late FocusNode focusNode;
  final db = DBProvider.db;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    passwordController.dispose();
    userNameController.dispose();
    batchController.dispose();
    super.dispose();
  }

  Widget _title() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 8,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'S',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: 50,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            children: const [
              TextSpan(
                text: 'tock ',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 40,
                    fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: 'T',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 50,
                    fontWeight: FontWeight.w900),
              ),
              TextSpan(
                text: 'ake',
                style: TextStyle(color: Colors.black87, fontSize: 40),
              ),
            ]),
      ),
    );
  }

  Widget _usernameController() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 8,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
//        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
            ],
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            textAlign: TextAlign.left,
            focusNode: focusNode,
            autofocus: true,
            // obscureText: true,
            controller: userNameController,
            style: const TextStyle(fontSize: 22.0, height: 1, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.person,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 5.00),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20.0),
              ),
              labelText: ' User Name',
              labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
            )));
  }

  Widget _passwordController() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 8,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
//        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
            ],
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            obscureText: true,
            textAlign: TextAlign.left,
            autofocus: true,
            controller: passwordController,
            style: const TextStyle(fontSize: 22.0, height: 1, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.https,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 5.00),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20.0),
              ),
              labelText: ' Password',
              labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
            )));
  }

  Widget _batchdController() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 8,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
//        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9/\\-]+$')),
            ],
            obscureText: false,
            textAlign: TextAlign.left,
            autofocus: true,
            controller: batchController,
            style: const TextStyle(fontSize: 22.0, height: 1, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.inventory,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 5.00),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20.0),
              ),
              labelText: ' Batch Number',
              labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
            )));
  }

  Widget _loginButton() {
    return InkWell(
      onTap: () async {
        String userNameLogin = userNameController.text;
        String passwordLogin = passwordController.text;
        String? batchNo = batchController.text;
        // userNameController.text = '';
        // passwordController.text = '';
        focusNode.unfocus();
        if(userNameLogin.isEmpty || passwordLogin.isEmpty)
        {
          scaffoldMsg(context, 'Please Enter the Credentials');
          return;
        }
        if(await (db.validateUser(userNameLogin, passwordLogin))) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockTake(userNameLogin, batchNo),
            ),
          );
        } else{
          scaffoldMsg(context, 'Credential Mismatch');
        }
      },
      onDoubleTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfigSettings(),
          ),
        );
        // String userNameLogin = userNameController.text;
        // String passwordLogin = passwordController.text;
        // userNameController.text = '';
        // passwordController.text = '';
        // focusNode.requestFocus();
        // if(await (db.validateUser(userNameLogin, passwordLogin))) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ConfigSettings(),
        //     ),
        //   );
        // } else{
        //   print('There is no data');
        // }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: const Color(0xffdf8e33).withAlpha(10),
                  offset: const Offset(2, 4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
            color: Colors.black),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return InkWell(
      onTap: () async {
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: const Color(0xffdf8e33).withAlpha(10),
                  offset: const Offset(2, 4),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
            color: Colors.white),
        child: const Text(
          'Register',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _info() {
    return const Center(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Version : 1.4.56 \n Developed by @Archer Designs',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15,color: Colors.white,fontStyle: FontStyle.normal,),
            ),
        ));
  }

  void scaffoldMsg(context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0XFFB71731),
                      Color(0XFFB71731),
                      Color(0XFFA5004E),
                    ])),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _title(),
                  const SizedBox(
                    height: 90,
                  ),
                  _usernameController(),
                  _passwordController(),
                  _batchdController(),
                  _loginButton(),
                  const SizedBox(
                    height: 200,
                  ),
                  _info(),
                ])),
      ),
    );
  }
}