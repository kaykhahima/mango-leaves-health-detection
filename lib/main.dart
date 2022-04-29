import 'dart:convert';
import 'dart:developer';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;

import 'model/server_prediction_response.dart';

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
    return MaterialApp(
      home: const ImageUploadPage(),
      theme: ThemeData(
        primaryColor: const Color(0xff3e6b04),
      ),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({Key? key}) : super(key: key);

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {

  bool isLoading = false;

  @override
  void initState() {
    if (mounted) {
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mango Leaves Health Detection'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading ? _showLoadingDialogue() : const SizedBox.shrink(),
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

        await predictImage(context, file);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 35.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: [
            Icon(
              LineIcons.upload,
              size: 30.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text('Upload photo'),
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

        await predictImage(context, file);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 35.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: [
            Icon(
              LineIcons.camera,
              size: 30.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text('Take photo'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetWidget(
      BuildContext bottomSheetContext, XFileImage image, int status, double confidence) {
    Color chipColor;
    String healthStatus;

    if (status == 0) {
      //the leaf is diseased
      healthStatus = 'Diseased';
      chipColor = Colors.redAccent;
    } else if (status == 1) {
      //the leaf is healthy
      healthStatus = 'Healthy';
      chipColor = Theme.of(context).primaryColor;
    } else {
      //unknown
      healthStatus = 'Unknown';
      chipColor = Colors.amberAccent;
    }

    return Container(
      height: 400,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 200.0,
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
              height: 15.0,
            ),
            const Divider(),
            Row(
              children: [
                const Text('Status: '),
                const SizedBox(
                  width: 10.0,
                ),
                Chip(
                  backgroundColor: chipColor, //CircleAvatar
                  label: Text(
                    healthStatus,
                    style: const TextStyle(color: Colors.white),
                  ), //Text
                ),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              children: [
                const Text('Confidence: '),
                const SizedBox(
                  width: 10.0,
                ),
                Text(confidence.toString()),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      primary: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          LineIcons.camera, size: 20.0,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('Take New Photo', style: TextStyle(fontSize: 13.0),),
                      ],
                    ),
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);
                      // Capture a photo
                      final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);

                      final file = XFileImage(photo!);

                      await predictImage(context, file);
                    },
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      primary: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          LineIcons.upload, size: 20.0,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('Upload New Image', style: TextStyle(fontSize: 13.0),),
                      ],
                    ),
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);
                      // Pick an image
                      final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);

                      final file = XFileImage(image!);

                      await predictImage(context, file);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  predictImage(BuildContext bottomSheetContext, XFileImage image) async {
    setState(() {
      isLoading = true;
    });

    final bytes = await image.file.readAsBytes();
    String base64Image = base64Encode(bytes);

    var client = http.Client();

    final payload =
        jsonEncode({'image': base64Image, 'application': 'mangoes-leaves1'});

    var baseUrl = dotenv.env['BASE_URL'];
    var apiKey = dotenv.env['API_KEY'];

    String endpointUrl = baseUrl! + '/v1/lambda/predict';
    // String endpointUrl = baseUrl! + '/v1/sagemaker/predict';

    var url = Uri.parse(endpointUrl);

    var response = await client.post(url, body: payload, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "x-api-key": apiKey!,
    });

    print(response.body);

    int? results;
    double? confidence;

    try {
      final predictResponse = predictResponseFromJson(response.body);
      results = predictResponse.results;
      confidence = predictResponse.confidence;
    } catch (e) {
      results = null;
      confidence = null;
    }

    setState(() {
      isLoading = false;
    });

    showModalBottomSheet<void>(
      context: bottomSheetContext,
      builder: (BuildContext bottomSheetContext) {
        return _buildBottomSheetWidget(bottomSheetContext, image, results!, confidence!);
      },
    );
  }

  Widget _showLoadingDialogue() {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Row(
          children: [
            CircularProgressIndicator(color: Theme.of(context).primaryColor,),
            const SizedBox(width: 10.0,),
            const Text('Loading...'),
          ],
        )
      ),
    );
  }
}
