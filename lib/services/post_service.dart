import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addPost({
    required String userId,
    required String content,
    String? imageBase64,
    required String username,
  }) async {
    await firestore.collection('posts').add({
      'userId': userId,
      'content': content,
      'username': username,
      'imageBase64': imageBase64 ?? '',

      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAllPosts() {
    return firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection('posts');

  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    String? imageBase64,
  }) async {
    await postsCollection.doc(postId).update({
      'content': content,
      'imageBase64': imageBase64 ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
