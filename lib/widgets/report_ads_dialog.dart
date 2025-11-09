import 'package:afghan_bazar/pages/home.dart';
import 'package:flutter/material.dart';

class ReportAdDialog extends StatefulWidget {
  final Future<void> Function(String reason, String comment) onSubmit;

  const ReportAdDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<ReportAdDialog> createState() => _ReportAdDialogState();
}

class _ReportAdDialogState extends State<ReportAdDialog> {
  String? _selectedReason;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  final List<String> _reasons = [
    'Offensive content',
    'Fraud',
    'Duplicate ad',
    'Product already sold',
    'Wrong category',
    'Product unavailable',
    'Fake product',
    'Indecent',
    'Other',
  ];

  void _handleSubmit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a reason')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSubmit(_selectedReason!, _commentController.text);
      Navigator.of(context).pop(); // Close dialog after successful submission
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Optional: handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submission failed. Please try again.',
            style: TextStyle(
              color: Colors.white,
            ), // Change text color to white for contrast
          ),
          backgroundColor: Colors.red, // Success color
          behavior:
              SnackBarBehavior.floating, // Position the Snackbar at the top
          margin: EdgeInsets.only(
            top: 50.0,
            left: 20.0,
            right: 20.0,
          ), // Add margin to give space from top
          duration: Duration(seconds: 3), // Customize duration if needed
        ),
      );
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
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Report this Ad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ..._reasons.map(
              (reason) => RadioListTile<String>(
                value: reason,
                groupValue: _selectedReason,
                title: Text(reason),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 3,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Enter details (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isLoading
                      ? Colors.teal[800]
                      : Colors.teal[900],
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Submit Complain',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
