import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wasteagram/screens/detail_screen.dart';
import 'package:wasteagram/wasteagram.dart';

class ListScreen extends StatefulWidget {

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
                stream: Firestore.instance.collection('posts').snapshots(),
                builder: (content, snapshot) {
                  if (!snapshot.data.documents.isEmpty) {
                    int i = 0;
                    int sum = 0;
                    while (i < snapshot.data.documents.length) {
                      sum += snapshot.data.documents[i]['quantity'];
                      i++;
                    }
                    return Text('Wasteagram - $sum');
                  } else {
                    return Text('Wasteagram');
                  }
                },
              ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('posts').orderBy('date', descending: true).snapshots(),
        builder: (content, snapshot) {
          if (!snapshot.data.documents.isEmpty) {
            return new ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                var post = snapshot.data.documents[index];
                var postDate = post['date'].toDate();
                var fDate;
                var fDate2;
                var formatterDate = DateFormat('EEEE, MMMM d');
                var formatterDate2 = DateFormat('EEEE, MMMM d, yyyy');
                fDate = formatterDate.format(postDate);
                fDate2 = formatterDate2.format(postDate);
                return Column(
                  children: <Widget>[
                    Semantics(
                      label: 'List of clickable tiles each representing an entry of wasted food',
                      onTapHint: 'Navigates to the details screen that shows date, picture, quantity, and location',
                        child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: Text(fDate.toString(),
                          style: TextStyle(fontSize: 22),),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Text(post['quantity'].toString(),
                          style: TextStyle(fontSize: 22),),
                        ),
                        onTap: () {
                          toDetailsScreen(
                            context,
                            fDate2.toString(), 
                            post['imageURL'], 
                            post['quantity'], 
                            post['latitude'],
                            post['longitude']);
                        },
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator(),);
          }
        },
      ),
      floatingActionButton: Semantics(
              label: 'Navigate to select photo screen',
              button: true,
              onTapHint: 'Opens up a new screen with option to select'
                          'photo from storage or use camera',
              child: FloatingActionButton(
          onPressed: () => toPhotoScreen(context),
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void toDetailsScreen(
    BuildContext context, 
    String date, String imageURL, int quanity, double latitude, double longitude) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(),
        settings: RouteSettings(
          name: 'details',
          arguments: Post(
            dateTime: date, imageURL: imageURL, quantity: quanity, latitude: latitude, longitude: longitude),), 
    ));
  }

  void toPhotoScreen(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PhotoScreen()));
  }

}
