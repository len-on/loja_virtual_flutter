import 'package:flutter/material.dart';
import 'package:loja_virtual_flutter/tabs/home_tab.dart';
import 'package:loja_virtual_flutter/tabs/products_tab.dart';
import 'package:loja_virtual_flutter/widgets/cart_button.dart';
import 'package:loja_virtual_flutter/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Scaffold(
            body: HomeTab(),
          drawer: CustomDrawer(_pageController),
          floatingActionButton: CartButton(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Produtos"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: ProductsTab(),
          floatingActionButton: CartButton(),
        ),
        Container(color: Colors.yellow),
        Container(color: Colors.red),
        Container(color: Colors.green),
      ],
    );
  }
}
