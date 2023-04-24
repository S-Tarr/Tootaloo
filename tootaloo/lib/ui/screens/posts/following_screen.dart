import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/post_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final int index = 0;

  late List<Rating> _ratings;

  AppUser _user = AppUser(username: 'null', id: 'null');
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _ratings = [];
    _getRatings().then((ratings) => {
          setState(() {
            for (var rating in ratings) {
              _ratings.add(rating);
            }
          })
        });

    _getUser().then((user) => {
      setState(() {
        _user = user;
        _loaded = true;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!_loaded) {
      return Scaffold(
        appBar: const TopNavBar(title: "Following"),
        body: const Scaffold(
          appBar: PostNavBar(title: "bitches", selectedIndex: 1),
          body: Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(181, 211, 235, 1),
              backgroundColor: Color.fromRGBO(223, 241, 255, 1),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: index),
      );
    }
    if(_user.username == 'null' && _user.id == 'null') {
      return Scaffold(
        appBar: const TopNavBar(title: "Following"),
        body: Scaffold(
          appBar: const PostNavBar(title: "bitches", selectedIndex: 1),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical:250),
              child: Container(
                height: 75,
                width: 350,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(181, 211, 235, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const LoginScreen();
                      }));
                    },
                    child: const Text(
                      "Log-In to Follow Your Friends!",
                      style: TextStyle(color:Colors.black, fontSize: 20,),
                    )),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: index),
      );
    }
    return Scaffold(
      appBar: const TopNavBar(title: "Following"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 1),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children:
                _ratings.map((rating) => ListTileItem(rating: rating)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

Future pause(Duration d) => Future.delayed(d);

Future<AppUser> _getUser() async {
  await pause(const Duration(milliseconds: 700));
  return await UserPreferences.getUser();
}

void _updateVotes(id, int votes, String type) async {
  final response = await http.post(
    Uri.parse('http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update_votes/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'type': type,
      'id': id.toString(),
      'votes': votes.toString(),
    }),
  );
}

Future<bool> _checkVoted(ratingId) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return true;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse('http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/check_votes/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body:
        jsonEncode(<String, String>{'rating_id': ratingId.toString(), 'user_id': userId}),
  );
  if (response.body.toString() == 'false') {
    return false;
  }
  return true;
}

class Rating {
  final id;
  final String building;
  final String by;
  final String room;
  final String review;
  final num overallRating;
  final num internet;
  final num cleanliness;
  final num vibe;
  final int upvotes;
  final int downvotes;

  Rating({
    required this.id,
    required this.building,
    required this.by,
    required this.room,
    required this.review,
    required this.overallRating,
    required this.internet,
    required this.cleanliness,
    required this.vibe,
    required this.upvotes,
    required this.downvotes,
  });
}

Future<List<Rating>> _getRatings() async {
  // get the building markers from the database/backend
  // TODO: change this url later
  String url = "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/following_ratings/";
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);

  List<Rating> ratings = [];
  for (var rating in responseData) {
    Rating ratingData = Rating(
        id: rating["_id"],
        building: rating["building"],
        by: rating["by"],
        room: rating["room"],
        review: rating["review"],
        overallRating: rating["overall_rating"],
        internet: rating["internet"],
        cleanliness: rating["cleanliness"],
        vibe: rating["vibe"],
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"]);
    ratings.add(ratingData);
  }
  return ratings;
}

class ListTileItem extends StatefulWidget {
  final Rating rating;
  const ListTileItem({super.key, required this.rating});
  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  int _upvotes = 0;
  int _downvotes = 0;
  @override
  Widget build(BuildContext context) {
    print("builtTile");
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.white10,
        child: ListTile(
          //visualDensity: const VisualDensity(vertical: 3), // to expand
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          // onTap: () async {
          //   // ignore: deprecated_member_use
          //   if (await canLaunch(e.url)) {
          //     await launch(e.url);
          //   } else {
          //     throw 'Could not launch ${e.url}';
          //   }
          // },
          leading:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 30),
                Text(widget.rating.by)
              ],
            ),
            Expanded(child: RatingBarIndicator(
              rating: widget.rating.overallRating.toDouble(),
              itemCount: 5,
              itemSize: 20.0,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Color.fromARGB(255, 218, 196, 0),
              )
            ))
          ]),
          title: Text(
            widget.rating.building + widget.rating.room,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(widget.rating.review),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_upward, color: Colors.green),
                      onPressed: () {
                        if (_upvotes < 1) {
                          _checkVoted(widget.rating.id).then((value) {
                            if (!value) {
                              setState(() {
                                _upvotes += 1;
                              });
                              _updateVotes(widget.rating.id, widget.rating.upvotes + _upvotes, "upvotes");
                            }
                          });
                        }
                      },
                    ),
                    Text(
                      '${widget.rating.upvotes + _upvotes}',
                      style: const TextStyle(color: Colors.green),
                    )
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_downward, color: Colors.red),
                      onPressed: () {
                        if (_downvotes < 1) {
                          _checkVoted(widget.rating.id).then((value) {
                            if (!value) {
                              setState(() {
                                _downvotes += 1;
                              });
                              _updateVotes(widget.rating.id, widget.rating.downvotes + _downvotes, "downvotes");
                            }
                          });
                        }
                      },
                    ),
                    Text(
                      '${widget.rating.downvotes + _downvotes}',
                      style: const TextStyle(color: Colors.red),
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
