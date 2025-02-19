import 'package:flutter/material.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';

class AppRoutes {
	static const String splash = '/';
	static const String login = '/login';
	static const String register = '/register';
	static const String home = '/home';

	static Route<dynamic> onGenerateRoute(RouteSettings settings) {
		switch (settings.name) {
			case splash:
				return MaterialPageRoute(builder: (_) => const SplashScreen());
			case login:
				return MaterialPageRoute(builder: (_) => const LoginScreen());
			case register:
				return MaterialPageRoute(builder: (_) => const RegisterScreen());
			case home:
				return MaterialPageRoute(builder: (_) => const HomeScreen());
			default:
				return MaterialPageRoute(
					builder: (_) => Scaffold(
						body: Center(
							child: Text('No route defined for ${settings.name}'),
						),
					),
				);
		}
	}
}