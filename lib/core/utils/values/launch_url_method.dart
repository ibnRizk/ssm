// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> onLaunch({
  required BuildContext context,
  required String url,
  required String platformName,
}) async {
  final Uri uri = Uri.parse(url);
  if (platformName == 'Whatsapp') {
    //todo remove +20 from url
    if (!await launchUrl(Uri.parse('https://wa.me/+20$url/?text=Hello'))) {
      _showErrorMessage(context, 'Could not launch WhatsApp');
    }
  } else if (platformName == 'Phone Call') {
    await makePhoneCall(phoneNumber: url, context: context);
  } else {
    if (!await launchUrl(uri)) {
      _showErrorMessage(context, 'Could not launch $platformName');
    }
  }
}

void _showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

//--------------launch phone call
Future<void> makePhoneCall({
  required String phoneNumber,
  required BuildContext context,
}) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  try {
    if (await launchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorMessage(context, 'Could not launch phone call to $phoneNumber');
    }
  } catch (e) {
    _showErrorMessage(context, 'Could not launch phone call to $phoneNumber');
  }
}
