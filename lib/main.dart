import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutterjsonisolate/models/photo.dart';

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
  await client.get("https://jsonplaceholder.typicode.com/photos");

  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String body) {
  final parsed = json.decode(body).cast<Map<String, dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJSON(json)).toList();
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = "Isolate Deme";
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(),
          ),
          Expanded(
            child: FutureBuilder<List<Photo>>(
              future: fetchPhotos(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? PhotoList(photos: snapshot.data)
                    : Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class PhotoList extends StatelessWidget {
  final List<Photo> photos;

  PhotoList({ Key key, this.photos }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2
        ), itemCount: photos.length, itemBuilder: (context, index) {
      return Image.network(photos[index].thumbnailUrl);
    });
  }
}
