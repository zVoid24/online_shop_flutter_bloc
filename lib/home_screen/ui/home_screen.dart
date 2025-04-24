// lib/features/home_screen/ui/home_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/product_database.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/features/cart/ui/cart.dart';
import 'package:online_shop/features/help/ui/help.dart';
import 'package:online_shop/features/home/ui/home.dart';
import 'package:online_shop/features/order_history/ui/order_history.dart';
import 'package:online_shop/features/profile/bloc/profile_bloc.dart';
import 'package:online_shop/features/profile/ui/profile.dart';
import 'package:online_shop/features/wrapper/ui/wrapper.dart';
import 'package:online_shop/home_screen/bloc/home_screen_bloc.dart';
import 'package:online_shop/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_shop/features/search/ui/search.dart';

class HomeScreen extends StatefulWidget {
  int selectedIndex;
  HomeScreen({super.key, this.selectedIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductDatabase _productDatabase = ProductDatabase();
  static const List<String> _titles = ['Home', 'Search', 'Cart', 'Profile'];

  final HomeScreenBloc _homeScreenBloc = HomeScreenBloc();
  final Database db = Database();

  late final Future<UserData?> userDatabase;

  _HomeScreenState() : userDatabase = _initializeUserDatabase();

  static Future<UserData?> _initializeUserDatabase() async {
    final User? user = await Database().getCurrentUser();
    if (user == null) {
      return null;
    }
    return UserDatabase(uid: user.uid).getUserData();
  }

  @override
  void initState() {
    super.initState();
    _homeScreenBloc.add(HomeScreenInitialEvent());
  }

  @override
  void dispose() {
    _homeScreenBloc.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      _homeScreenBloc.add(HomeScreenInitialEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeScreenBloc, HomeScreenState>(
      bloc: _homeScreenBloc,
      listenWhen: (previous, current) => current is HomeScreenActionState,
      buildWhen: (previous, current) => current is HomeScreenLoadedState,
      listener: (context, state) {
        if (state is HomeScreenNavigateToHelpState) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Help()),
          );
        } else if (state is HomeScreenNavigateToOrderHistoryState) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderHistory()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _titles[widget.selectedIndex],
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
                          'Please sign in',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                'https://robohash.org/${snapshot.data!.email}.png?set=set1',
                              ),
                            ),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                  leading: const Icon(Icons.history),
                  title: const Text('Order History'),
                  onTap: () {
                    _homeScreenBloc.add(
                      HomeScreenNavigateToOrderHistoryEvent(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    _homeScreenBloc.add(HomeScreenLogoutEvent());
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Wrapper(),
                      ), // Replace with your Wrapper
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          body: () {
            switch (widget.selectedIndex) {
              case 0:
                return const Home();
              case 1:
                return Search(productDatabase: _productDatabase);
              case 2:
                return const Cart();
              case 3:
                return BlocProvider(
                  create:
                      (context) => ProfileBloc(
                        userDatabase: UserDatabase(
                          uid: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      ),
                  child: const Profile(),
                );
              default:
                return const Center(child: Text('Page not found'));
            }
          }(),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: widget.selectedIndex,
            selectedItemColor: const Color(0xFF328E6E),
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
