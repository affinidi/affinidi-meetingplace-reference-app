import 'package:flutter/material.dart';

/// Data model for a single detail row in a credential
class CredentialDetailRowData {
  const CredentialDetailRowData({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

/// Reusable widget for displaying credential detail rows
class CredentialDetailRow extends StatelessWidget {
  const CredentialDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
