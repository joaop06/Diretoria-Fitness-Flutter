import 'package:flutter/material.dart';
import 'package:daily_training_flutter/utils/Date.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';

class DateRangePicker extends StatefulWidget {
  DateTime? finalDate;
  DateTime? initialDate;
  final TextEditingController finalDateController;
  final TextEditingController initialDateController;

  DateRangePicker({
    Key? key,
    this.finalDate,
    this.initialDate,
    required this.finalDateController,
    required this.initialDateController,
  }) : super(key: key);

  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker>
    with SingleTickerProviderStateMixin {
  DateTimeRange? _selectedDateRange;
  String? placeholderField;

  // Controlador de animação
  late Animation<double> _opacityAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null && widget.finalDate != null) {
      placeholderField =
          '${Date(date: widget.initialDate).format()} - ${Date(date: widget.finalDate).format()}';
    } else {
      placeholderField = 'Selecione um intervalo';
    }

    // Configuração da animação
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectInterval() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      saveText: 'Salvar',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      lastDate: Date.year(2100),
      firstDate: Date.year(2000),
      helpText: 'Selecione o período',

      initialDateRange: widget.initialDate == null || widget.finalDate == null
          ? null
          : Date.range(
              end: widget.finalDate,
              start: widget.initialDate,
            ),

      locale: const Locale('pt', 'BR'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,

      // Personalização do tema
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AllColors.gold,
              onSurface: AllColors.gold,
              onPrimary: AllColors.white,
              onSecondary: AllColors.white,
              secondary: AllColors.softGold,
            ),
            dialogBackgroundColor: AllColors.background,
            textTheme: const TextTheme(
              // Cor dos dias no calendário
              bodyLarge: TextStyle(color: AllColors.white),
              bodySmall: TextStyle(color: AllColors.white),
              bodyMedium: TextStyle(color: AllColors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
        _formatSelectedDate();
      });
      widget.finalDateController.text = Date(date: pickedRange.end).format();
      widget.initialDateController.text =
          Date(date: pickedRange.start).format();

      // Inicia a animação
      _animationController.forward(from: 0.0);
    }
  }

  void _formatSelectedDate() {
    if (_selectedDateRange == null) {
      setState(() {
        placeholderField = 'Selecione um período';
      });
    }

    final endDate = Date(date: _selectedDateRange!.end).format();
    final startDate = Date(date: _selectedDateRange!.start).format();
    setState(() {
      placeholderField = '$startDate - $endDate';
      print(placeholderField);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectInterval,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AllColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AllColors.gold, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                placeholderField!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AllColors.white,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month,
              color: AllColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}
