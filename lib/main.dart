import 'dart:convert';
import 'dart:developer';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

final ImagePicker _picker = ImagePicker();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatelessWidget {
  const ImageUploadPage({Key? key}) : super(key: key);
  static const primaryColor = Color(0xff30a84b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mango Leaves DS'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTakePhotoWidget(context),
                const SizedBox(
                  width: 10.0,
                ),
                _buildUploadPhotoWidget(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPhotoWidget(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Pick an image
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);

        final file = XFileImage(image!);

        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomSheetWidget(context, file);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 35.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: const [
            Icon(
              LineIcons.upload,
              size: 30.0,
              color: primaryColor,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text('Upload photo'),
          ],
        ),
      ),
    );
  }

  Widget _buildTakePhotoWidget(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Capture a photo
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.camera);

        final file = XFileImage(photo!);

        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomSheetWidget(context, file);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 35.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: const [
            Icon(
              LineIcons.camera,
              size: 30.0,
              color: primaryColor,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text('Take photo'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetWidget(BuildContext context, XFileImage image) {
    return Container(
      height: 470,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 300.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Predict'),
              onPressed: () async {
                // Navigator.pop(context);
                await predictImage(image);
              },
            ),
          ],
        ),
      ),
    );
  }

  predictImage(XFileImage image) async {
    final bytes = await image.file.readAsBytes();
    String base64Image = base64Encode(bytes);

    var client = http.Client();

    final payload =
        jsonEncode({'image': base64Image, 'application': 'mangoes-leaves'});

    var baseUrl = dotenv.env['BASE_URL'];
    var apiKey = dotenv.env['API_KEY'];

    // String endpointUrl = baseUrl! + '/v1/lambda/predict';
    String endpointUrl = baseUrl! + '/v1/sagemaker/predict';

    var url = Uri.parse(endpointUrl);

    var response = await client.post(url, body: payload, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "x-api-key": apiKey!,
    });

    print(response.body);

  }
}
