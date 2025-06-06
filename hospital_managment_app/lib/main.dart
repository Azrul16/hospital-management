import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/patient_register_screen.dart';
import 'screens/auth/doctor_register_screen.dart';
import 'screens/patient/patient_home.dart';
import 'screens/doctor/doctor_home.dart';
import 'screens/admin/admin_home.dart';
import 'services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/doctor.dart';
import 'models/patient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final role = await _fetchUserRole(user.uid);
      setState(() {
        _isLoggedIn = true;
        _userRole = role;
      });
    }
  }

  Future<String> _fetchUserRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('role')) {
        return data['role'] as String;
      }
    }
    return 'patient'; // default role
  }

  Future<dynamic> _getUserData() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection(_userRole == 'patient' ? 'patients' : 'doctors')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        return _userRole == 'patient'
            ? Patient.fromMap(data)
            : Doctor.fromMap(data);
      }
    }
    return null;
  }

  Future<void> _onLoginSuccess(BuildContext context) async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        final role = await _fetchUserRole(user.uid);
        if (!mounted) return;
        setState(() {
          _isLoggedIn = true;
          _userRole = role;
        });
        await _handleInitialRoute(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoggedIn = false;
        _userRole = '';
      });
    }
  }

  void _onLogout() {
    _authService.logout();
    setState(() {
      _isLoggedIn = false;
      _userRole = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF87CEEB),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF87CEEB),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF87CEEB),
          secondary: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF87CEEB),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF87CEEB)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF0D47A1),
          secondary: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF0D47A1),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF64B5F6)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          return LoginScreen(
            onLoginSuccess: () async {
              await _onLoginSuccess(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _handleInitialRoute(BuildContext context) async {
    if (!_isLoggedIn) {
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final userData = await _getUserData();

      // Hide loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;

      switch (_userRole) {
        case 'patient':
          if (userData is Patient) {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PatientHome(patientData: userData.toMap()),
              ),
            );
          } else {
            throw Exception('Invalid patient data');
          }
          break;
        case 'doctor':
          if (userData is Doctor) {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorHome(doctorData: userData.toMap()),
              ),
            );
          } else {
            throw Exception('Invalid doctor data');
          }
          break;
        case 'admin':
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHome()),
          );
          break;
        default:
          throw Exception('Invalid user role');
      }
    } catch (e) {
      if (!mounted) return;

      // Hide loading indicator if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      // Reset login state
      setState(() {
        _isLoggedIn = false;
        _userRole = '';
      });
    }
  }
}
