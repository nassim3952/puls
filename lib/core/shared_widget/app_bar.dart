import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:puls/core/color.dart';

Widget _buildUserSection() {
  return Row(
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Dr. Marie Dubois",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Responsable qualité",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(width: 10),
      CircleAvatar(radius: 18, child: const Icon(Icons.person)),
    ],
  );
}

AppBar AppAppbar() {
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 2,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2),spreadRadius: 1)],
      ),
    ),
    backgroundColor: AppColors.surface,

    foregroundColor: Colors.white,
    shadowColor: AppColors.shadow,
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset('assets/logo.png', width: 280, height: 32),
          const SizedBox(width: 40),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  fillColor: AppColors.error,
                  hintText: 'Recherche...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primaryMenthe,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
          _buildUserSection(),
          const SizedBox(width: 20),
          Icon(Icons.settings_sharp, color: AppColors.textPrimary),
          const SizedBox(width: 15),
          Badge(
            label: const Text('3'),
            child: const Icon(
              Icons.notifications_sharp,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    ),
  );
}
