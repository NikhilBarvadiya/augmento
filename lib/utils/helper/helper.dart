import 'package:url_launcher/url_launcher.dart';

class Helper {
  Future<void> launchURL(String val) async {
    if (await canLaunchUrl(Uri.parse(val))) {
      await launchUrl(Uri.parse(val));
    } else {
      throw 'Could not launch $val';
    }
  }
}
Helper helper = Helper();