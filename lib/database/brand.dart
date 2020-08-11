import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BrandService {
  Firestore _firestore = Firestore.instance;
  String ref = 'brands';

  void createBrand(String name) {
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection(ref).document(brandId).setData({'brand': name});
  }

  // ignore: missing_return
  Future<List<DocumentSnapshot>> getBrands() =>

     _firestore.collection(ref).getDocuments().then((snaps) {
      print(snaps.documents.length);
      return snaps.documents;
    });



  Future<List<DocumentSnapshot>> getSuggestion(String suggestion) => _firestore
      .collection(ref)
      .where('brand', isEqualTo: suggestion)
      .getDocuments()
      .then((value) {
    return value.documents;
  });
}
