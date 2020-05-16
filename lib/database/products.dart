import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class ProductService
{

  Firestore _firestore = Firestore.instance;
  String ref = 'products';

  void uploadProducts({String productName, String brand, String category, int quantity, String images, List sizes, List colors ,double price, bool sale, bool featured}){
    var id = new Uuid();
    String productId = id.v1();

    _firestore.collection(ref)
      .document(productId)
      .setData({
        'name':productName,
        'id':productId,
        'brand':brand,
        'categoty':category,
        'price': price,
        'sizes': sizes,
        'quantity': quantity,
        'images': images,
        'sale': sale,
        'featured': featured,
        'colors': colors
      });
  }
}