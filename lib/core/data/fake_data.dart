
import 'dart:math';

import '../../features/dashboard/presentation/model/domain/verbatim_node.dart';
import '../color.dart';
import '../models/chart_model.dart';

final splineData1 = [
  SplineGroup(
    name: "Oui totalement",
    color: AppColors.success,
    data: [
      ChartDataSpline('Jan', 60),
      ChartDataSpline('Feb', 45),
      ChartDataSpline('Mar', 52),
      ChartDataSpline('Apr', 45),
      ChartDataSpline('May', 55),
    ],
  ),
  SplineGroup(
    name: "En partie",
    color: AppColors.warning,
    data: [
      ChartDataSpline('Jan', 30),
      ChartDataSpline('Feb', 55),
      ChartDataSpline('Mar', 59),
      ChartDataSpline('Apr', 40),
      ChartDataSpline('May', 45),
    ],
  ),
  SplineGroup(
    name: "Non",
    color: AppColors.error,
    data: [
      ChartDataSpline('Jan', 38),
      ChartDataSpline('Feb', 58),
      ChartDataSpline('Mar', 67),
      ChartDataSpline('Apr', 49),
      ChartDataSpline('May', 60),
    ],
  ),
  SplineGroup(
    name: "En attente",
    color: AppColors.neutral,
    data: [
      ChartDataSpline('Jan', 20),
      ChartDataSpline('Feb', 25),
      ChartDataSpline('Mar', 39),
      ChartDataSpline('Apr', 20),
      ChartDataSpline('May', 25),
    ],
  ),
];

final splineData2 = [
  SplineGroup(
    name: "kpi",
    data: [
      ChartDataSpline('Jan', 60),
      ChartDataSpline('Feb', 45),
      ChartDataSpline('Mar', 52),
      ChartDataSpline('Apr', 45),
      ChartDataSpline('May', 55),
    ],
  ),
];


final pie2data = [
  ChartDataPie('Oui totalement', 45, AppColors.success),
  ChartDataPie('En partie', 35, AppColors.warning),
  ChartDataPie('Non', 30, AppColors.error),
  ChartDataPie('En attente', 38, AppColors.neutral),
];

final pie6data = [
  ChartDataPie('Oui', 192, AppColors.success),
  ChartDataPie('Non', 65, AppColors.warning),
];


final List<BarData> dataIAR = [
  BarData(label: "Douleur", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Anxiété", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Attente", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Accueil", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Suivi", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Propreté", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Compétence", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Disponibilité", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Facturation", value: Random().nextInt(100), valence: Valence.bonne),
];
final List<BarData> dataVPQS = [
  BarData(label: "Accueil", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Attente", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Empathie", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Écoute", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Médecin", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Soins", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Douleur", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Explication", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Propreté", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Hygiène", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Coordination", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Orientation", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Matériel", value: Random().nextInt(100), valence: Valence.bonne),
];
final List<BarData> dataMCR = [
  BarData(label: "geste soignant", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Soulagement", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Réconfort", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Douleur", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Attente", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Indifférence", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Stress", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Interaction humaine", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Compétence", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Confiance", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Propreté", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Structure", value: Random().nextInt(100), valence: Valence.bonne),
  BarData(label: "Flexibilité", value: Random().nextInt(100), valence: Valence.bonne),
];

final List<PyramidData> chartData = [
  PyramidData('0-4', -4.5, 4.2),
  PyramidData('5-9', -4.5, 4.2),
  PyramidData('10-14', -4.3, 4.1),
  PyramidData('15-19', -4.1, 3.8),
  PyramidData('20-24', -4.0, 3.7),
  PyramidData('25-29', -3.9, 3.7),
  PyramidData('30-34', -3.9, 3.8),
  // Ajoute le reste de tes tranches ici...
];


final kpi1Jauge = 85;
final kpi1Spline = splineData2;
final kpi2Pie = pie2data;
final kpi2Spline = splineData1;


final kpi6Pie = pie6data;


final data = [
  // --- RELATIONNEL ---
  VerbatimNode(
    label: 'Relationnel',
    children: [
      VerbatimNode(
        label: 'Communication',
        children: [
          VerbatimNode(label: 'Écoute', value: 52),
          VerbatimNode(label: 'Empathie', value: 41),
          VerbatimNode(label: 'Explication', value: 63),
          VerbatimNode(label: 'Indifférence', value: 14),
          VerbatimNode(label: 'Sourire', value: 39),
          VerbatimNode(label: 'Gentillesse', value: 58),
          VerbatimNode(label: 'Politesse', value: 47),
        ],
      ),
      VerbatimNode(
        label: 'Accueil',
        children: [
          VerbatimNode(label: 'Accueil physique', value: 44),
          VerbatimNode(label: 'Orientation', value: 31),
          VerbatimNode(label: 'Interaction humaine', value: 25),
          VerbatimNode(label: 'Disponibilité', value: 36),
          VerbatimNode(label: 'Standard téléphonique', value: 22),
        ],
      ),
    ],
  ),

  // --- SOIN & TECHNIQUE ---
  VerbatimNode(
    label: 'Soin & Technique',
    children: [
      VerbatimNode(
        label: 'Qualité Médicale',
        children: [
          VerbatimNode(label: 'Médecin', value: 85),
          VerbatimNode(label: 'Geste soignant', value: 74),
          VerbatimNode(label: 'Compétence', value: 92),
          VerbatimNode(label: 'Confiance', value: 81),
          VerbatimNode(label: 'Douceur', value: 56),
          VerbatimNode(label: 'Professionnalisme', value: 69),
        ],
      ),
      VerbatimNode(
        label: 'Confort Physique',
        children: [
          VerbatimNode(label: 'Douleur', value: 42),
          VerbatimNode(label: 'Soulagement', value: 38),
          VerbatimNode(label: 'Réconfort', value: 29),
          VerbatimNode(label: 'Stress', value: 54),
          VerbatimNode(label: 'Sommeil', value: 41),
          VerbatimNode(label: 'Aide aux gestes', value: 27),
        ],
      ),
    ],
  ),

  // --- ORGANISATION ---
  VerbatimNode(
    label: 'Organisation',
    children: [
      VerbatimNode(
        label: 'Gestion du Temps',
        children: [
          VerbatimNode(label: 'Attente', value: 124),
          VerbatimNode(label: 'Longue attente', value: 89),
          VerbatimNode(label: 'Flexibilité', value: 15),
          VerbatimNode(label: 'Ponctualité', value: 21),
          VerbatimNode(label: 'Rapidité', value: 43),
        ],
      ),
      VerbatimNode(
        label: 'Logistique',
        children: [
          VerbatimNode(label: 'Coordination', value: 37),
          VerbatimNode(label: 'Disponibilité du matériel', value: 24),
          VerbatimNode(label: 'Facturation', value: 19),
          VerbatimNode(label: 'Sortie de l\'hôpital', value: 45),
          VerbatimNode(label: 'Dossier médical', value: 32),
        ],
      ),
    ],
  ),

  // --- ENVIRONNEMENT ---
  VerbatimNode(
    label: 'Environnement',
    children: [
      VerbatimNode(
        label: 'Hygiène',
        children: [
          VerbatimNode(label: 'Propreté', value: 98),
          VerbatimNode(label: 'Manque d\'hygiène', value: 12),
          VerbatimNode(label: 'Odeurs', value: 18),
          VerbatimNode(label: 'Entretien', value: 54),
        ],
      ),
      VerbatimNode(
        label: 'Infrastructure',
        children: [
          VerbatimNode(label: 'Structure', value: 42),
          VerbatimNode(label: 'Chambre', value: 67),
          VerbatimNode(label: 'Repas / Nourriture', value: 88),
          VerbatimNode(label: 'Bruit', value: 73),
          VerbatimNode(label: 'Signalisation', value: 26),
          VerbatimNode(label: 'Température', value: 19),
          VerbatimNode(label: 'Équipement TV/Wifi', value: 34),
        ],
      ),
    ],
  ),
];
