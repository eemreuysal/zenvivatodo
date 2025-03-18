import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TimePickerWidget extends StatelessWidget {
  // Constructor moved to top
  const TimePickerWidget({
    super.key,
    this.selectedTime,
    required this.onTimeChanged,
    this.isOptional = true,
  });

  final TimeOfDay? selectedTime;
  final Function(TimeOfDay?) onTimeChanged;
  final bool isOptional;

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
          child: child!, // Remove null check when fixed
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
            color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                Color.fromRGBO(
                  Colors.grey.red.toInt(), 
                  Colors.grey.green.toInt(), 
                  Colors.grey.blue.toInt(), 
                  0.3,
                ),
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
                color: selectedTime == null
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