import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/features/cart/ui/cart.dart';
import 'package:online_shop/features/home/ui/home.dart';
import 'package:online_shop/features/profile/ui/profile.dart';
import 'package:online_shop/home_screen/bloc/home_screen_bloc.dart';
import 'package:online_shop/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [Home(), Cart(), Profile()];
  static const List<String> _titles = ['Home', 'Cart', 'Profile'];

  final HomeScreenBloc _homeScreenBloc = HomeScreenBloc();
  final Database db = Database();
  late final String uid;
  // Initialize userDatabase at declaration, removing 'late'
  final Future<UserData?> userDatabase;

  _HomeScreenState() : userDatabase = _initializeUserDatabase();

  static Future<UserData?> _initializeUserDatabase() async {
    final User? user = await Database().getCurrentUser();
    final String uid = user?.uid ?? '';
    return UserDatabase(uid: uid).getUserData();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _homeScreenBloc.add(HomeScreenInitialEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeScreenBloc, HomeScreenState>(
      bloc: _homeScreenBloc,
      listenWhen: (previous, current) => current is HomeScreenActionState,
      buildWhen: (previous, current) => current is HomeScreenLoadedState,
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF328E6E),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF328E6E)),
                  child: FutureBuilder<UserData?>(
                    future: userDatabase,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        );
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return const Text(
                          'Error',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                'https://robohash.org/${snapshot.data!.email}.png?set=set4',
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  snapshot.data!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  snapshot.data!.email,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help'),
                  onTap: () {
                    _homeScreenBloc.add(HomeScreenNavigateToHelpEvent());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    _homeScreenBloc.add(HomeScreenNavigateToSettingsEvent());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    _homeScreenBloc.add(HomeScreenLogoutEvent());
                  },
                ),
              ],
            ),
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF328E6E),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFFEAECCC),
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
