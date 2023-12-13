import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:shopp_app/pages/dashboard_screen.dart';

class adminScreen extends StatefulWidget {
  static const String id = 'Admin-Screen';

  @override
  State<adminScreen> createState() => _adminScreenState();
}

class _adminScreenState extends State<adminScreen> {
  Widget _selectedScreen = DashboardScreen();
  currentScreen(item) {
    switch (item.route) {
      case DashboardScreen.id:
        setState(() {
          _selectedScreen = DashboardScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: const Text('Admin Panel')),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'Dashboard',
            route: DashboardScreen.id,
            icon: Icons.dashboard,
          ),
        ],
        selectedRoute: adminScreen.id,
        onSelected: (item) {
          currentScreen(item);
          // if (item.route != null) {
          //   Navigator.of(context).pushNamed(item.route!);
          // }
        },
        header: Container(
          height: 50,
          width: double.infinity,
          color: Color.fromARGB(255, 68, 68, 68),
          child: const Center(
            child: Text(
              'Savoiur',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              '',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: _selectedScreen,
      ),
    );
  }
}
