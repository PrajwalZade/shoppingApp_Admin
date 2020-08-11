import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app_admin/database/brand.dart';
import 'package:shop_app_admin/database/category.dart';
import 'package:shop_app_admin/database/products.dart';

class AddProducts extends StatefulWidget {
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  final priceController = TextEditingController();

  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];

  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];

  String _currentCategory;

  String _currentBands;
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  List<String> selectedSizes = <String>[];
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;

  @override
  // ignore: must_call_super
  void initState() {
    // TODO: implement initState
    _getCategories();
    _getBrands();

//    print(categoriesDropDown.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: white,
        leading: Icon(
          Icons.close,
          color: black,
        ),
        title: Text(
          "add products",
          style: TextStyle(color: black),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    Row(
                      children: [
//========================================== IMAGE PICKER BOX1 ===================================================
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      1);
                                },
                                child: _displayChild1()),
                          ),
                        ),
//======================================================== IMAGE PICKER BOX2 ================================================================

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                child: _displayChild2()),
                          ),
                        ),
                        //========================================== IMAGE PICKER BOX3 ============================================================================
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      3);
                                },
                                child: _displayChild3()),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "enter the product name with maximum 10 character long",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: productNameController,
                        decoration: InputDecoration(hintText: "Product Name"),
                        // ignore: missing_return
                        validator: (value) {
                          if (value.isEmpty) {
                            return "You must enter product name";
                          } else if (value.length > 10) {
                            return "product name cant't have more than 10 letters";
                          }
                        },
                      ),
                    ),
//=================================== SELECT CATEGORY DROP-DOWN-BUTTON ================================================================

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Category: ",
                            style: TextStyle(color: red),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: DropdownButton(
                            items: categoriesDropDown,
                            onChanged: changeSelectedCategory,
                            value: _currentCategory,
                            style: TextStyle(fontSize: 14.0, color: black),
                          ),
                        ),
//==================================================== SELECT BRANDS DROP-DOWN-BUTTON ======================================================
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "Brands: ",
                            style: TextStyle(color: red),
                          ),
                        ),
                        DropdownButton(
                          items: brandsDropDown,
                          onChanged: changeSelectedBrand,
                          value: _currentBands,
                          style: TextStyle(fontSize: 14.0, color: black),
                        ),
                      ],
                    ),
// =================================== QUANTITY ==============================================================================
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 00, right: 8, left: 8),
                      child: TextFormField(
                        controller: quantityController,
//                  initialValue: '1',
                        decoration: InputDecoration(
                          hintText: "Quantity",
                        ),
                        keyboardType: TextInputType.numberWithOptions(),
                        // ignore: missing_return
                        validator: (value) {
                          if (value.isEmpty) {
                            return "enter quantity";
                          }
                        },
                      ),
                    ),

//========================================================== PRICE ===========================================================
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: priceController,
//                 initialValue: '0.00',
                        decoration: InputDecoration(
                          hintText: "Price",
                        ),
                        keyboardType: TextInputType.numberWithOptions(),
                        // ignore: missing_return
                        validator: (value) {
                          if (value.isEmpty) {
                            return "enter price";
                          }
                        },
                      ),
                    ),

//============================================== AVAILABLE SIZES ==================================================================
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Available Sizes"),
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: selectedSizes.contains('S'),
                          onChanged: (value) => changeSelectedSize('S'),
                        ),
                        Text('S'),
                        Checkbox(
                          value: selectedSizes.contains('M'),
                          onChanged: (value) => changeSelectedSize('M'),
                        ),
                        Text('M'),
                        Checkbox(
                          value: selectedSizes.contains('L'),
                          onChanged: (value) => changeSelectedSize('L'),
                        ),
                        Text('L'),
                        Checkbox(
                          value: selectedSizes.contains('XL'),
                          onChanged: (value) => changeSelectedSize('XL'),
                        ),
                        Text('XL'),
                        Checkbox(
                          value: selectedSizes.contains('XXL'),
                          onChanged: (value) => changeSelectedSize('XXL'),
                        ),
                        Text('XXL'),
                      ],
//              mainAxisSize: MainAxisSize.max,
//              mainAxisAlignment: MainAxisAlignment.start,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              verticalDirection: VerticalDirection.down,
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: selectedSizes.contains('28'),
                          onChanged: (value) => changeSelectedSize('28'),
                        ),
                        Text('28'),
                        Checkbox(
                          value: selectedSizes.contains('30'),
                          onChanged: (value) => changeSelectedSize('30'),
                        ),
                        Text('30'),
                        Checkbox(
                          value: selectedSizes.contains('32'),
                          onChanged: (value) => changeSelectedSize('32'),
                        ),
                        Text('32'),
                        Checkbox(
                          value: selectedSizes.contains('34'),
                          onChanged: (value) => changeSelectedSize('34'),
                        ),
                        Text('34'),
                        Checkbox(
                          value: selectedSizes.contains('36'),
                          onChanged: (value) => changeSelectedSize('36'),
                        ),
                        Text('36'),
                      ],
//              mainAxisSize: MainAxisSize.max,
//              mainAxisAlignment: MainAxisAlignment.start,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              verticalDirection: VerticalDirection.down,
                    ),
//
                    Row(
                      children: [
                        Checkbox(
                          value: selectedSizes.contains('38'),
                          onChanged: (value) => changeSelectedSize('38'),
                        ),
                        Text('38'),
                        Checkbox(
                          value: selectedSizes.contains('40'),
                          onChanged: (value) => changeSelectedSize('40'),
                        ),
                        Text('40'),
                        Checkbox(
                          value: selectedSizes.contains('42'),
                          onChanged: (value) => changeSelectedSize('42'),
                        ),
                        Text('42'),
                        Checkbox(
                          value: selectedSizes.contains('44'),
                          onChanged: (value) => changeSelectedSize('44'),
                        ),
                        Text('44'),
                        Checkbox(
                          value: selectedSizes.contains('46'),
                          onChanged: (value) => changeSelectedSize('46'),
                        ),
                        Text('46'),
                      ],
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: selectedSizes.contains('48'),
                          onChanged: (value) => changeSelectedSize('48'),
                        ),
                        Text('48'),
                        Checkbox(
                          value: selectedSizes.contains('50'),
                          onChanged: (value) => changeSelectedSize('50'),
                        ),
                        Text('50'),
                      ],
                    ),

// ========================== ADD BUTTON =====================================
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        color: red,
                        textColor: white,
                        child: Text("add product"),
                        onPressed: () {
                          vaildateAndUploadImage();
                        },
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

//================================ CATEGORY SELECTION METHODS ==============================================================================
  List<DropdownMenuItem<String>> getCategoriesDropDown() {
    List<DropdownMenuItem<String>> items = new List();

    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
              child: Text(categories[i].data['category']),
              value: categories[i].data['category'],
            ));
      });
    }
    return items;
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);

    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropDown();

      _currentCategory = categories[0].data['category'];
//            print(categories.length);
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() {
      _currentCategory = selectedCategory;
    });
  }

// ====================================================== BRAND SELECTION METHODS ============================================================
  void _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);

    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();

      _currentBands = brands[0].data['brand'];
//            print(categories.length);
    });
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();

    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
              child: Text(brands[i].data['brand']),
              value: brands[i].data['brand'],
            ));
      });
    }
    return items;
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() {
      _currentBands = selectedBrand;
    });
  }

  changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }

//================================================= IMAGE SELECTING CODE ==================================================================================
  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() {
          _image1 = tempImg;
        });
        break;
      case 2:
        setState(() {
          _image2 = tempImg;
        });
        break;
      case 3:
        setState(() {
          _image3 = tempImg;
        });
        break;
    }
//    _image1 = await pickImage;
//    _image2 = await pickImage;
//    _image3 = await pickImage;
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image1,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image2,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image3,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

//====================================================IMAGE UPLOADING METHOD===================================================================
  void vaildateAndUploadImage() async {
    if (_formKey.currentState.validate()) {
      setState(() => isLoading = true);
      if (_image1 != null && _image2 != null && _image3 != null) {
        if (selectedSizes.isNotEmpty) {
          String imgUrl1;
          String imgUrl2;
          String imgUrl3;
          final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
          final String picture1 =
              "1${DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()}.jpg";
          StorageUploadTask task1 =
          firebaseStorage.ref().child(picture1).putFile(_image1);
          final String picture2 =
              "2${DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()}.jpg";
          StorageUploadTask task2 =
          firebaseStorage.ref().child(picture2).putFile(_image2);
          final String picture3 =
              "3${DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()}.jpg";
          StorageUploadTask task3 =
          firebaseStorage.ref().child(picture3).putFile(_image3);
          StorageTaskSnapshot snapshot1 =
          await task1.onComplete.then((snapshot) => snapshot);
          StorageTaskSnapshot snapshot2 =
          await task2.onComplete.then((snapshot) => snapshot);
          List<String> imgList = [imgUrl1, imgUrl2, imgUrl3];

          task3.onComplete.then((snapshot3) async {
            imgUrl1 = await snapshot1.ref.getDownloadURL();
            imgUrl2 = await snapshot2.ref.getDownloadURL();
            imgUrl3 = await snapshot3.ref.getDownloadURL();

            productService.uploadProducts(
                productName: productNameController.text,
                price: double.parse(productNameController.text),
                sizes: selectedSizes,
                images: imgList,
                quantity: int.parse(quantityController.text));
            _formKey.currentState.reset();

            setState(() => isLoading = false);
            Fluttertoast.showToast(msg: "Products added");
            Navigator.pop(context);
          });
        }
        else {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: "Select at least one size");
          }
              } else {
              setState(() => isLoading = false);
              Fluttertoast.showToast(msg: "all the images must be provided");
              }
          }


    }
  }


//Expanded(
//              child: ListView.builder(
//                itemCount: categories.length,
//                itemBuilder: (context, index) {
//                  return ListTile(
//                    title: Text(categories[index]['category']),
//                  );
//                },
//              ),
//            )
//            Center(
//              child: DropdownButton(
//                items: categoriesDropDown, value: _currentCategory,
//                onChanged: changeSelectedCategory,
//              ),

//    for (DocumentSnapshot category in categories) {
//      items.add(new DropdownMenuItem(
//        child: Text(category['category']),
//        value: category['category'],
//      ));
//}
//    return items;

//========== select categories ==============
//Visibility(
//visible: _currentCategory != null,
//child: InkWell(
//child: Material(
//borderRadius: BorderRadius.circular(20),
//color: red,
//child: Padding(
//padding: const EdgeInsets.all(8.0),
//child: Row(
//children: [
//Expanded(
//child: Text(
//_currentCategory ?? '',
//style: TextStyle(color: white),
//),
//),
//IconButton(
//icon: Icon(
//Icons.close,
//color: white,
//),
//onPressed: () {
//setState(() {
//_currentCategory = '';
//});
//},
//)
//],
//),
//),
//),
//),
//),
//Padding(
//padding: const EdgeInsets.all(8.0),
//child: TypeAheadField(
//textFieldConfiguration: TextFieldConfiguration(
//autofocus: false,
//decoration: InputDecoration(
////                      border: OutlineInputBorder()
//hintText: 'add category')),
//suggestionsCallback: (pattern) async {
//return await _categoryService.getSuggestion(pattern);
//},
//
//itemBuilder: (context, suggestion) {
//return ListTile(
//leading: Icon(Icons.category),
//title: Text(suggestion['category']),
//);
//},
//onSuggestionSelected: (suggestion) {
//setState(() {
//_currentCategory = suggestion['category'];
//});
//},
//
//),
//),
// =========== select brand =================

//Visibility(
//visible: _currentBands!= null,
//child: InkWell(
//child: Material(
//borderRadius: BorderRadius.circular(20),
//color: red,
//child: Padding(
//padding: const EdgeInsets.all(8.0),
//child: Row(
//children: [
//Expanded(
//child: Text(
//_currentBands  ?? '',
//style: TextStyle(color: white),
//),
//),
//IconButton(
//icon: Icon(
//Icons.close,
//color: white,
//),
//onPressed: () {
//setState(() {
//_currentBands = '';
//});
//},
//)
//],
//),
//),
//),
//),
//),
//Padding(
//padding: const EdgeInsets.all(8.0),
//child: TypeAheadField(
//textFieldConfiguration: TextFieldConfiguration(
//autofocus: false,
//decoration: InputDecoration(
////                      border: OutlineInputBorder()
//hintText: 'add brand')),
//suggestionsCallback: (pattern) async {
//return await _brandService.getSuggestion(pattern);
//},
//
//itemBuilder: (context, suggestion) {
//return ListTile(
//leading: Icon(Icons.category),
//title: Text(suggestion['brand']),
//);
//},
//onSuggestionSelected: (suggestion) {
//setState(() {
//_currentBands = suggestion['brand'];
//});
//},
//
//),
//)
