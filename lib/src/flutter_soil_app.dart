import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class FlutterSoilApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fluter Soil App",
      home: FlutterSoilHomeScreen(),
    );
  }
}

class FlutterSoilHomeScreen extends StatefulWidget {
  @override
  _FlutterSoilHomeScreenState createState() => _FlutterSoilHomeScreenState();
}

class _FlutterSoilHomeScreenState extends State<FlutterSoilHomeScreen> {
  FirebaseUser _user;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase().reference();

  @override
  void initState() {
    super.initState();
  }

  _signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = await _auth.signInWithCredential(credential);
      print("signed in " + user.displayName);
      _user = user;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

//  _signInWithEmail() async {
//    try {
//      final AuthCredential credential = EmailAuthProvider.getCredential(
//        email: "raveeshr503@gmail.com",
//        password: "123abcxyz",
//      );
//
//      final FirebaseUser user = await _auth.signInWithCredential(credential);
//      print("signed in " + user.displayName);
//      _user = user;
//      setState(() {});
//    }catch(e){
//      print(e);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Soil App'),
      ),
      floatingActionButton: _user == null
          ? FloatingActionButton(
              onPressed: _signInWithGoogle,
              child: Text(
                'G',
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(color: Colors.white),
              ),
            )
          : null,
      body: Center(
        child: StreamBuilder<Event>(
            stream: _db.child('sensor').onValue,
            builder: (context, AsyncSnapshot<Event> snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();

              var allData = snapshot.data.snapshot.value;
              var dhtData = allData["dht"] as Map;
              var moistData = allData["moist"];
              var rainData = allData["rain"];
              var tempData = allData["temp"];
              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "DHT",
                        style: Theme.of(context).textTheme.display4,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((_, int index) {
                        return ListTile(
                          title: Text(dhtData.keys.toList()[index]),
                          onTap: () {},
                          leading: Text(dhtData.values
                              .toList()[index]["temp"]
                              .toString()),
                          subtitle: Text(dhtData.values
                              .toList()[index]["humidity"]
                              .toString()),
                          isThreeLine: true,
                        );
                      }, childCount: dhtData.length),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "MOIST",
                        style: Theme.of(context).textTheme.display4,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        moistData.toString(),
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "RAIN",
                        style: Theme.of(context).textTheme.display4,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        rainData.toString(),
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "TEMP",
                        style: Theme.of(context).textTheme.display4,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        tempData.toString(),
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
