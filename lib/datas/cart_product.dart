import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual_flutter/datas/product_data.dart';

class CartProduct{
  String cartID;
  String category;
  String productID;
  int quantity;
  String size;

  ProductData productData;

  CartProduct();

  CartProduct.fromDocument(DocumentSnapshot document){
    cartID = document.documentID;
    category = document.data["category"];
    productID = document.data["productID"];
    quantity = document.data["quantity"];
    size = document.data["size"];
  }

  Map<String, dynamic> toMap(){
    return {
      "category": category,
      "productID": productID,
      "quantity": quantity,
      "size": size,
     // "product": productData.toResumeMap()
    };
  }

}