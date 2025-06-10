import 'package:flutter/material.dart';

class WebLayout extends StatelessWidget {
  final Widget child;
  final String title;

  WebLayout({required this.child, this.title = 'Medease Web App'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(title),
      //   backgroundColor: Colors.teal.shade700,
      //   elevation: 4,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: () {
      //         // Implement logout logic or callback
      //       },
      //       tooltip: 'Logout',
      //     ),
      //   ],
      // ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal.shade50,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal.shade700),
                child: Text(
                  'Medease',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.teal.shade700),
                title: Text('Dashboard'),
                onTap: () {
                  // Navigate to dashboard
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.teal.shade700),
                title: Text('Profile'),
                onTap: () {
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.teal.shade700,
                ),
                title: Text('Appointments'),
                onTap: () {
                  // Navigate to appointments
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.medical_services,
                  color: Colors.teal.shade700,
                ),
                title: Text('Prescriptions'),
                onTap: () {
                  // Navigate to prescriptions
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        color: Colors.grey.shade100,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: child,
          ),
        ),
      ),
    );
  }
}
