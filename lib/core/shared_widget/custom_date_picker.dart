import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../color.dart';
import '../provider/filter_controller.dart';

void showCustomDatePicker(
    BuildContext context,
    DashboardFilterNotifier notifier,
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text("Sélectionner une période"),
      content: SizedBox(
        height: 350,
        width: 300,
        child: SfDateRangePicker(
          headerStyle: const DateRangePickerHeaderStyle(
            backgroundColor: AppColors.surface,
          ),
          backgroundColor: AppColors.surface,
          selectionColor: AppColors.primaryBlue,
          endRangeSelectionColor: AppColors.primaryBlue,
          startRangeSelectionColor: AppColors.primaryBlue,
          rangeSelectionColor: AppColors.primaryBlue.withOpacity(0.2),
          todayHighlightColor: AppColors.primaryBlue,
          selectionMode: DateRangePickerSelectionMode.range,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is PickerDateRange) {
              final range = args.value as PickerDateRange;
              if (range.startDate != null && range.endDate != null) {
                notifier.updatePeriode(
                  DateTimeRange(
                    start: range.startDate!,
                    end: range.endDate!,
                  ),
                );
              }
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Valider",
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
      ],
    ),
  );
}