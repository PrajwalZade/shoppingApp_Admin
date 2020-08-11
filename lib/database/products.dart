import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  Firestore _firestore = Firestore.instance;
  String ref = 'products';

  void uploadProducts({String productName, String brand, String category,int quantity,List sizes, List images, double price}) {
    var id = Uuid();
    String productId = id.v1();

    _firestore.collection(ref).document(productId).setData({
      'name':productName,
      'id':productId,
      'brand': brand,
      'category':category,
      'price':price,
      'quantity':quantity,
      'images':images,
      'sizes':sizes


    });
  }

  // ignore: missing_return
//  Future<List<DocumentSnapshot>> getBrands() =>
//
//      _firestore.collection(ref).getDocuments().then((snaps) {
//        print(snaps.documents.length);
//        return snaps.documents;
//      });
//
//
//
//  Future<List<DocumentSnapshot>> getSuggestion(String suggestion) => _firestore
//      .collection(ref)
//      .where('brand', isEqualTo: suggestion)
//      .getDocuments()
//      .then((value) {
//    return value.documents;
//  });
}