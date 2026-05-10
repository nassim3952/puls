
import 'dart:math';

import 'package:xtal_dataview/xtal_dataview.dart';

import '../../features/dashboard/presentation/model/domain/verbatim_node.dart';
import '../color.dart';
import '../models/chart_model.dart';

final splineData1 = [
  SplineGroup(
    name: "Oui totalement",
    color: AppColors.primaryMenthe,
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
    color: AppColors.primaryMentheVariantDeepMenthe,
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
    color: AppColors.primaryMentheVariantLightMenthe,
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
    color: AppColors.primaryMentheVariantMenthe,
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
  ChartDataPie('Oui totalement', 45, AppColors.primaryMenthe),
  ChartDataPie('En partie', 35, AppColors.primaryMentheVariantDeepMenthe),
  ChartDataPie('Non', 30, AppColors.primaryMentheVariantLightMenthe),
  ChartDataPie('En attente', 38, AppColors.primaryMentheVariantMenthe),
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


final ChartTreeNode sunBurstData = ChartTreeNode(
  name: 'Expérience Patient',
  children: [
    // --- RELATIONNEL ---
    ChartTreeNode(
      name: 'Relationnel',
      children: [
        ChartTreeNode(
          name: 'Communication',
          children: [
            ChartTreeNode(name: 'Écoute', value: 52),
            ChartTreeNode(name: 'Empathie', value: 41),
            ChartTreeNode(name: 'Explication', value: 63),
            ChartTreeNode(name: 'Indifférence', value: 14),
            ChartTreeNode(name: 'Sourire', value: 39),
            ChartTreeNode(name: 'Gentillesse', value: 58),
            ChartTreeNode(name: 'Politesse', value: 47),
          ],
        ),
        ChartTreeNode(
          name: 'Accueil',
          children: [
            ChartTreeNode(name: 'Accueil physique', value: 44),
            ChartTreeNode(name: 'Orientation', value: 31),
            ChartTreeNode(name: 'Interaction humaine', value: 25),
            ChartTreeNode(name: 'Disponibilité', value: 36),
            ChartTreeNode(name: 'Standard téléphonique', value: 22),
          ],
        ),
      ],
    ),

    // --- SOIN & TECHNIQUE ---
    ChartTreeNode(
      name: 'Soin & Technique',
      children: [
        ChartTreeNode(
          name: 'Qualité Médicale',
          children: [
            ChartTreeNode(name: 'Médecin', value: 85),
            ChartTreeNode(name: 'Geste soignant', value: 74),
            ChartTreeNode(name: 'Compétence', value: 92),
            ChartTreeNode(name: 'Confiance', value: 81),
            ChartTreeNode(name: 'Douceur', value: 56),
            ChartTreeNode(name: 'Professionnalisme', value: 69),
          ],
        ),
        ChartTreeNode(
          name: 'Confort Physique',
          children: [
            ChartTreeNode(name: 'Douleur', value: 42),
            ChartTreeNode(name: 'Soulagement', value: 38),
            ChartTreeNode(name: 'Réconfort', value: 29),
            ChartTreeNode(name: 'Stress', value: 54),
            ChartTreeNode(name: 'Sommeil', value: 41),
            ChartTreeNode(name: 'Aide aux gestes', value: 27),
          ],
        ),
      ],
    ),

    // --- ORGANISATION ---
    ChartTreeNode(
      name: 'Organisation',
      children: [
        ChartTreeNode(
          name: 'Gestion du Temps',
          children: [
            ChartTreeNode(name: 'Attente', value: 124),
            ChartTreeNode(name: 'Longue attente', value: 89),
            ChartTreeNode(name: 'Flexibilité', value: 15),
            ChartTreeNode(name: 'Ponctualité', value: 21),
            ChartTreeNode(name: 'Rapidité', value: 43),
          ],
        ),
        ChartTreeNode(
          name: 'Logistique',
          children: [
            ChartTreeNode(name: 'Coordination', value: 37),
            ChartTreeNode(name: 'Disponibilité du matériel', value: 24),
            ChartTreeNode(name: 'Facturation', value: 19),
            ChartTreeNode(name: 'Sortie de l\'hôpital', value: 45),
            ChartTreeNode(name: 'Dossier médical', value: 32),
          ],
        ),
      ],
    ),

    // --- ENVIRONNEMENT ---
    ChartTreeNode(
      name: 'Environnement',
      children: [
        ChartTreeNode(
          name: 'Hygiène',
          children: [
            ChartTreeNode(name: 'Propreté', value: 98),
            ChartTreeNode(name: 'Manque d\'hygiène', value: 12),
            ChartTreeNode(name: 'Odeurs', value: 18),
            ChartTreeNode(name: 'Entretien', value: 54),
          ],
        ),
        ChartTreeNode(
          name: 'Infrastructure',
          children: [
            ChartTreeNode(name: 'Structure', value: 42,),
            ChartTreeNode(name: 'Chambre', value: 67),
            ChartTreeNode(name: 'Repas / Nourriture', value: 88),
            ChartTreeNode(name: 'Bruit', value: 73),
            ChartTreeNode(name: 'Signalisation', value: 26),
            ChartTreeNode(name: 'Température', value: 19),
            ChartTreeNode(name: 'Équipement TV/Wifi', value: 34),
          ],
        ),
      ],
    ),
  ],
);
