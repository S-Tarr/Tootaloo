import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tootaloo/ui/screens/posts/following_screen.dart';
import '../components/bottom_nav_bar.dart';
import '../components/top_nav_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with TickerProviderStateMixin {
  double _cleanliness = 5;
  double _internet = 5;
  double _vibe = 5;
  String _review = "";
  String _restroom = "";
  AppUser _user = AppUser(username: 'null', id: 'null');
  bool _loaded = false;


  final int index = 1;

  late List<String> _restrooms = []; // restrooms we get from API

  @override
  void initState() {
    _getRestrooms().then((restrooms) => {
          setState(() {
            for (var restroom in restrooms) {
              _restrooms.add(restroom);
            }
          })
        });

    _getUser().then((user) => {
        setState(() {
          _user = user;
          _loaded = true;
        })
    });

    super.initState();
  }

  Future pause(Duration d) => Future.delayed(d);

  Future<AppUser> _getUser() async {
    await pause(const Duration(milliseconds: 1200));
    return await UserPreferences.getUser();
  }

  Future<List<String>> _getRestrooms() async {
    // get the building markers from the database/backend
    // TODO: change this url later
    String url = "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/restrooms/";
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    List<String> tempList = [];
    for (var restroom in responseData) {
      print(restroom["building"]);
      tempList.add(restroom["building"] + " " + restroom["room"]);
    }
    return tempList;
  }

  void submit(
      restroom, cleanliness, internet, vibe, overallRating, review) async {
    final response = await http.post(
      Uri.parse("http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/submit_rating/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'restroom': restroom,
        'cleanliness': cleanliness.toString(),
        'internet': internet.toString(),
        'vibe': vibe.toString(),
        'overall_rating': overallRating.toString(),
        'review': review
      }),
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          return const FollowingScreen(title: "App Settings");
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    // controls the text label we use as a search bar
    if(!_loaded) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "Review"),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical:250),
                child: Container(
                  height: 200,
                  width: 200,
                  child: const CircularProgressIndicator(
                    color: Color.fromRGBO(181, 211, 235, 1),
                    backgroundColor: Color.fromRGBO(223, 241, 255, 1),
                  ),
                ),
              ),
            ]),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: index,
        ),
      );
    }
    else if(_user.username == 'null' && _user.id == 'null') {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "Review"),
        body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
           Padding(
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
                      "Log-In to Write a Review!",
                      style: TextStyle(color:Colors.black, fontSize: 23,),
                    )),
              ),
          ),
        ]),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: index,
        ),
      );
    }
    else {
      return Scaffold(
        appBar: const TopNavBar(title: "Review"),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child:
              DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  showSearchBox: true,
                  disabledItemFn: (String s) => s.startsWith('I'),
                ),
                items: _restrooms,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Menu mode",
                    hintText: "country in menu mode",
                  ),
                ),
                onChanged: (value) {
                  _restroom = (value != null) ? value : '';
                },
                selectedItem: "",
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    const Text('Cleanliness: ', style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Slider(
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          value: _cleanliness,
                          label: '${roundDouble(_cleanliness, 1)}',
                          onChanged: (value) {
                            setState(() {
                              _cleanliness = value;
                            });
                          },
                        )),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    const Text('   Internet   : ',
                        style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Slider(
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          value: _internet,
                          label: '${roundDouble(_internet, 1)}',
                          onChanged: (value) {
                            setState(() {
                              _internet = value;
                            });
                          },
                        )),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    const Text('      Vibe      : ',
                        style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Slider(
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          value: _vibe,
                          label: '${roundDouble(_vibe, 1)}',
                          onChanged: (value) {
                            setState(() {
                              _vibe = value;
                            });
                          },
                        )),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    Text(
                        'Overall Rating: ${roundDouble(
                            (_vibe + _internet + _cleanliness) / 3.0, 1)}',
                        style: const TextStyle(fontSize: 20)),
                  ],
                )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write a Review',
                  ),
                  onChanged: (value) {
                    _review = value;
                  },
                )),
            Expanded(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: ElevatedButton(
                        onPressed: () {
                          submit(_restroom,
                              roundDouble(
                                  (_vibe + _internet + _cleanliness) / 3.0, 1),
                              _cleanliness,
                              _internet,
                              _vibe,
                              _review);
                        },
                        child: const Text('     Submit     '))))
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: index,
        ),
      );
    }
  }
}
