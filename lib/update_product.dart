import 'dart:convert';

import 'package:crud_app/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key, required this.product});

  final Product product;

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _productCodeTEController =
      TextEditingController();
  final TextEditingController _unitPriceTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();
  final TextEditingController _totalPriceTEController = TextEditingController();
  final TextEditingController _imageTEController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  bool _updateProductInprogress = false;

  @override
  void initState() {
    super.initState();
    _nameTEController.text = widget.product.productName;
    _unitPriceTEController.text = widget.product.unitPrice;
    _productCodeTEController.text = widget.product.productCode;
    _quantityTEController.text = widget.product.quantity;
    _totalPriceTEController.text = widget.product.totalPrice;
    _imageTEController.text = widget.product.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Product"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameTEController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      hintText: "Name", labelText: "Name"),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write your product name";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _productCodeTEController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      hintText: "Product Code", labelText: "Product Code"),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write your product code";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _unitPriceTEController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Unit Price", labelText: "Unit Price"),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write your unit price";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _quantityTEController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Quantity", labelText: "Quantity"),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write your quantity";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _totalPriceTEController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Total Price", labelText: "Total Price"),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write your total price";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _imageTEController,
                  decoration: const InputDecoration(
                      hintText: "Image", labelText: "Image"),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write your image url";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: _updateProductInprogress == false,
                  replacement: const Center(
                      child: CircularProgressIndicator()
                  ),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _updateProduct();
                        }
                      },
                      child: const Text('Add')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProduct() async {
    _updateProductInprogress = true;
    setState(() {});

    Map<String, String> inputData = {
      "Img": _imageTEController.text,
      "ProductCode": _productCodeTEController.text,
      "ProductName": _nameTEController.text,
      "Qty": _quantityTEController.text,
      "TotalPrice": _totalPriceTEController.text,
      "UnitPrice": _unitPriceTEController.text
    };

    String updateProductUrl =
        "https://crud.teamrabbil.com/api/v1/UpdateProduct/${widget.product.id}";
    Uri uri = Uri.parse(updateProductUrl);
    Response response = await post(uri,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(inputData));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product updated")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Update product failed. Try again!",
          style: TextStyle(color: Colors.red),
        ),
      ));
    }

    _updateProductInprogress = false;
  }

  @override
  void dispose() {
    _nameTEController.dispose();
    _unitPriceTEController.dispose();
    _quantityTEController.dispose();
    _totalPriceTEController.dispose();
    _imageTEController.dispose();
    super.dispose();
  }
}
