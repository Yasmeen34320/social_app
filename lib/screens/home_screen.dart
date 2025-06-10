import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_app/screens/Shared/custom_input_label_form.dart';
import 'package:social_app/screens/log_in_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/screens/sign_up_screen.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/post_service.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController postContentController = TextEditingController();
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
    }
  }

  var data;
  void fetchUserData() async {
    var userDoc = await AuthService().getUserFromCollection(); // ✅ await here
    if (userDoc != null) {
      setState(() {
        data = userDoc.data() as Map<String, dynamic>;
      });
      // print(data);
    } else {
      print('No user document found');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Map<String, String> userImages = {}, userNames = {};
  Future<String> getUserdetails(String field, String userId) async {
    print(userId);
    if (userImages.containsKey(userId) && field == 'imageUrl') {
      print('here');

      return userImages[userId]!; // Return from cache
    }
    if (userNames.containsKey(userId) && field == 'displayName') {
      print('here');

      return userNames[userId]!; // Return from cache
    }
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userSnapshot.data();

      final imageUrl = userData?['imageUrl'] ?? "";
      final userName = userData?['displayName'] ?? "";
      userImages[userId] = imageUrl;
      userNames[userId] = userName;
      if (field == 'displayName') return userName;
      return imageUrl;
    } catch (e) {
      print("Failed to fetch user image: $e");
      return "";
    }
  }

  Future<void> clearUserImageCache(String userId) async {
    userImages.remove(userId);
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Center(
            child: const Text(
              'Home',
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 77, 10, 88),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            tooltip: 'Logout',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 77, 10, 88),
                  ),
                ),
              );
              try {
                await AuthService().logOutUser();
              } finally {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop(); // Remove loading
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return LogInScreen();
                  },
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),

      body: StreamBuilder(
        stream: PostService().getAllPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              data == null) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final querySnapshot = snapshot.data as QuerySnapshot;
          final posts = querySnapshot.docs;
          if (posts.isEmpty) {
            return data != null && data['imageUrl'] != null
                ? sharedContainer()
                : SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return data != null && data['imageUrl'] != null
                      ? sharedContainer()
                      : SizedBox();
                }
                final postData =
                    posts[index - 1].data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FutureBuilder<String>(
                                future: getUserdetails(
                                  'imageUrl',
                                  postData['userId'],
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircleAvatar(
                                      radius: 30,
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data == "") {
                                    return CircleAvatar(
                                      radius: 30,
                                      child: Icon(Icons.person),
                                    );
                                  }

                                  return CircleAvatar(
                                    radius: 30,
                                    backgroundImage: MemoryImage(
                                      base64Decode(snapshot.data!),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String>(
                                    future: getUserdetails(
                                      'displayName',
                                      postData['userId'],
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text('Loading..');
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data == "") {
                                        return Text('Unknown');
                                      }

                                      return Text(
                                        snapshot.data!, //displayName
                                        style: TextStyle(
                                          fontFamily: 'popins',
                                          fontSize: 18,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    postData['timestamp'] != null
                                        ? timeago.format(
                                            postData['timestamp'].toDate(),
                                          )
                                        : 'Unknown time',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              if (postData['userId'] == currentUser?.uid)
                                PopupMenuButton(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _showEditPostDialog(
                                        postId: posts[index - 1].id,
                                        currentContent: postData['content'],
                                        currentImageBase64:
                                            postData['imageBase64'],
                                        action: 'edit',
                                      );
                                    } else {
                                      await PostService().deletePost(
                                        posts[index - 1].id,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Post deleted')),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          letterSpacing: 1,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          letterSpacing: 1,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          SizedBox(height: 20),
                          Text(
                            postData['content'],
                            style: TextStyle(fontSize: 17, letterSpacing: 1),
                          ),
                          SizedBox(height: 20),
                          if (postData['imageBase64'] != '')
                            Image.memory(base64Decode(postData['imageBase64'])),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(
                                ((index + 1) % 2 == 0)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: ((index + 1) % 2 == 0)
                                    ? Colors.red
                                    : Colors.black,
                                size: 27,
                              ),
                              SizedBox(width: 4),
                              Text('12'),
                              SizedBox(width: 20),
                              Icon(Icons.comment, size: 27),
                              SizedBox(width: 6),
                              Text('23'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Padding(padding: EdgeInsets.all(10));
              },
              itemCount: posts.length + 1,
            ),
          );
        },
      ),
    );
  }

  void _showEditPostDialog({
    required String postId,
    required String currentContent,
    required String currentImageBase64,
    required String action,
  }) {
    postContentController = TextEditingController(text: currentContent);

    String? localBase64Image = (action == 'edit')
        ? currentImageBase64
        : base64Image;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: action == 'edit' ? Text('Edit Post') : Text('Add Post'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: postContentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: (action == 'edit')
                            ? 'Edit content'
                            : 'Enter post content',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await pickAndConvertImage();
                        // setState(() {});
                        print('here');
                        setModalState(() {
                          localBase64Image = base64Image!;
                        });
                      },
                      icon: Icon(Icons.image),
                      label: (action == 'edit')
                          ? Text("Change Image")
                          : Text("Pick Image"),
                    ),
                    const SizedBox(height: 10),
                    if (localBase64Image != null &&
                        localBase64Image!.isNotEmpty)
                      Image.memory(base64Decode(localBase64Image!)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    selectedImage = null;
                    base64Image = '';
                    localBase64Image = '';
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newContent = postContentController.text.trim();
                    if (newContent.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Post Content cannot be empty')),
                      );
                      return;
                    }
                    //add
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          Center(child: CircularProgressIndicator()),
                    );
                    try {
                      if (action == 'edit') {
                        await PostService().updatePost(
                          postId: postId,
                          content: newContent,
                          imageBase64: base64Image,
                        );
                      } else {
                        User? currentUser = FirebaseAuth.instance.currentUser;
                        String? userId = currentUser?.uid;

                        final userSnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get();

                        final userData =
                            userSnapshot.data() as Map<String, dynamic>?;
                        String? username = userData!['displayName'];
                        await PostService().addPost(
                          userId: userId!, // Replace with current user's ID
                          content: postContentController.text,
                          username: username!,
                          imageBase64: base64Image ?? "",
                        );
                      }
                      postContentController.clear();

                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.of(context).pop(); // close dialog
                      // close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: (action == 'edit')
                              ? Text('Post updated')
                              : Text("Post added successfully"),
                        ),
                      );
                      selectedImage = null;
                      base64Image = '';
                      localBase64Image = '';
                    } catch (e) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pop(); // close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: (action == 'edit')
                              ? Text("Failed to add post: $e")
                              : Text('Failed to edit post: $e'),
                        ),
                      );
                      localBase64Image = '';
                    }
                  },
                  child: (action == 'edit') ? Text('Save') : Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  sharedContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ProfileScreen(user: data);
                    },
                  ),
                );
                if (res == true) {
                  setState(() {
                    clearUserImageCache(data['uid']);

                    fetchUserData();
                  });
                }
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: MemoryImage(base64Decode(data['imageUrl'])),
              ),
            ),
            SizedBox(width: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onTap: () {
                    _showEditPostDialog(
                      postId: '',
                      currentContent: '',
                      currentImageBase64: '',
                      action: 'add',
                    );
                  },
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    fillColor: Colors.white,
                    filled: true,
                    hintStyle: TextStyle(letterSpacing: 2),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 77, 10, 88),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
