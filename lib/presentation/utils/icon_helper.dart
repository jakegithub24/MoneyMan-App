import 'package:flutter/material.dart';

class AppIconHelper {
  static final Map<int, IconData> _iconRegistry = {
    Icons.restaurant_rounded.codePoint: Icons.restaurant_rounded,
    Icons.directions_car_rounded.codePoint: Icons.directions_car_rounded,
    Icons.shopping_bag_rounded.codePoint: Icons.shopping_bag_rounded,
    Icons.movie_rounded.codePoint: Icons.movie_rounded,
    Icons.bolt_rounded.codePoint: Icons.bolt_rounded,
    Icons.health_and_safety_rounded.codePoint: Icons.health_and_safety_rounded,
    Icons.school_rounded.codePoint: Icons.school_rounded,
    Icons.flight_takeoff_rounded.codePoint: Icons.flight_takeoff_rounded,
    Icons.grid_view_rounded.codePoint: Icons.grid_view_rounded,
    Icons.work_rounded.codePoint: Icons.work_rounded,
    Icons.laptop_mac_rounded.codePoint: Icons.laptop_mac_rounded,
    Icons.trending_up_rounded.codePoint: Icons.trending_up_rounded,
    Icons.card_giftcard_rounded.codePoint: Icons.card_giftcard_rounded,
    Icons.redeem_rounded.codePoint: Icons.redeem_rounded,
    Icons.account_balance_wallet_rounded.codePoint: Icons.account_balance_wallet_rounded,
    Icons.receipt_long_rounded.codePoint: Icons.receipt_long_rounded,
    Icons.home_rounded.codePoint: Icons.home_rounded,
    Icons.pets_rounded.codePoint: Icons.pets_rounded,
    Icons.fitness_center_rounded.codePoint: Icons.fitness_center_rounded,
    Icons.local_cafe_rounded.codePoint: Icons.local_cafe_rounded,
    Icons.local_grocery_store_rounded.codePoint: Icons.local_grocery_store_rounded,
    Icons.wifi_rounded.codePoint: Icons.wifi_rounded,
    Icons.build_rounded.codePoint: Icons.build_rounded,
    Icons.child_care_rounded.codePoint: Icons.child_care_rounded,
    Icons.local_hospital_rounded.codePoint: Icons.local_hospital_rounded,
    Icons.savings_rounded.codePoint: Icons.savings_rounded,
    Icons.category_rounded.codePoint: Icons.category_rounded,
  };

  static IconData getIcon(int codePoint) {
    return _iconRegistry[codePoint] ?? Icons.category_rounded;
  }
}
