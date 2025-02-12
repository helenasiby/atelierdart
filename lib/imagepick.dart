import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryUploadPage extends StatefulWidget {
  final String productId; // Pass the product ID to update
  const CloudinaryUploadPage({Key? key, required this.productId})
      : super(key: key);

  @override
  _CloudinaryUploadPageState createState() => _CloudinaryUploadPageState();
}

class _CloudinaryUploadPageState extends State<CloudinaryUploadPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;
  String? _uploadedImageUrl;

  // Cloudinary configuration
  final String cloudName = "djg2fn4b7"; // Replace with your Cloudinary cloud name
  final String uploadPreset = "main_project"; // Replace with your unsigned preset name

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageData;
        _uploadedImageUrl = null;
      });
    }
  }

  // Function to upload image to Cloudinary and update Firestore
  Future<void> _uploadToCloudinary() async {
    if (_imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading to Cloudinary...")),
      );

      // Cloudinary upload endpoint
      final uri = Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      // Prepare the request
      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            "file",
            _imageData!,
            filename: "image.jpg",
          ),
        );

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        // Get the secure URL of the uploaded image
        final imageUrl = jsonResponse["secure_url"];
        setState(() {
          _uploadedImageUrl = imageUrl;
        });

        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId) // Use the passed productId
            .update({'imagePath': imageUrl});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uploaded and updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload failed. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image to Cloudinary"),
        backgroundColor: const Color.fromARGB(255, 238, 140, 165),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageData != null) ...[
              Image.memory(
                _imageData!,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image from Gallery"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadToCloudinary,
              child: const Text("Upload to Cloudinary"),
            ),
            const SizedBox(height: 20),
            if (_uploadedImageUrl != null) ...[
              const Text(
                "Uploaded Image URL:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("URL copied to clipboard!")),
                  );
                },
                child: Text(
                  _uploadedImageUrl!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
