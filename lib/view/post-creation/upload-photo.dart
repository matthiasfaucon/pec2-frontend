import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firstflutterapp/utils/platform_utils.dart';
import 'package:firstflutterapp/view/post-creation/post-details.dart';
import 'package:camera/camera.dart';

class UploadPhotoView extends StatefulWidget {
  const UploadPhotoView({Key? key}) : super(key: key);

  @override
  _UploadPhotoViewState createState() => _UploadPhotoViewState();
}

class _UploadPhotoViewState extends State<UploadPhotoView> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  int _selectedCameraIndex = 0;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = 0; // Par défaut, caméra arrière
        await _setupCamera(_selectedCameraIndex);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'initialisation de la caméra: $e')),
      );
    }
  }

  Future<void> _setupCamera(int index) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    if (_cameras.isEmpty) return;

    _cameraController = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'initialisation de la caméra: $e')),
      );
    }
  }

  void _switchCamera() async {
    if (_cameras.length <= 1) return;
    
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera(_selectedCameraIndex);
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _cameraController == null || _isCapturing) return;
    
    try {
      setState(() {
        _isCapturing = true;
      });
      
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _image = File(photo.path);
        _isCapturing = false;
      });
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prise de photo: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  void _continueToNextStep() {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailsView(imageFile: _image!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez prendre ou sélectionner une image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _image != null 
          ? _buildImagePreview()
          : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Vue de la caméra en plein écran
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController!),
        ),
        
        // Boutons d'interface caméra
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            color: Colors.black.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton Galerie
                FloatingActionButton(
                  heroTag: "galleryBtn",
                  onPressed: _pickImage,
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.photo_library, color: Colors.black),
                ),
                
                // Bouton pour prendre une photo
                FloatingActionButton(
                  heroTag: "cameraBtn",
                  onPressed: _isCapturing ? null : _takePhoto,
                  backgroundColor: Colors.white,
                  child: _isCapturing 
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.camera_alt, color: Colors.black),
                ),
                
                // Bouton pour retourner la caméra
                FloatingActionButton(
                  heroTag: "switchBtn",
                  onPressed: _cameras.length <= 1 ? null : _switchCamera,
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.flip_camera_ios, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        
        // Bouton pour fermer
        Positioned(
          top: 40,
          left: 20,
          child: FloatingActionButton(
            heroTag: "closeBtn",
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // Provide feedback if we can't pop
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot go back from this screen')),
                );
              }
            },
            backgroundColor: Colors.black.withOpacity(0.5),
            mini: true,
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        // Aperçu de l'image en plein écran
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Image.file(
            _image!,
            fit: BoxFit.contain,
          ),
        ),
        
        // Bouton pour utiliser cette image
        Positioned(
          bottom: 30,
          left: 30,
          right: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: _continueToNextStep,
            child: const Text('Utiliser cette image', style: TextStyle(fontSize: 16)),
          ),
        ),
        
        // Bouton pour réessayer
        Positioned(
          top: 40,
          left: 20,
          child: FloatingActionButton(
            heroTag: "backBtn",
            onPressed: () {
              setState(() {
                _image = null;
              });
            },
            backgroundColor: Colors.black.withOpacity(0.5),
            mini: true,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
