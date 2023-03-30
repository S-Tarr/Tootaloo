import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/searches_tiles/UserTileItem.dart';
import 'package:tootaloo/ui/models/User.dart';

/* Define the screen itself */
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

/* Define screen state */
class _UserSearchScreenState extends State<UserSearchScreen> {
  final int index = 0;

  List<UserTileItem> _user = [];
  TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "User Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "User Search", selectedIndex: 1),
        body: Column(children: [
          Row(children: [
            Flexible(
                child: TextField(
              controller: userController,
              decoration: const InputDecoration(
                  hintText: 'Username',
                  contentPadding: EdgeInsets.all(2.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(color: Colors.blue, width: 0.5),
                  )),
            )),
            OutlinedButton.icon(
                onPressed: () {
                  if (userController.text.isEmpty) return; // Sanity Check
                  getSearchedUser(userController.text).then((user) => {
                        setState(() {
                          bool followed = false;
                          // TODO: define currently logged in user here
                          // TODO: adjust `followed` based on currently logged in user's `following` list

                          UserTileItem userTileItem = UserTileItem(
                            username: user.username,
                            followed: followed,
                          );
                          _user = [userTileItem];
                        })
                      });
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue)),
          ]),
          Expanded(
              child: Center(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: _user),
          ))
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}

/* Get User the user searches for from the backend */
Future<User> getSearchedUser(String username) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {"username": username};
  Uri uri = Uri.https(
      "3091-128-210-106-49.ngrok.io", "/user-by-username/", queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  // Build User model based on response
  User userData = User(
      username: responseData["username"],
      posts_ids: responseData["posts"],
      following_ids: responseData["following"]);

  return userData;
}