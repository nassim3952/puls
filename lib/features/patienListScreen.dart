// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../core/provider/patient_provider.dart';
//
//
// class PatientListScreen extends ConsumerWidget {
//   const PatientListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // On "écoute" le provider
//     // AVANT
// // final patientsAsync = ref.watch(patientsListProvider);
//
// // APRÈS (On écoute la passoire maintenant)
//     final patientsAsync = ref.watch(filteredPatientsProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Suivi des Patients')),
//       body: patientsAsync.when(
//         // 1. État : Données reçues avec succès
//         data: (patients) => ListView.builder(
//           itemCount: patients.length,
//           itemBuilder: (context, index) {
//             final patient = patients[index];
//             return ListTile(
//               title: Text("${patient.firstName} ${patient.lastName}"),
//               subtitle: Text("Service: ${patient.latestVisit?.service ?? '–'} - IPP: ${patient.ipp}"),
//               trailing: Icon(
//                 Icons.circle,
//                 color: (patient.latestVisit?.hasAlert ?? false) ? Colors.red : Colors.green,
//               ),
//             );
//           },
//         ),
//         // 2. État : En cours de chargement (lecture du JSON)
//         loading: () => const Center(child: CircularProgressIndicator()),
//         // 3. État : Quelque chose a cassé
//         error: (err, stack) => Center(child: Text('Erreur: $err')),
//       ),
//     );
//   }
// }