import 'package:flutter/material.dart';
import 'package:revuer/coming_soon.dart';
import 'package:revuer/ui/help-support/help_support.dart';
import 'package:revuer/ui/refer_earn/refer_earn_screen.dart';
import '../ui/campaign/my-campaign-details-pending.dart';
import '../ui/social/social_after_personal_info.dart';
import '../ui/splash/splash_screen.dart';
import '../ui/onboarding/onboarding_screen.dart';
import '../ui/auth/signup.dart';
import '../ui/auth/login.dart';
import '../ui/personal/personal_info.dart';
import '../ui/welcome/welcome.dart';
import '../ui/main/main.dart';
import '../ui/profile/profile.dart';
import '../ui/campaign/campaign-details.dart';
import '../ui/profile-setup/setup-profile.dart';
import '../ui/profile-setup/social-profiles.dart';
import '../ui/profile-setup/subscription.dart';
import '../ui/profile-setup/payment-mode.dart';
import '../ui/profile-setup/payment-mode-profile.dart';
import '../ui/profile-setup/privacy-policy.dart';
import '../ui/personal/save-personal-info.dart';
import '../ui/interests/interests.dart';
import '../ui/social/connect-social-account.dart';
import '../ui/withdraw/withdraw-earnings.dart';
import '../ui/history/earning-history.dart';
import '../ui/policy/privacy-policy-tc.dart';
import '../ui/campaign/my-campaign-details.dart';
import '../ui/task/product_review_task_details.dart';
import '../ui/earnings/my-earnings.dart';

class Routes {
  static Map<String, WidgetBuilder> routes = {
    '/initial': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/signup': (context) => const SignupScreen(),
    '/login': (context) => const LoginScreen(),
    '/personalinfo': (context) => const PersonalInfoScreen(),
    '/welcome': (context) => const WelcomeScreen(),
    '/main': (context) => MainScreen(index: 0),
    '/profile': (context) =>  ProfileScreen(),
    '/refer-earn-screen': (context) =>  ReferEarnScreen(),
    '/campaign-details': (context) =>  CampaignDetailsScreen(),
    '/setup-profile': (context) => const SetupProfileScreen(),
    '/social-profiles': (context) => const SocialProfilesScreen(),
    '/subscription': (context) => const SubscriptionScreen(),
    '/payment-mode': (context) => const PaymentModeScreen(),
    '/payment-mode-profile': (context) => PaymentModeProfileScreen(location: '', patmentMethod: 1),
    '/privacy-policy': (context) => const PrivacyPolicyScreen(location: '', patmentMethod: 1),
    '/save-profile': (context) => const SavePersonalInfoScreen(),
    '/interests': (context) => const InterestsScreen(),
    '/social-account': (context) => const SocialAccountScreen(),
    '/social-account-after-personal-info': (context) => const SocialAccountScreenAfterPersonalInfo(),
    '/withdraw-earnings': (context) => const WithdrawEarningsScreen(),
    /*'/earning-history': (context) => const EarningHistoryScreen(),*/
    '/earning-history': (context) =>  MyEarningsScreen(),
    '/privacy-policy-tc': (context) => const PrivacyPolicyTcScreen(),
    '/my-campaign-details': (context) => MyCampaignDetailsScreen(index: 0),
    '/my-campaign-details-pending': (context) => const MyCampaignDetailsPendingScreen(),
    // '/campaign-task': (context) => ProductReviewTaskDetails(),
    '/coming-soon': (context) => const ComingSoonScreen(),

    '/mainNotify': (context) => MainScreen(index: 0),
    '/my-campaign-details_notify1': (context) => MyCampaignDetailsScreen(location: "notify", index: 0,),
    '/my-campaign-details_notify2': (context) => MyCampaignDetailsScreen(location: "notify", index: 1,),
    '/campaign-details_notify': (context) =>   CampaignDetailsScreen(),
    '/earning-history_notify': (context) =>  MyEarningsScreen(location: "notify"),

    '/help_support': (context) => const HelpSupportScreen(),
  };
}
