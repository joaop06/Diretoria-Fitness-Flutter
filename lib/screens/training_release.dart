import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:daily_training_flutter/providers/training_release.provider.dart';

class LaunchTrainingScreen extends StatefulWidget {
  final int betDayId;
  final int participantId;

  const LaunchTrainingScreen({
    super.key,
    required this.betDayId,
    required this.participantId,
  });

  @override
  State<LaunchTrainingScreen> createState() => _LaunchTrainingScreenState();
}

class _LaunchTrainingScreenState extends State<LaunchTrainingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _commentController = TextEditingController();
  final _trainingTypeController = TextEditingController();

  final ValueNotifier<Uint8List?> _trainingImage =
      ValueNotifier<Uint8List?>(null);
  final ValueNotifier<bool> _isSubmitting = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // BackButtonInterceptor.add(backButtonInterceptor);
  }

  @override
  void dispose() {
    // BackButtonInterceptor.remove(backButtonInterceptor);
    _trainingTypeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushNamed(context, '/bet-details');
    return true;
  }

  setMessage(String message, [bool error = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        message,
        style: TextStyle(
          color: error ? AllColors.red : AllColors.white,
        ),
      )),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        Uint8List? imageBytes;

        if (kIsWeb) {
          // Web: Use pickedFile.readAsBytes() diretamente
          imageBytes = await pickedFile.readAsBytes();
        } else {
          // Plataformas móveis e desktop
          imageBytes = await File(pickedFile.path).readAsBytes();
        }

        _trainingImage.value = imageBytes;
      }
    } catch (e) {
      setMessage('Erro ao carregar imagem', true);
    }
  }

  Future<void> _submitTraining() async {
    try {
      if (_trainingImage.value == null) {
        throw Exception('Foto do treino não informada');
      }

      _isSubmitting.value = true;

      final trainingReleaseProvider =
          Provider.of<TrainingReleaseProvider>(context, listen: false);

      final result = await trainingReleaseProvider.create(
        image: _trainingImage.value!,
        trainingRelease: {
          'betDayId': widget.betDayId,
          'comment': _commentController.text,
          'participantId': widget.participantId,
          'trainingType': _trainingTypeController.text,
        },
      );
      setMessage(result);

      Navigator.pushNamed(context, '/bet-details');
    } catch (e) {
      if (e.toString().replaceFirst('Exception: ', '') ==
          'Token expirado. Faça o login novamente') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Token expirado. Faça o login novamente',
            style: TextStyle(color: AllColors.red),
          )),
        );
        Navigator.pushNamed(context, '/');
      }
      setMessage(e.toString().replaceAll('Exception: ', ''), true);
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentPage = 0.0;
    PageController pageController = PageController();

    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page ?? 0.0;
      });
    });

    final scale = (1 - (currentPage).abs()).clamp(1.0, 1.2);
    final scaleWidth = (MediaQuery.of(context).size.width) * scale;
    final scaleHeight = (MediaQuery.of(context).size.height) * scale;

    return Sidebar(
      title: 'Lançamento de Treino',
      leading: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/bet-details',
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: AllColors.transparent,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Icon(
          size: 22,
          Icons.arrow_back,
          color: AllColors.white,
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.of(context).size.width > 500)
                ? MediaQuery.of(context).size.width * 0.4
                : MediaQuery.of(context).size.width * 0.9,
          ),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ValueListenableBuilder<Uint8List?>(
                    valueListenable: _trainingImage,
                    builder: (context, value, child) {
                      return value != null
                          ? Container(
                              constraints: BoxConstraints(
                                maxWidth: scaleWidth / 2,
                                maxHeight: scaleHeight / 2,
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.memory(
                                      value,
                                      fit: BoxFit.contain,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _trainingImage.value = null;
                                      },
                                      style: ButtonStyle(
                                        elevation: WidgetStateProperty.all(0),
                                        padding: WidgetStateProperty.all(
                                          EdgeInsets.zero,
                                        ),
                                        minimumSize: WidgetStateProperty.all(
                                          const Size(40, 30),
                                        ),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                          AllColors.transparent,
                                        ),
                                      ),
                                      child: const Text(
                                        'Remover',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              constraints: BoxConstraints(
                                maxWidth: scaleWidth / 2,
                                maxHeight: scaleHeight / 2,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt,
                                    color: AllColors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AllColors.transparent,
                                    ),
                                    child: const Column(
                                      children: [
                                        Text(
                                          'Tirar Foto',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AllColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Treino',
                      labelStyle: const TextStyle(color: AllColors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AllColors.gold,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AllColors.gold,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(0, 179, 19, 19),
                    ),
                    dropdownColor: AllColors.card,
                    style: const TextStyle(
                      color: AllColors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Musculação',
                        child: Row(
                          children: [
                            Icon(Icons.fitness_center, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Musculação'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Corrida',
                        child: Row(
                          children: [
                            Icon(Icons.directions_run, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Corrida'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Vôlei',
                        child: Row(
                          children: [
                            Icon(Icons.sports_volleyball, color: Colors.orange),
                            SizedBox(width: 10),
                            Text('Vôlei'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Luta',
                        child: Row(
                          children: [
                            Icon(Icons.sports_kabaddi, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Luta'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Natação',
                        child: Row(
                          children: [
                            Icon(Icons.pool, color: Colors.teal),
                            SizedBox(width: 10),
                            Text('Natação'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Ciclismo',
                        child: Row(
                          children: [
                            Icon(Icons.directions_bike, color: Colors.purple),
                            SizedBox(width: 10),
                            Text('Ciclismo'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Outros',
                        child: Row(
                          children: [
                            Icon(Icons.more_horiz, color: Colors.grey),
                            SizedBox(width: 10),
                            Text('Outros'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      _trainingTypeController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o tipo de treino.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Comentário (opcional)',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AllColors.gold,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: AllColors.white,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isSubmitting,
                    builder: (context, isSubmitting, child) {
                      return isSubmitting
                          ? const CircularProgressIndicator(
                              color: AllColors.gold,
                            )
                          : ElevatedButton(
                              onPressed: _submitTraining,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AllColors.gold,
                              ),
                              child: const Text(
                                'Lançar Treino',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AllColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
