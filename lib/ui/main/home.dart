import 'package:butler/ui/firebase/firebase_storage.dart';
import 'package:butler/ui/firebase/firestore_database.dart';
import 'package:butler/ui/firebase/realtime_database.dart';
import 'package:flutter/material.dart';
import 'package:butler/ui/widget/animated_bottom_bar.dart';
import 'package:butler/ui/screens/account.dart';
import 'package:butler/ui/screens/add.dart';
import 'package:butler/ui/screens/home_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final List<BarItem> barItems = [
    BarItem(
      text: "Home",
      icon: Icons.home,
      color: Colors.blue,
    ),
    BarItem(
      text: "compte",
      icon: Icons.account_box_rounded,
      color: Colors.blue,
    ),
  ];
  int selectedBarIndex = 0;
  final PageController _pageController = PageController();
  bool showMoreActions = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);
    //
    final realtimeDatabase = Provider.of<RealTimeDatabase>(context);
    //
    final firebaseFileStorage = Provider.of<FirebaseFileStorage>(context);
    //
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Stack(
          children: [
            SizedBox.expand(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  HomeScreen(),
                  Account(),
                  Add(),
                ],
                onPageChanged: (int index) {
                  setState(() {
                    selectedBarIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: selectedBarIndex == barItems.length ? 3 : 0,
        onPressed: () {
          _pageController.jumpToPage(barItems.length);
        },
        child: Icon(
          Icons.add,
          size: selectedBarIndex == barItems.length ? 35 : 25,
          color:
              selectedBarIndex == barItems.length ? Colors.white : Colors.grey,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        notchMargin: 1,
        shape: const CircularNotchedRectangle(),
        height: kToolbarHeight + 8,
        child: Row(
          children: [
            Expanded(
              child: AnimatedBottomBar(
                  currentIndex: selectedBarIndex,
                  barItems: barItems,
                  barStyle: BarStyle(fontSize: 15.0, iconSize: 35.0),
                  onBarTap: (index) {
                    setState(() {
                      selectedBarIndex = index;
                    });
                    _pageController.jumpToPage(index);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
