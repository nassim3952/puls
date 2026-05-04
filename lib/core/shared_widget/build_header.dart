import 'package:flutter/material.dart';

import '../color.dart';

Widget appBuildHeader() {
  // On peut le laisser simple pour l'instant
  return Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
    ),
    child: Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            spacing: 14,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today),
                label: Text("Période"),
              ),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.layers_outlined),
                label: Text("Type"),

              ),
              OutlinedButton.icon(
                onPressed: () {},
                label: Text("Service"),
                icon: const Icon(Icons.medical_services_outlined),

              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.explore_outlined),
                label: Text("Exploration"),

              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.output_rounded),
                label: Text("Sortie"),

              ),
            ],

          ),

          Spacer(),



          ElevatedButton(
            onPressed: (){},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMenthe,
              foregroundColor: AppColors.surface,
            ),
            child: Text('Actualiser'),
          ),



        ],
      ),
    ),
  );
}
