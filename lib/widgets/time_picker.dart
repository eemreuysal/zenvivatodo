import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay?) onTimeChanged;
  final bool isOptional;

  const TimePickerWidget({
    Key? key,
    this.selectedTime,
    required this.onTimeChanged,
    this.isOptional = true,
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  void _clearTime() {
    onTimeChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                Colors.grey.withAlpha(76), // Changed from withOpacity(0.3)
          ),
          borderRadius: BorderRadius.circular(8),
          color: theme.inputDecorationTheme.fillColor,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 12),
            Text(
              selectedTime != null
                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                  : isOptional
                  ? 'Saat seçin (Opsiyonel)'
                  : 'Saat seçin',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    selectedTime == null
                        ? theme.textTheme.bodySmall?.color
                        : theme.textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            if (selectedTime != null && isOptional)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: _clearTime,
                splashRadius: 20,
              )
            else
              const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }
}
