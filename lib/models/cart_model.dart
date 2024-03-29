import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual_flutter/datas/cart_product.dart';
import 'package:loja_virtual_flutter/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class CartModel extends Model{
  UserModel user;
  List<CartProduct> products = [];
  bool isLoading = false;
  String couponCode;
  int discountPercentage = 0;

  CartModel(this.user){
    if(user.isLoggedIn())
      _loadCartItems();
  }

  static CartModel of(BuildContext context)=>ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct){
    products.add(cartProduct);
    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart").add(cartProduct.toMap()).then((doc){
      cartProduct.cartID = doc.documentID;
    });
  }

  void removeCartItem(CartProduct cartProduct){
    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart").document(cartProduct.cartID).delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct){
    cartProduct.quantity--;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
    .document(cartProduct.cartID).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartProduct){
    cartProduct.quantity++;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .document(cartProduct.cartID).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage){
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  void updatePrices(){
    notifyListeners();
  }

  double getProductsPrice(){
    double price = 0.0;
    for(CartProduct c in products){
      if(c.productData != null)
        price += c.quantity * c.productData.price;
    }
    return price;
  }

  double getDiscount(){
    return getProductsPrice() * discountPercentage/100;
  }

  double getShipPrice(){
    return 9.99;
  }

  Future<String> finishOrder() async {
    if(products.length == 0) return null;

    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();
    
    DocumentReference refOrder = await Firestore.instance.collection("orders").add({
        "clientId": user.firebaseUser.uid,
        "products": products.map((cartProduct)=>cartProduct.toMap()).toList(),
        "shiPrice": shipPrice,
        "productsPrice": productsPrice,
        "discount": discount,
        "totalPrice": productsPrice - discount + shipPrice,
        "status": 1
      }
    );

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("orders").document(refOrder.documentID).setData({
      "orderId": refOrder.documentID
    });

    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart").getDocuments();

    for(DocumentSnapshot doc in query.documents){
      doc.reference.delete();
    }

    products.clear();
    couponCode = null;
    isLoading = false;
    notifyListeners();

    return refOrder.documentID;
  }

  void _loadCartItems() async {
    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .getDocuments();

    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();

  }
  
}