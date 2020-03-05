import 'package:flutter/material.dart';
import 'package:material_components/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
          child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        children: <Widget>[
          SizedBox(
            height: 80,
          ),
          Column(
            children: <Widget>[
              Image.asset('image/lake.jpg'),
              SizedBox(
                height: 16,
              ),
              Text('LNH')
            ],
          ),
          SizedBox(
            height: 48,
          ),
          AccentColorOverride(
              color: kShrineBrown900,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'UserName'),
              )),
          SizedBox(
            height: 12,
          ),
          AccentColorOverride(
              color: kShrineBrown900,
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              )),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  // todo clear text feilds
                  _usernameController.clear();
                  _passwordController.clear();
                },
                child: Text('Cancel'),
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0))),
              ),
              RaisedButton(
                onPressed: () {
                  // todo next page
                  Navigator.pop(context);
                },
                child: Text('Next'),
                elevation: 8.0,
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0))),
              )
            ],
          )
        ],
      )),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}
