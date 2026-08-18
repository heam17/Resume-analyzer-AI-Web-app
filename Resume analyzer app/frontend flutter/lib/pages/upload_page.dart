import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import 'result_page.dart';

class UploadPage extends StatefulWidget {
  final String jobRole;
  final List<String> skills;
  final int experience;
  final int vacancy;

  const UploadPage({
    super.key,
    required this.jobRole,
    required this.skills,
    required this.experience,
    required this.vacancy,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final List<File> _selectedFiles = [];
  bool _isAnalyzing = false;

  Future<void> _pickFiles() async {
    const pdfTypeGroup = XTypeGroup(
      label: 'PDF resumes',
      extensions: ['pdf'],
      mimeTypes: ['application/pdf'],
    );
    try {
      final files = await openFiles(acceptedTypeGroups: [pdfTypeGroup]);
      if (files.isEmpty) return;
      setState(() {
        for (final f in files) {
          final alreadyAdded = _selectedFiles.any((existing) => existing.path == f.path);
          if (!alreadyAdded) _selectedFiles.add(File(f.path));
        }
      });
    } catch (e) {
      _showSnack('Could not open the file picker. Please try again.', isError: true);
    }
  }

  void _removeFile(File file) {
    setState(() => _selectedFiles.remove(file));
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorContainer : AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _analyze() async {
    if (_isAnalyzing || ApiService.instance.isRequestInFlight) return;

    if (_selectedFiles.isEmpty) {
      _showSnack('Please select at least one resume to analyze.', isError: true);
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final response = await ApiService.instance.analyzeJob(
        jobRole: widget.jobRole,
        skills: widget.skills,
        experience: widget.experience,
        files: _selectedFiles,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(response: response, jobRole: widget.jobRole, vacancy: widget.vacancy),
        ),
      );
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Unexpected error occurred. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFiles = _selectedFiles.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          const FloatingBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Center',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Processing ${widget.vacancy} open vacanc${widget.vacancy == 1 ? 'y' : 'ies'} for ${widget.jobRole}.',
                          style: TextStyle(fontSize: 14, color: AppColors.outline),
                        ),
                        const SizedBox(height: 24),
                        _buildUploadZone(hasFiles),
                        const SizedBox(height: 20),
                        CustomButton(
                          label: _isAnalyzing ? 'Analyzing...' : 'Analyze Candidates',
                          icon: Icons.psychology_outlined,
                          isLoading: _isAnalyzing,
                          borderRadius: 16,
                          onPressed: hasFiles ? _analyze : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: AppColors.onSurface),
          ),
          Icon(Icons.hub_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text('AI Resume Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildUploadZone(bool hasFiles) {
    return GestureDetector(
      onTap: _pickFiles,
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.upload_file_outlined, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              hasFiles ? 'Ready to analyze ${_selectedFiles.length} resume${_selectedFiles.length == 1 ? '' : 's'}' : 'Upload Resumes from Device',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              hasFiles ? "Tap 'Analyze Candidates' to begin AI ranking." : 'Tap to select PDF files. You can select multiple files at once.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.outline),
            ),
            if (hasFiles) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _selectedFiles.map((f) => _FileChip(file: f, onRemove: () => _removeFile(f))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _FileChip({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name = file.path.split(Platform.pathSeparator).last;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.onSurface)),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 12, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
