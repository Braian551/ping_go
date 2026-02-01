import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_go/src/core/config/app_config.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  File? _selectedImage;
  bool _imageDeleted = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['nombre'] ?? '');
    _lastNameController = TextEditingController(text: widget.user['apellido'] ?? '');
    _phoneController = TextEditingController(text: widget.user['telefono'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageDeleted = false; // Reset deleted flag if new image picked
        });
      }
    } catch (e) {
      CustomSnackbar.showError(context, message: 'Error al seleccionar imagen');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageDeleted = true;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty || 
        _lastNameController.text.trim().isEmpty || 
        _phoneController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, message: 'Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final int userId = int.parse(widget.user['id'].toString());
      
      final result = await UserService.updateProfileInfo(
        userId: userId,
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        imagePath: _selectedImage?.path,
        deleteImage: _imageDeleted,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success'] == true) {
          CustomSnackbar.showSuccess(context, message: 'Perfil actualizado con éxito');
          Navigator.pop(context, true); // Return true to refresh parent
        } else {
          CustomSnackbar.showError(context, message: result['message'] ?? 'Error al actualizar');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, message: 'Error inesperado: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFF00).withOpacity(0.05),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileImage(),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Editar Perfil',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileImage() {
    final String? currentUrl = widget.user['url_imagen_perfil'];
    // Construct full URL if it's a relative path and not starting with http
    String? fullUrl;
    if (currentUrl != null && currentUrl.isNotEmpty) {
      if (currentUrl.startsWith('http')) {
        fullUrl = currentUrl;
      } else {
        // Remove duplicate slashes if any
        final cleanPath = currentUrl.startsWith('uploads/') ? currentUrl : 'uploads/$currentUrl';
        // Assuming AppConfig.apiBaseUrl points to backend-deploy/ .. we need root
        // If apiBaseUrl is http://.../backend-deploy, and images are in http://.../uploads
        // We might need to adjust based on how AppConfig is set.
        // Assuming standard structure:
        // backend: domain.com/backend-deploy/
        // images: domain.com/uploads/
        // We'll use a pragmatic approach or assume check logic.
        // For now, let's try to construct it from base domain if possible, or relative to backend.
        
        // Quick fix: assume backend url is like .../backend-deploy
        // We need to go up one level.
        final baseUrl = AppConfig.baseUrl; // http://10.0.2.2/ping_go/backend-deploy
        
        // If baseUrl ends with 'backend-deploy', we remove it to get the project root
        // uploads is sibling to backend-deploy
        String rootUrl = baseUrl;
        if (baseUrl.endsWith('/backend-deploy')) {
          rootUrl = baseUrl.substring(0, baseUrl.length - '/backend-deploy'.length);
        } else if (baseUrl.endsWith('backend-deploy/')) {
           rootUrl = baseUrl.substring(0, baseUrl.length - 'backend-deploy/'.length); 
        }

        // Now rootUrl should be http://10.0.2.2/ping_go
        fullUrl = '$rootUrl/$cleanPath';
      }
    }

    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (!_imageDeleted && fullUrl != null) {
      imageProvider = NetworkImage(fullUrl);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: const Color(0xFFFFFF00), width: 2),
              image: imageProvider != null 
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: imageProvider == null
                ? Center(
                    child: Text(
                      widget.user['nombre'] != null && widget.user['nombre'].isNotEmpty 
                          ? widget.user['nombre'][0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Color(0xFFFFFF00),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFF00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
              ),
            ),
          ),
          if (imageProvider != null)
             Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nombre',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _lastNameController,
          label: 'Apellido',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFF00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Guardar Cambios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
