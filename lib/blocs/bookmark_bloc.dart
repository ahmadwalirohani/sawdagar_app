import 'package:flutter/foundation.dart';
import 'package:afghan_bazar/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc extends ChangeNotifier {
  Future<List> getArticles() async {
    // String _collectionName = 'contents';
    // String _fieldName = 'bookmarked items';

    // SharedPreferences sp = await SharedPreferences.getInstance();
    // String? _uid = sp.getString('uid');

    // final DocumentReference ref =
    //     FirebaseFirestore.instance.collection('users').doc(_uid);
    // DocumentSnapshot snap = await ref.get();
    // List bookmarkedList = snap[_fieldName];
    // debugPrint('mainList: $bookmarkedList');

    List d = [];
    // if (bookmarkedList.isEmpty) {
    //   return d;
    // } else if (bookmarkedList.length <= 10) {
    //   await FirebaseFirestore.instance
    //       .collection(_collectionName)
    //       .where('timestamp', whereIn: bookmarkedList)
    //       .get()
    //       .then((QuerySnapshot snap) {
    //     d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
    //   });
    // } else if (bookmarkedList.length > 10) {
    //   int size = 10;
    //   var chunks = [];

    //   for (var i = 0; i < bookmarkedList.length; i += size) {
    //     var end = (i + size < bookmarkedList.length)
    //         ? i + size
    //         : bookmarkedList.length;
    //     chunks.add(bookmarkedList.sublist(i, end));
    //   }

    //   await FirebaseFirestore.instance
    //       .collection(_collectionName)
    //       .where('timestamp', whereIn: chunks[0])
    //       .get()
    //       .then((QuerySnapshot snap) {
    //     d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
    //   }).then((value) async {
    //     await FirebaseFirestore.instance
    //         .collection(_collectionName)
    //         .where('timestamp', whereIn: chunks[1])
    //         .get()
    //         .then((QuerySnapshot snap) {
    //       d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
    //     });
    //   });
    // } else if (bookmarkedList.length > 20) {
    //   int size = 10;
    //   var chunks = [];

    //   for (var i = 0; i < bookmarkedList.length; i += size) {
    //     var end = (i + size < bookmarkedList.length)
    //         ? i + size
    //         : bookmarkedList.length;
    //     chunks.add(bookmarkedList.sublist(i, end));
    //   }

    //   await FirebaseFirestore.instance
    //       .collection(_collectionName)
    //       .where('timestamp', whereIn: chunks[0])
    //       .get()
    //       .then((QuerySnapshot snap) {
    //     d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
    //   }).then((value) async {
    //     await FirebaseFirestore.instance
    //         .collection(_collectionName)
    //         .where('timestamp', whereIn: chunks[1])
    //         .get()
    //         .then((QuerySnapshot snap) {
    //       d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
    //     });
    //   }).then((value) async {
    //     await FirebaseFirestore.instance
    //         .collection(_collectionName)
    //         .where('timestamp', whereIn: chunks[2])
    //         .get()
    //         .then((QuerySnapshot snap) {
    //       d.addAll(snap.docs.map((e) => Article.fromFirestore(e)).toList());
    //     });
    //   });
    // }

    return d;
  }

  Future onBookmarkIconClick(String? timestamp) async {
    //final SharedPreferences sp = await SharedPreferences.getInstance();

    notifyListeners();
  }

  Future onLoveIconClick(String? timestamp) async {
    //   final SharedPreferences sp = await SharedPreferences.getInstance();
    //   final String collectionName = 'contents';
    //   String? uid = sp.getString('uid');
    //   String fieldName = 'loved items';

    //   final DocumentReference ref = FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(uid);
    //   final DocumentReference ref1 = FirebaseFirestore.instance
    //       .collection(collectionName)
    //       .doc(timestamp);

    //   DocumentSnapshot snap = await ref.get();
    //   DocumentSnapshot snap1 = await ref1.get();
    //   List d = snap[fieldName];
    //   int? loves = snap1['loves'];

    //   if (d.contains(timestamp)) {
    //     List a = [timestamp];
    //     await ref.update({fieldName: FieldValue.arrayRemove(a)});
    //     ref1.update({'loves': loves! - 1});
    //   } else {
    //     d.add(timestamp);
    //     await ref.update({fieldName: FieldValue.arrayUnion(d)});
    //     ref1.update({'loves': loves! + 1});
    //   }
  }
}
