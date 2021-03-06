import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'themes.dart';

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'All', icon: Icons.group),
  const Choice(title: 'School', icon: Icons.school),
  const Choice(title: 'Year', icon: Icons.calendar_today),
  const Choice(title: 'Degree', icon: Icons.science),
  const Choice(title: 'Age', icon: Icons.cake),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: DataBaseListView(),
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: globalDarkTheme(),
      home: DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: TabBar(
              isScrollable: true,
              tabs: choices.map((Choice choice) {
                return Tab(
                  text: choice.title,
                  icon: Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: choices.map((Choice choice) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: ChoiceCard(choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class DataBaseListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents
                  .map<Widget>((DocumentSnapshot document) {
                return Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: new BoxDecoration(
                          color: globalDarkTheme().primaryColor,
                          borderRadius:
                              new BorderRadius.all(Radius.circular(20)),
                        ),
                        child: new ListTile(
                          // create new list tile for each task in doc
                          shape: RoundedRectangleBorder(),
                          title: new Text(document['name'],
                              style: Theme.of(context).textTheme.headline6),
                          subtitle: new Text(document['score'].toString()),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
