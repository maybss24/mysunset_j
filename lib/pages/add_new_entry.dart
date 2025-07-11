import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/sunset_entry.dart';


class AddNewEntryPage extends StatefulWidget {
  final void Function(SunsetEntry) onSave;

  const AddNewEntryPage({super.key, required this.onSave});

  @override
  State<AddNewEntryPage> createState() => _AddNewEntryPageState();
}

class _AddNewEntryPageState extends State<AddNewEntryPage> {
  File? _image;
  final _captionController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEntry() {
    if (_image == null ||
        _captionController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select an image.")),
      );
      return;
    }

    final entry = SunsetEntry(
      image: _image!,
      caption: _captionController.text.trim(),
      description: _descriptionController.text.trim(),
      date: DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
      rawDate: _selectedDate,
    );

    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Entry"),
        backgroundColor: Colors.pink.shade300,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Shadow
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _image == null
                  ? const Center(
                child: Icon(Icons.image, size: 80, color: Colors.grey),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),

            // Upload Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("Upload from Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade200,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                shadowColor: Colors.pink.shade100,
              ),
            ),
            const SizedBox(height: 24),

            // Caption Field with shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  labelText: "Caption",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description Field with shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      enabled: false,
                      controller: TextEditingController(
                        text: DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      ),
                      decoration: InputDecoration(
                        labelText: "Date of Sunset",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  color: Colors.pink.shade300,
                  tooltip: "Pick Date",
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade200,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
              ),
              child: const Text("Save Entry", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
