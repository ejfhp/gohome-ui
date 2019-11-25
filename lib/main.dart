import 'dart:core';
import 'dart:convert';

import 'package:flhome/pubsub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(FlHomeApp());

class FlHomeApp extends StatelessWidget {
  final Plan plan = Plan();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flHome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home('ViaPiave controls', plan),
    );
  }
}

class HomeSwitch extends StatefulWidget {
  final String amb;
  final String pl;

  HomeSwitch(this.amb, this.pl);

  @override
  State<HomeSwitch> createState() {
    return HomeSwitchState();
  }
}

class HomeSwitchState extends State<HomeSwitch> {
  bool turnedON = false;

  void _onChanged(bool svVal) {
    setState(() {
    print("_onChanged($svVal)");
    String command;
      turnedON = !turnedON;
      if (turnedON) {
        command = "TURN_ON";
       } else {
         command = "TURN_OFF";
       }
    String message = buildLightCommandMessage(ambient: widget.amb, light: widget.pl, command: command);
    sendMessage(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    var col = Column(
      children: <Widget>[
        Text(widget.amb + "." + widget.pl),
        Switch(onChanged: _onChanged, value: turnedON)
      ],
    );
    return Container(child: col, height: 15,);
  }
}

class AmbientCard extends StatelessWidget {
  final String ambient;
  final Set<String> lights;

  AmbientCard(this.ambient, this.lights) {
    print("Ambient is $ambient");
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> switches = List<Widget>();
    for (var pl in lights) {
      switches.add(HomeSwitch(ambient, pl));
    }
    var lightGrids = GridView.count(children: switches, crossAxisCount: 3, shrinkWrap: true,);
    var card = Card(child: lightGrids);
    return card;
  }
  
}


class Home extends StatefulWidget {
  final Plan plan;
  final String title;
  Map<String, Set<String>> lightsState;

  // Constructor that sets title to the internal variable
  //TODO Maybe read default can be moved before constructor
  Home(this.title, this.plan) {
    lightsState = this.plan.mapPlan;
  }


  @override
  State<Home> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    var cards = List<Widget>();
    for (var amb in widget.lightsState.keys) {
      var lights = widget.lightsState[amb];
      cards.add(AmbientCard(amb, lights));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cards,
        ),
      )
    );
  }

}

class Plan {
  Map<String, Set<String>> mapPlan;

  Future<bool> init() async {
    String planJson = await rootBundle.loadString('conf/gohome.json');
    Map<String, dynamic> mapPlan = jsonDecode(planJson);

    mapPlan = Map<String, Set<String>>();
    mapPlan['cucina'] = {'principale', 'tavolo', 'fornelli'};
    mapPlan['sala'] = {'principale'};
    mapPlan['bagno'] = {'principale'};
    return true;
  }
}

