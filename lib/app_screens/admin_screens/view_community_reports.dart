import 'package:brighter_bee/app_screens/community_screens/community_home.dart';
import 'package:brighter_bee/helpers/community_delete.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// @author: Ashutosh Chitranshi
// 21 Oct, 2020
// This will be used for viewing reports of other communities in BrighterBee community.

class ViewCommunityReports extends StatefulWidget {
  @override
  _ViewCommunityReportsState createState() => _ViewCommunityReportsState();
}

class _ViewCommunityReportsState extends State<ViewCommunityReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Community Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('communities').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                int reports = documentSnapshot['reports'];
                if (reports > 0) {
                  return Dismissible(
                      key: Key(documentSnapshot.id),
                      child: Card(
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CommunityHome(
                                                documentSnapshot.id)));
                              },
                              child: Row(children: [
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                documentSnapshot['photoUrl']),
                                        radius: 40)),
                                Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(documentSnapshot.id,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 3),
                                      Text('Reports: $reports',
                                          style: TextStyle(fontSize: 18)),
                                      SizedBox(height: 3),
                                      Text(documentSnapshot['about'],
                                          style: TextStyle(
                                              fontSize: 15, color: Colors.grey),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis)
                                    ]))
                              ]))),
                      background: slideRightBackground(),
                      secondaryBackground: slideLeftBackground(),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          final bool res = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content:
                                      Text("Are you sure you want to delete ?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).buttonColor),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).errorColor),
                                      ),
                                      onPressed: () async {
                                        await deleteCommunity(
                                            documentSnapshot.id);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                          return res;
                        }
                        final bool res = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "Are you sure you want to remove all reports ?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: Theme.of(context).buttonColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "Remove reports",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('communities')
                                          .doc(documentSnapshot.id)
                                          .update({'reports': 0});
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                        return res;
                      });
                }
                return Container();
              },
            );
          }),
    );
  }

  // This will show slide right background
  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            Text(
              " Remove Reports",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  // This will show slide left background
  Widget slideLeftBackground() {
    return Container(
      color: Theme.of(context).errorColor,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete community",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
