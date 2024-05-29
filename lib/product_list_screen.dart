import 'dart:convert';

import 'package:crud_app/add_product.dart';
import 'package:crud_app/product_model.dart';
import 'package:crud_app/update_product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _getProductListInprogress = false;
  List<ProductModel> productList = [];

  @override
  void initState() {
    _getProductList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: RefreshIndicator(
        onRefresh: _getProductList,
        child: Visibility(
          visible: _getProductListInprogress == false,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: ListView.separated(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return _buildProductItem(productList[index]);
            },
            separatorBuilder: (_, __) => const Divider(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddProductScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _getProductList() async {
    _getProductListInprogress = true;
    setState(() {});
    productList.clear();
    const String productListUrl =
        "https://crud.teamrabbil.com/api/v1/ReadProduct";
    Uri uri = Uri.parse(productListUrl);
    Response response = await get(uri);

    print(response.body);
    print(response.headers);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final jsonProductList = decodedData['data'];
      for (Map<String, dynamic> json in jsonProductList) {
        ProductModel productModel = ProductModel.fromJson(json);
        productList.add(productModel);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Get product list failed.",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
    _getProductListInprogress = false;
    setState(() {});
  }

  Widget _buildProductItem(ProductModel product) {
    return ListTile(
      leading: Image.network(
        product?.image ?? 'Unknown',
        height: 60,
      ),
      title: Text(product?.productName ?? 'Unknown'),
      subtitle: Wrap(
        spacing: 6,
        children: [
          Text('Unit Price: ${product.unitPrice}'),
          Text('Quantity: ${product.quantity}'),
          Text('Total Price: ${product.totalPrice}'),
        ],
      ),
      trailing: Wrap(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateProductScreen(
                          product: product,
                        )),
              );
              if (result == true){
                _getProductList();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(product.id!);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String productId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure you want to delete?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: const Text('Yes, delete'),
              onPressed: () {
                _deleteProduct(productId); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    _getProductListInprogress = true;
    setState(() {});
    productList.clear();
    String deleteProductUrl =
        "https://crud.teamrabbil.com/api/v1/DeleteProduct/$productId";
    Uri uri = Uri.parse(deleteProductUrl);
    Response response = await get(uri);

    print(response.body);
    print(response.headers);

    if (response.statusCode == 200) {
      _getProductList();
    } else {
      _getProductListInprogress = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Delete product failed. Try again!",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }
  }
}
