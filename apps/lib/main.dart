import 'dart:convert';
import 'dart:io';

import 'package:apps/response.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Go Firebase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _token;
  String? _message;
  String? _user;

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _getCurrentUserEmail() async {
    http.Response res = await http.get(Uri.parse("http://192.168.18.46:3000"),
        headers: {HttpHeaders.authorizationHeader: 'Basic ${_token!}'});
    var responseBody = parseResponse(res.body);
    setState(() {
      _user = responseBody.content;
    });
  }

  Future<http.Response> login(String? token) async {
    return http.post(Uri.parse("http://192.168.18.46:3000"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{"token": token}));
  }

  Response parseResponse(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<String, dynamic>();

    return Response.fromJson(parsed);
  }

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((event) {
      event?.authentication.then((value) async {
        http.Response res = await login(value.idToken);
        var responseBody = parseResponse(res.body);
        setState(() {
          _message = responseBody.message;
          _token = responseBody.content;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: _token == null
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                  onPressed: () => _handleSignIn(),
                  child: const Text(
                    'Sign in by Google',
                    style: TextStyle(color: Colors.black),
                  ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _message ?? "Error",
                      style: const TextStyle(color: Colors.black),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed: () => _getCurrentUserEmail(),
                        child: const Text(
                          'Get User Data',
                          style: TextStyle(color: Colors.black),
                        )),
                    Text(
                      _user ?? "Error",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                )),
    );
  }
}
