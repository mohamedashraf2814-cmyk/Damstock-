import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../features/add_property/add_property_screen.dart';
import '../../features/add_property/my_listings_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/compare/compare_screen.dart';
import '../../features/developers/developer_details_screen.dart';
import '../../features/inquiries/inquiries_screen.dart';
import '../../features/inquiries/inquiry_form_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/projects/project_details_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/properties/property_details_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';

class Routes {
  Routes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const otp = '/auth/otp';
  static const shell = '/home';
  static const property = '/properties/details';
  static const project = '/projects/details';
  static const projects = '/projects';
  static const developer = '/developers/details';
  static const compare = '/compare';
  static const map = '/map';
  static const inquiryNew = '/inquiries/new';
  static const inquiries = '/inquiries';
  static const addProperty = '/add-property';
  static const myListings = '/profile/listings';
  static const profile = '/profile';
}

class PropertyArgs {
  final String id;
  final String? heroTag;
  const PropertyArgs(this.id, {this.heroTag});
}

class InquiryArgs {
  final InquiryType type;
  final String? propertyId;
  final String? projectId;
  final String? developerId;
  const InquiryArgs({this.type = InquiryType.info, this.propertyId, this.projectId, this.developerId});
}

class LoginArgs {
  final bool fromInside;
  final String name;
  final String phone;
  const LoginArgs({this.fromInside = false, this.name = '', this.phone = ''});
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> generate(RouteSettings s) {
    final a = s.arguments;
    final Widget page = switch (s.name) {
      Routes.splash => const SplashScreen(),
      Routes.onboarding => const OnboardingScreen(),
      Routes.login => LoginScreen(args: a is LoginArgs ? a : const LoginArgs()),
      Routes.otp => OtpScreen(args: a is LoginArgs ? a : const LoginArgs()),
      Routes.shell => const MainShell(),
      Routes.property => a is PropertyArgs ? PropertyDetailsScreen(id: a.id, heroTag: a.heroTag) : PropertyDetailsScreen(id: '$a'),
      Routes.project => ProjectDetailsScreen(id: '$a'),
      Routes.projects => const ProjectsScreen(),
      Routes.developer => DeveloperDetailsScreen(id: '$a'),
      Routes.compare => const CompareScreen(),
      Routes.map => const MapScreen(),
      Routes.inquiryNew => InquiryFormScreen(args: a is InquiryArgs ? a : const InquiryArgs()),
      Routes.inquiries => const InquiriesScreen(),
      Routes.addProperty => const AddPropertyScreen(),
      Routes.myListings => const MyListingsScreen(),
      Routes.profile => const ProfileScreen(),
      _ => const MainShell(),
    };

    return PageRouteBuilder(
      settings: s,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, anim, secondary, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, .035), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static void toShell(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.settings.name == Routes.shell || r.isFirst);
  }
}
