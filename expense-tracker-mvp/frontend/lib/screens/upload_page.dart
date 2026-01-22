import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../models/receipt.dart';

/// Screen for uploading receipt images
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ApiService _apiService = ApiService();

  bool _isUploading = false;
  String? _errorMessage;
  Receipt? _uploadedReceipt;

  /// Handle file selection and upload
  Future<void> _pickAndUploadFile() async {
    setState(() {
      _errorMessage = null;
      _uploadedReceipt = null;
    });

    try {
      // Open file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled
        return;
      }

      final file = result.files.first;

      if (file.bytes == null) {
        setState(() {
          _errorMessage = 'Failed to read file';
        });
        return;
      }

      // Start upload
      setState(() {
        _isUploading = true;
        _errorMessage = null;
      });

      // Upload to backend
      final receipt = await _apiService.uploadReceipt(
        file.name,
        file.bytes!,
      );

      // Success
      setState(() {
        _isUploading = false;
        _uploadedReceipt = receipt;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt uploaded and processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Receipt'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Icon(
                Icons.receipt_long,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Upload a Receipt',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Take a photo of your receipt and upload it.\n'
                'We\'ll automatically extract and categorize your expenses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 48),

              // Upload button or loading indicator
              if (_isUploading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing receipt...'),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _pickAndUploadFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose Image'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),

              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Success message with receipt preview
              if (_uploadedReceipt != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Text(
                            'Receipt Processed!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildReceiptPreview(_uploadedReceipt!),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/receipt/${_uploadedReceipt!.id}',
                            );
                          },
                          child: const Text('View Details'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptPreview(Receipt receipt) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receipt.store,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('Date: ${receipt.date}'),
            Text('Total: ${receipt.currencySymbol}${receipt.total}'),
            Text('Items: ${receipt.itemCount ?? 0}'),
          ],
        ),
      ),
    );
  }
}
