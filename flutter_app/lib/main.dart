import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/client_home.dart';
import 'screens/provider_home.dart';
import 'screens/provider_apply.dart';
import 'screens/provider_status.dart';
import 'screens/provider_list.dart';
import 'screens/booking_create.dart';
import 'screens/client_bookings.dart';
import 'screens/provider_bookings.dart';
import 'screens/admin_home.dart';
import 'screens/admin_providers.dart';
import 'screens/booking_detail.dart';
import 'screens/chat_screen.dart';
import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Sahayak',
        theme: buildAppTheme(),
        home: AuthWrapper(),
        routes: {
          '/login': (_) => LoginScreen(),
          '/register': (_) => RegisterScreen(),
          '/client': (_) => ClientHome(),
          '/client/providers': (_) => ProviderListScreen(category: '', area: ''),
          '/client/booking/create': (_) => BookingCreateScreen(),
          '/client/bookings': (_) => ClientBookingsScreen(),
          '/provider': (_) => ProviderHome(),
          '/provider/apply': (_) => ProviderApplyScreen(),
          '/provider/status': (_) => ProviderStatus(),
          '/provider/bookings': (_) => ProviderBookingsScreen(),
          '/admin': (_) => AdminHome(),
          '/admin/providers': (_) => AdminProvidersScreen(),
          // Booking related screens
          '/booking/detail': (_) => BookingDetailScreen(),
          '/booking/chat': (_) => ChatScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return FutureBuilder<bool>(
      future: auth.tryAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!snapshot.hasData || !snapshot.data!) return LoginScreen();
        // navigate to role-based home
        final role = auth.userRole;
        if (role == 'client') return ClientHome();
        if (role == 'provider') return ProviderHome();
        if (role == 'admin') return AdminHome();
        return LoginScreen();
      },
    );
  }
}
