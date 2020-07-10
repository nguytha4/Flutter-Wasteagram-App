import 'package:flutter/material.dart';
import '../wasteagram.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {

    final Post post = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("Wasteagram"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('${post.dateTime}',
              style: TextStyle(fontSize: 28),),
            ),
            SizedBox(height: 25,),
            SizedBox(
              height: 200,
              width: 400,
              child: Image.network('${post.imageURL}'),
              ),
           SizedBox(height: 25,),
           Text('Items: ${post.quantity}',
           style: TextStyle(fontSize: 22),),
           SizedBox(height: 25,),
           Text('(${post.latitude}, ${post.longitude})',
           style: TextStyle(fontSize: 20),),
          ],
      ),
    ));
    
  }
}