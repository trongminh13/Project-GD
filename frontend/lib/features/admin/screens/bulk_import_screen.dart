import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
          _statusMessage = "Uploading file, please wait...";
        });

        final filePath = result.files.single.path!;
        final token = await AuthService().getToken();

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.baseUrl}/admin/migration/upload-excel'),
        );

        request.headers.addAll({'Authorization': 'Bearer $token'});

        request.files.add(await http.MultipartFile.fromPath('file', filePath));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          setState(() {
            _statusMessage = response.body;
          });
        } else {
          setState(() {
            _statusMessage =
                "Failed: ${response.statusCode} - ${response.body}";
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Data Import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.table_view, size: 80, color: AppColors.primaryOf(context)),
            const SizedBox(height: 24),
            Text(
              'Upload the Student details Excel file to seed the database records.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _pickAndUploadFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Excel File (.xlsx)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOf(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains("Success")
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusMessage!.contains("Success")
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains("Success")
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
