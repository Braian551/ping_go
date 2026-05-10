import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:ping_go/src/features/conductor/services/conductor_service.dart';
import 'package:ping_go/src/features/conductor/services/vehicle_api_service.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';

class ConductorRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic>? userSession;

  const ConductorRegistrationScreen({
    super.key,
    this.userSession,
  });

  @override
  State<ConductorRegistrationScreen> createState() => _ConductorRegistrationScreenState();
}

class _ConductorRegistrationScreenState extends State<ConductorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controladores
  final _licenciaController = TextEditingController();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController(); 
  final _colorController = TextEditingController();
  final _aseguradoraController = TextEditingController(); // Nuevo: Aseguradora
  final _polizaController = TextEditingController(); // Nuevo: Póliza
  
  // Variables de estado
  String _tipoVehiculo = 'motocicleta';
  DateTime? _vencimientoLicencia;
  DateTime? _vencimientoSeguro; // Nuevo: Vencimiento seguro
  
  // Imágenes
  File? _licenciaFrente;
  File? _licenciaReverso;
  final _picker = ImagePicker();
  
  // Tipos de vehículo disponibles
  final List<String> _tiposVehiculo = ['motocicleta', 'carro'];
  
  // API Data
  List<String> _brands = [];
  List<String> _models = [];
  bool _loadingBrands = false;
  bool _loadingModels = false;
  
  // Colores mejorados con soporte para gradientes
  final List<Map<String, dynamic>> _vehiculoColors = [
    {'name': 'Blanco', 'color': Colors.white},
    {'name': 'Negro', 'color': Colors.black},
    {'name': 'Gris', 'color': Colors.grey},
    {'name': 'Plata', 'color': const Color(0xFFC0C0C0)},
    {'name': 'Azul', 'color': Colors.blue},
    {'name': 'Rojo', 'color': Colors.red},
    {'name': 'Beige', 'color': const Color(0xFFF5F5DC)},
    {'name': 'Amarillo', 'color': Colors.yellow},
    {'name': 'Verde', 'color': Colors.green},
    {'name': 'Café', 'color': Colors.brown},
    {'name': 'Naranja', 'color': Colors.orange},
    {'name': 'Vino', 'color': const Color(0xFF800000)},
    {
      'name': 'Multicolor', 
      'color': Colors.transparent, 
      'gradient': const LinearGradient(
        colors: [Colors.red, Colors.blue, Colors.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    },
  ];

  @override
  void dispose() {
    _licenciaController.dispose();
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _colorController.dispose();
    _aseguradoraController.dispose();
    _polizaController.dispose();
    _cleanupTemporaryFiles();
    super.dispose();
  }

  Future<void> _cleanupTemporaryFiles() async {
    try {
      if (_licenciaFrente != null && await _licenciaFrente!.exists()) {
        await _licenciaFrente!.delete();
      }
      if (_licenciaReverso != null && await _licenciaReverso!.exists()) {
        await _licenciaReverso!.delete();
      }
    } catch (e) {
      print('Error limpiando archivos temporales: $e');
    }
  }

  Future<void> _pickImage({required bool isFrente}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFFFF00)),
                title: const Text('Galería', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(isFrente: isFrente, source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFFFF00)),
                title: const Text('Cámara', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(isFrente: isFrente, source: ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage({required bool isFrente, required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, 
      );
      
      if (pickedFile != null) {
        // Copiar el archivo a un directorio permanente para evitar que desaparezca
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${isFrente ? "frente" : "reverso"}_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}';
        final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');

        setState(() {
          if (isFrente) {
            _licenciaFrente = savedImage;
          } else {
            _licenciaReverso = savedImage;
          }
        });
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, message: 'Error seleccionando imagen');
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isLicencia}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFFF00),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1A1A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isLicencia) {
          _vencimientoLicencia = picked;
        } else {
          _vencimientoSeguro = picked;
        }
      });
    }
  }

  Future<List<String>> _getBrands() async {
    if (_brands.isNotEmpty) return _brands;
    return await VehicleApiService.getMakes(_tipoVehiculo);
  }

  Future<List<String>> _getModels(String make) async {
    // If we cached models for this make, return them? 
    // Current implementation clears models when make changes. 
    // So if _models is not empty, it belongs to current make.
    if (_models.isNotEmpty) return _models;
    return await VehicleApiService.getModels(make);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.showError(context, message: 'Por favor, corrige los errores en el formulario');
      return;
    }
    if (_vencimientoLicencia == null) {
      CustomSnackbar.showError(context, message: 'Selecciona fecha de vencimiento');
      return;
    }
    
    if (_licenciaFrente == null || _licenciaReverso == null) {
      CustomSnackbar.showError(context, message: 'Debes subir ambas fotos de tu licencia');
      return;
    }

    if (_colorController.text.isEmpty) {
      CustomSnackbar.showError(context, message: 'Selecciona el color de tu vehículo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener ID de usuario si no vino en props
      int? userId;
      if (widget.userSession != null && widget.userSession!['id'] != null) {
        userId = int.tryParse(widget.userSession!['id'].toString());
      } else {
        final session = await UserService.getSavedSession();
        if (session != null) {
          userId = int.tryParse(session['id'].toString());
        }
      }

      if (userId == null) {
        throw Exception('No se pudo identificar al usuario');
      }

      final result = await ConductorService.submitVerification(
        usuarioId: userId,
        numeroLicencia: _licenciaController.text,
        vencimientoLicencia: _vencimientoLicencia!.toIso8601String().split('T')[0],
        tipoVehiculo: _tipoVehiculo,
        placaVehiculo: _placaController.text,
        marcaVehiculo: _marcaController.text.isNotEmpty ? _marcaController.text : null,
        modeloVehiculo: _modeloController.text.isNotEmpty ? _modeloController.text : null,
        anoVehiculo: _anoController.text.isNotEmpty ? _anoController.text : null,
        colorVehiculo: _colorController.text,
        aseguradora: _aseguradoraController.text.isNotEmpty ? _aseguradoraController.text : null,
        numeroPolizaSeguro: _polizaController.text.isNotEmpty ? _polizaController.text : null,
        vencimientoSeguro: _vencimientoSeguro != null ? _vencimientoSeguro!.toIso8601String().split('T')[0] : null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // 2. Subir imágenes si el registro fue exitoso
        bool imagesUploaded = true;
        String uploadErrorMessage = '';
        try {
          // Verificar que los archivos aún existen físicamente
          if (!await _licenciaFrente!.exists()) {
            throw Exception('El archivo de la licencia (frente) no se encuentra en el dispositivo. Por favor, selecciona la foto de nuevo.');
          }
          if (!await _licenciaReverso!.exists()) {
            throw Exception('El archivo de la licencia (reverso) no se encuentra en el dispositivo. Por favor, selecciona la foto de nuevo.');
          }

          final frenteResult = await ConductorService.uploadDocument(
            conductorId: userId, 
            filePath: _licenciaFrente!.path, 
            type: 'licencia_frente'
          );
          
          final reversoResult = await ConductorService.uploadDocument(
            conductorId: userId, 
            filePath: _licenciaReverso!.path, 
            type: 'licencia_reverso'
          );
          
          if (frenteResult['success'] != true || reversoResult['success'] != true) {
            imagesUploaded = false;
            uploadErrorMessage = frenteResult['success'] != true 
                ? frenteResult['message'] 
                : reversoResult['message'];
          }
        } catch (e) {
          imagesUploaded = false;
          uploadErrorMessage = e.toString();
          print('Error subiendo imágenes: $e');
        }

        if (imagesUploaded) {
          _cleanupTemporaryFiles();
        }

        if (!mounted) return;

        if (imagesUploaded) {
          CustomSnackbar.showSuccess(
            context, 
            message: 'Solicitud y documentos enviados correctamente',
          );
          Navigator.pop(context, true);
        } else {
          CustomSnackbar.showWarning( 
            context, 
            message: 'Solicitud creada pero hubo error al subir documentos: $uploadErrorMessage',
          );
          Navigator.pop(context, true);
        }
      } else {
        CustomSnackbar.showError(
          context, 
          message: result['message'] ?? 'Error al enviar solicitud',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, message: 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Información de Licencia'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _licenciaController,
                      label: 'Número de Licencia',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v.length < 5) return 'Mínimo 5 caracteres';
                        return null;
                      },
                      maxLength: 15,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePicker(
                            label: 'Frente',
                            file: _licenciaFrente,
                            onTap: () => _pickImage(isFrente: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImagePicker(
                            label: 'Reverso',
                            file: _licenciaReverso,
                            onTap: () => _pickImage(isFrente: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Información del Vehículo'),
                    const SizedBox(height: 16),
                    _buildDropdownType(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _placaController,
                      label: 'Placa del Vehículo',
                      icon: Icons.directions_car_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v.length != 6) return 'Debe tener 6 caracteres';
                        return null;
                      },
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      ],
                      hintText: 'Ej: ABC123',
                    ),
                    const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildInfoPicker(
                            label: 'Marca',
                            controller: _marcaController,
                            icon: Icons.branding_watermark_outlined,
                            onTap: () {
                              _showSelectionModal(
                                title: 'Selecciona Marca',
                                futureItems: _getBrands(),
                                onSelected: (val) {
                                  setState(() {
                                    _marcaController.text = val;
                                    _modeloController.clear(); 
                                    _models = []; 
                                  });
                                  // Pre-fetch models? No, wait for user.
                                },
                              );
                            },
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInfoPicker(
                            label: 'Modelo',
                            controller: _modeloController,
                            icon: Icons.model_training,
                            onTap: () {
                              if (_marcaController.text.isEmpty) {
                                CustomSnackbar.showError(context, message: 'Selecciona primero una marca');
                                return;
                              }
                              _showSelectionModal(
                                title: 'Selecciona Modelo',
                                futureItems: _getModels(_marcaController.text),
                                onSelected: (val) {
                                  setState(() {
                                    _modeloController.text = val;
                                    // Cache the models list if we just fetched it?
                                    // The FutureBuilder fetched it, but we didn't save it to _models.
                                    // We should update _models inside the modal or just rely on re-fetching (cached by service? No service doesn't cache).
                                    // Better to update _models when data arrives.
                                    // Or simply let _getModels handle caching if we desire.
                                    // For now, let's keep it simple.
                                  });
                                },
                              );
                            },
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _anoController,
                        label: 'Año',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (v.length != 4) return 'Inválido';
                          final year = int.tryParse(v);
                          final currentYear = DateTime.now().year;
                          if (year == null || year < 1990 || year > currentYear + 1) {
                            return 'Año inválido (1990-${currentYear + 1})';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    _buildColorSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Información del Seguro'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _aseguradoraController,
                      label: 'Aseguradora (Opcional)',
                      icon: Icons.shield_outlined,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 30,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _polizaController,
                      label: 'Número de Póliza (Opcional)',
                      icon: Icons.receipt_long_outlined,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 20,
                    ),
                    const SizedBox(height: 16),
                    _buildInsuranceDatePicker(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFF00).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFFF00), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFFF00).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.person_pin_circle_rounded, color: Color(0xFFFFFF00), size: 40),
        ),
        const SizedBox(height: 20),
        const Text(
          'Conviértete en Conductor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Completa el formulario para empezar a ganar dinero con PingGo',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFFFF00),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              textCapitalization: textCapitalization,
              keyboardType: keyboardType,
              validator: validator,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(icon, color: const Color(0xFFFFFF00).withOpacity(0.7)),
                border: InputBorder.none,
                counterText: '', // Hide counter
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildInfoPicker({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFFFF00).withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? label : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFFFFFF00)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorderContainer(
        label: label,
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  file,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: Color(0xFFFFFF00), size: 30),
                  const SizedBox(height: 8),
                  Text(
                    'Subir Foto',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
  
  // MISSING DATE PICKER WIDGET restored
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context, isLicencia: true),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _vencimientoLicencia == null 
                    ? Colors.white.withOpacity(0.1) 
                    : const Color(0xFFFFFF00).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFFFFFF00).withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _vencimientoLicencia == null
                        ? 'Vencimiento de Licencia'
                        : '${_vencimientoLicencia!.day}/${_vencimientoLicencia!.month}/${_vencimientoLicencia!.year}',
                    style: TextStyle(
                      color: _vencimientoLicencia == null 
                          ? Colors.white.withOpacity(0.6) 
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MISSING INSURANCE DATE PICKER WIDGET restored
  Widget _buildInsuranceDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context, isLicencia: false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: const Color(0xFFFFFF00).withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _vencimientoSeguro == null
                        ? 'Vencimiento Seguro (Opcional)'
                        : '${_vencimientoSeguro!.day}/${_vencimientoSeguro!.month}/${_vencimientoSeguro!.year}',
                    style: TextStyle(
                      color: _vencimientoSeguro == null 
                          ? Colors.white.withOpacity(0.6) 
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownType() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipoVehiculo,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFFF00)),
              isExpanded: true,
              items: _tiposVehiculo.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        _getVehicleIcon(value),
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(value[0].toUpperCase() + value.substring(1)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != _tipoVehiculo) {
                  setState(() {
                    _tipoVehiculo = newValue!;
                    _brands = [];
                    _models = [];
                    _marcaController.clear();
                    _modeloController.clear();
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final selectedColorData = _getColorDataFromName(_colorController.text);
    
    return GestureDetector(
      onTap: _showColorPicker,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: const Color(0xFFFFFF00).withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _colorController.text.isEmpty ? 'Color' : _colorController.text,
                    style: TextStyle(
                      color: _colorController.text.isEmpty 
                          ? Colors.white.withOpacity(0.6) 
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_colorController.text.isNotEmpty)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedColorData['color'],
                      gradient: selectedColorData['gradient'],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFFFFFF00)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showSelectionModal({
    required String title,
    required Future<List<String>> futureItems,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: futureItems,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFFF00)));
                      }
                      if (snapshot.hasError) {
                         return Center(
                           child: Text(
                             'Error al cargar datos', 
                             style: TextStyle(color: Colors.white.withOpacity(0.7))
                           )
                         );
                      }
                      
                      final items = snapshot.data ?? [];
                      
                      // Update local cache if needed, but setState here is dangerous during build.
                      // We can assume items are what we want.
                      
                      if (items.isEmpty) {
                        return const Center(child: Text('No hay resultados', style: TextStyle(color: Colors.white54)));
                      }

                      return SearchableList(
                        items: items,
                        onSelected: (val) {
                          onSelected(val);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _getColorDataFromName(String name) {
    return _vehiculoColors.firstWhere(
      (c) => c['name'] == name,
      orElse: () => {'color': Colors.transparent},
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Seleccionar Color',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: _vehiculoColors.length,
                        itemBuilder: (context, index) {
                          final colorItem = _vehiculoColors[index];
                          final isSelected = _colorController.text == colorItem['name'];
                          
                          return ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: colorItem['color'],
                                gradient: colorItem['gradient'],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10),
                              ),
                            ),
                            title: Text(
                              colorItem['name'],
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFFFFF00) : Colors.white
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: Color(0xFFFFFF00))
                                : null,
                            onTap: () {
                              setState(() {
                                _colorController.text = colorItem['name'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFF00),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
              )
            : const Text(
                'Enviar Solicitud',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'carro':
        return Icons.directions_car;
      case 'motocicleta':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }
}

// Helper Widget for Searchable List
class SearchableList extends StatefulWidget {
  final List<String> items;
  final Function(String) onSelected;
  
  const SearchableList({super.key, required this.items, required this.onSelected});

  @override
  State<SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  late List<String> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) => item.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // We moved search bar to parent for styling, but here we need it to filter locally?
        // Actually, parent layout has a search bar but it wasn't hooked up correctly to this widget's state.
        // Let's just put the list here and let the parent handle the search bar? 
        // Or put the search bar INSIDE this widget.
        // I will put the search bar inside this widget to encompass all logic.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return ListTile(
                title: Text(item, style: const TextStyle(color: Colors.white)),
                onTap: () => widget.onSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Helper classes
class DottedBorderContainer extends StatelessWidget {
  final String label;
  final Widget child;

  const DottedBorderContainer({Key? key, required this.label, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), style: BorderStyle.none),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: DottedBorderPainter(color: Colors.white.withOpacity(0.3)),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;

  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    ));

    final dashPath = _dashPath(path, dashArray: CircularIntervalList<double>([6, 4]));
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path path, {required CircularIntervalList<double> dashArray}) {
    final Path dest = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircularIntervalList<T> {
  final List<T> _values;
  int _index = 0;

  CircularIntervalList(this._values);

  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}
