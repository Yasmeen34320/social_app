import 'dart:convert';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/screens/Shared/custom_input_label_form.dart';

class ProfileScreen extends StatefulWidget {
  var user;
  ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? selectedImage;

  String? base64Image;

  Future<void> pickAndConvertImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      final bytes = await selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
      await update('imageUrl', base64Image);
      setState(() {});
    }
  }

  update(field, value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user['uid'])
        .update({field: value ?? ""});
  }

  TextEditingController _usernameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.user['displayName'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          Positioned(
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(),
                  color: Color.fromARGB(255, 77, 10, 88),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ),
          Positioned(
            top: 230,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.fromARGB(255, 77, 10, 88),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: (selectedImage == null)
                        ? MemoryImage(base64Decode(widget.user['imageUrl']))
                        : MemoryImage(base64Decode(base64Image ?? "")),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 355,
            left: 0,
            right: -90,
            child: GestureDetector(
              onTap: () {
                pickAndConvertImage();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 77, 10, 88),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(child: SvgPicture.asset('assets/camera-01.svg')),
              ),
            ),
          ),
          Positioned(
            top: 400,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Text(
                  widget.user['displayName'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ui/ux',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Bio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 3,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id. Placerat in id cursus mi pretium tellus duis. Pretium tellus duis convallis tempus leo eu aenean.',
                    style: TextStyle(fontSize: 15, letterSpacing: 1),
                  ),
                ),
                SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 200,
                          child: AlertDialog(
                            title: Text('Edit username'),
                            content: SizedBox(
                              height: 150,
                              child: CustomInputLabelForm(
                                hintText: 'edit username',
                                label: '',
                                validator: (String? value) {
                                  return null;
                                },
                                controller: _usernameController,
                                isPassword: false,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  selectedImage = null;
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await update(
                                    'displayName',
                                    _usernameController.text,
                                  );
                                  widget.user['displayName'] =
                                      _usernameController.text;
                                  Navigator.pop(context);
                                },
                                child: Text('save'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color.fromARGB(255, 77, 10, 88),
                    foregroundColor: Color(0xFFFFFCFC),
                    textStyle: TextStyle(fontSize: 20, letterSpacing: 3),
                    fixedSize: Size(300, 48),
                  ),
                  child: Text('Edit Username'),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Row(
                //     children: [
                //       Icon(Icons.person_3_outlined, size: 30),
                //       SizedBox(width: 10),
                //       Text(
                //         'username',
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           letterSpacing: 2,
                //           fontSize: 18,
                //         ),
                //       ),
                //       SizedBox(width: 10),
                //       Text(widget.user['displayName']),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved shape
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
