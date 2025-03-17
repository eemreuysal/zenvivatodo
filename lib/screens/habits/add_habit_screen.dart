import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../constants/habit_constants.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';

class AddHabitScreen extends StatefulWidget {
  final int userId;
  final Habit? habit; // Düzenleme durumu için

  // Constructor en üstte olmalı
  const AddHabitScreen({
    super.key,
    required this.userId,
    this.habit,
  });

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetDaysController = TextEditingController();

  final HabitService _habitService = HabitService();

  // String yerine HabitFrequency kullanıyoruz
  HabitFrequency _frequency = HabitFrequency.daily;
  List<int> _selectedWeekDays = [];
  DateTime _startDate = DateTime.now();
  TimeOfDay? _reminderTime;
  int _colorCode = HabitConstants.colors.first.toARGB32();
  bool _showInDashboard = false;

  bool _isEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupForm();
  }

  void _setupForm() {
    // Düzenleme modu kontrolü
    if (widget.habit != null) {
      _isEdit = true;
      final habit = widget.habit!;

      _titleController.text = habit.title;
      _descriptionController.text = habit.description;
      _frequency = habit.frequency;
      _colorCode = habit.colorCode;
      _targetDaysController.text = habit.targetDays.toString();
      _showInDashboard = habit.showInDashboard;

      // Başlangıç tarihi
      try {
        _startDate = DateTime.parse(habit.startDate);
      } on FormatException catch (e) {
        debugPrint('Tarih ayrıştırma hatası: $e');
        // Tarih düzgün ayrıştırılamadıysa, bugünü kullan
        _startDate = DateTime.now();
      } catch (e) {
        debugPrint('Beklenmeyen hata: $e');
        _startDate = DateTime.now();
      }

      // Haftalık seçilen günler
      if (habit.frequency == HabitFrequency.weekly &&
          habit.frequencyDays != null &&
          habit.frequencyDays!.isNotEmpty) {
        _selectedWeekDays = habit.frequencyDays!
            .split(',')
            .map((day) => int.parse(day))
            .toList();
      }

      // Hatırlatıcı saat
      if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) {
        final parts = habit.reminderTime!.split(':');
        if (parts.length == 2) {
          _reminderTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } else {
      // Yeni alışkanlık ekleme varsayılan değerleri
      _targetDaysController.text = '21'; // Varsayılan 21 gün
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetDaysController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Başlangıç Tarihi Seçin',
      cancelText: AppTexts.cancel,
      confirmText: AppTexts.save, // "ok" yerine "save" kullandık
      locale: const Locale('tr', 'TR'),
    );

    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      helpText: 'Hatırlatıcı Saati Seçin',
      cancelText: AppTexts.cancel,
      confirmText: AppTexts.save, // "ok" yerine "save" kullandık
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }

  void _showFrequencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tekrarlama Sıklığı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Günlük
                  RadioListTile<HabitFrequency>(
                    title: const Text('Her Gün'),
                    value: HabitFrequency.daily,
                    groupValue: _frequency,
                    onChanged: (value) {
                      setModalState(() {
                        _frequency = value!;
                      });
                      setState(() {
                        _frequency = value!;
                      });
                    },
                  ),

                  // Haftalık
                  RadioListTile<HabitFrequency>(
                    title: const Text('Haftanın Belirli Günleri'),
                    value: HabitFrequency.weekly,
                    groupValue: _frequency,
                    onChanged: (value) {
                      setModalState(() {
                        _frequency = value!;
                      });
                      setState(() {
                        _frequency = value!;
                      });
                    },
                  ),

                  // Haftalık gün seçimi
                  if (_frequency == HabitFrequency.weekly)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Wrap(
                        spacing: 8,
                        children: HabitConstants.weekdays.entries.map((entry) {
                          final weekday = entry.key;
                          final dayName = entry.value[0]; // İlk harf
                          final isSelected =
                              _selectedWeekDays.contains(weekday);

                          return FilterChip(
                            label: Text(dayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedWeekDays.add(weekday);
                                } else {
                                  _selectedWeekDays.remove(weekday);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  // Aylık
                  RadioListTile<HabitFrequency>(
                    title: const Text('Ayda Bir (Aynı Gün)'),
                    value: HabitFrequency.monthly,
                    groupValue: _frequency,
                    onChanged: (value) {
                      setModalState(() {
                        _frequency = value!;
                      });
                      setState(() {
                        _frequency = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tamam butonu
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tamam'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Renk Seçin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: HabitConstants.colors.map((color) {
                  final isSelected = _colorCode ==
                      color.toARGB32(); // value yerine toARGB32() kullanıyoruz

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _colorCode = color
                            .toARGB32(); // value yerine toARGB32() kullanıyoruz
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                  77), // withOpacity yerine withAlpha
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Frekans ayarlarını kontrol et
      if (_frequency == HabitFrequency.weekly && _selectedWeekDays.isEmpty) {
        _showErrorMessage('Lütfen en az bir gün seçin');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Alışkanlık nesnesi oluştur
      final habit = Habit(
        id: _isEdit ? widget.habit!.id : null,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        frequencyDays: _frequency == HabitFrequency.weekly
            ? _selectedWeekDays.join(',')
            : null,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        targetDays: int.parse(_targetDaysController.text),
        colorCode: _colorCode,
        reminderTime: _reminderTime != null
            ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
            : null,
        currentStreak: _isEdit ? widget.habit!.currentStreak : 0,
        longestStreak: _isEdit ? widget.habit!.longestStreak : 0,
        showInDashboard: _showInDashboard,
        userId: widget.userId,
      );

      bool success;
      if (_isEdit) {
        success = await _habitService.updateHabit(habit);
      } else {
        success = await _habitService.createHabit(habit);
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true); // Güncelleme sinyali için true döndür
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Alışkanlık kaydedilirken bir hata oluştu');
      }
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Biçim hatası: $e');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Bir hata oluştu: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getFrequencyText() {
    switch (_frequency) {
      case HabitFrequency.daily:
        return 'Her Gün';
      case HabitFrequency.weekly:
        if (_selectedWeekDays.isEmpty) {
          return 'Haftanın Belirli Günleri';
        } else {
          final days = _selectedWeekDays
              .map((day) => HabitConstants.weekdays[day])
              .join(', ');
          return 'Haftada $days';
        }
      case HabitFrequency.monthly:
        return 'Ayda Bir (Ayın ${_startDate.day}. günü)';
      case HabitFrequency.custom:
        return 'Özel Tekrarlama';
      default:
        return 'Tekrarlama Sıklığı';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Alışkanlık Düzenle' : 'Yeni Alışkanlık'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Renk ve Başlık
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _showColorPicker,
                          child: Container(
                            width: 56,
                            height: 56,
                            margin: const EdgeInsets.only(right: 16, top: 8),
                            decoration: BoxDecoration(
                              color: Color(_colorCode),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.repeat,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Alışkanlık Adı',
                              hintText:
                                  'Örn: Günlük yürüyüş, Su içmek, Kitap okumak',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen bir isim girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Açıklama
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (İsteğe Bağlı)',
                        hintText: 'Bu alışkanlığın detayları',
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Tekrarlama Sıklığı
                    Card(
                      child: InkWell(
                        onTap: _showFrequencyPicker,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.repeat),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tekrarlama Sıklığı',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getFrequencyText(),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_right),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Başlangıç Tarihi
                    Card(
                      child: InkWell(
                        onTap: _selectStartDate,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Başlangıç Tarihi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('d MMMM yyyy', 'tr_TR')
                                        .format(_startDate),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_right),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hatırlatıcı Saati
                    Card(
                      child: InkWell(
                        onTap: _selectReminderTime,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hatırlatıcı Saati (İsteğe Bağlı)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _reminderTime != null
                                        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Hatırlatıcı yok',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_right),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ana menüde göster seçeneği
                    SwitchListTile(
                      title: const Text(
                        'Ana menüde göster',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Etkinleştirildiğinde, bu alışkanlık görev panosunda gösterilir',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _showInDashboard,
                      onChanged: (value) {
                        setState(() {
                          _showInDashboard = value;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    const SizedBox(height: 16),

                    // Hedef
                    Text(
                      'Hedef',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _targetDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Hedef Gün Sayısı',
                        hintText: 'Örn: 21, 30, 90',
                        suffixText: 'gün',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir hedef gün sayısı girin';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Yeni bir alışkanlık oluşturmak genellikle 21 ile 66 gün arasında sürer.',
                      style: theme.textTheme.bodySmall,
                    ),

                    const SizedBox(height: 32),

                    // Kaydet butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveHabit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_isEdit ? 'GÜNCELLE' : 'OLUŞTUR'),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
