import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wp_b2b/constants.dart';
import 'package:wp_b2b/models/doc_order_customer.dart';
import 'package:wp_b2b/models/doc_order_movement.dart';
import 'package:wp_b2b/models/ref_product.dart';
import 'package:wp_b2b/system.dart';

Widget spaceBetweenColumn() {
  return SizedBox(width: 5);
}

Widget spaceBetweenHeaderColumn() {
  return SizedBox(width: 8);
}

Widget spaceVertBetweenHeaderColumn() {
  return SizedBox(height: 8);
}

class CountWindow extends StatefulWidget {
  final OrderCustomer? orderCustomer;
  final OrderMovement? orderMovement;
  final Product product;
  final ProductCharacteristic productCharacteristic;
  final double countOnWarehouse;
  final double price;

  const CountWindow(
      {Key? key,
        this.orderCustomer,
        this.orderMovement,
        required this.product,
        required this.productCharacteristic,
        required this.countOnWarehouse,
        required this.price})
      : super(key: key);

  @override
  State<CountWindow> createState() => _CountWindowState();
}

class _CountWindowState extends State<CountWindow> {
  TextEditingController textFieldProductController = TextEditingController();
  TextEditingController textFieldProductCharacteristicController = TextEditingController();
  TextEditingController textFieldPriceController = TextEditingController();
  TextEditingController textFieldCountController = TextEditingController();

  @override
  void initState() {
    _loadData();

    textFieldCountController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textFieldCountController.text.length,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 252,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            width: 350,
            child: Text('Назва товару'),
          ),
          SizedBox(
            height: 40,
            width: 350,
            child: TextField(
              style: TextStyle(fontSize: 14),
              readOnly: true,
              controller: textFieldProductController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                fillColor: bgColor,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          ),
          spaceVertBetweenHeaderColumn(),
          SizedBox(
            height: 20,
            width: 350,
            child: Text('Характеристика товару'),
          ),
          SizedBox(
            height: 40,
            width: 350,
            child: TextField(
              style: TextStyle(fontSize: 14),
              readOnly: true,
              controller: textFieldProductCharacteristicController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                fillColor: bgColor,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          ),
          spaceVertBetweenHeaderColumn(),
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 170,
                child: Text('Ціна'),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              SizedBox(
                height: 20,
                width: 170,
                child: Text('Кількість'),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: TextField(
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  controller: textFieldPriceController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                    fillColor: bgColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              SizedBox(
                height: 40,
                width: 170,
                child: TextField(
                  onSubmitted: (value) async {
                    await _addToDocument();
                    Navigator.of(context).pop(false);
                  },
                  style: TextStyle(fontSize: 14),
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: textFieldCountController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 24, 10, 0),
                    fillColor: bgColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              )
            ],
          ),
          spaceVertBetweenHeaderColumn(),
          spaceVertBetweenHeaderColumn(),
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                    onPressed: () async {
                      await _addToDocument();
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Додати')),
              ),
              spaceBetweenColumn(),
              spaceBetweenColumn(),
              SizedBox(
                height: 40,
                width: 170,
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Відміна')),
              )
            ],
          ),
        ],
      ),
    );
  }

  _loadData() {
    textFieldProductController.text = widget.product.name;
    textFieldProductCharacteristicController.text = widget.productCharacteristic.name;
    textFieldPriceController.text = doubleToString(widget.price);

    // Найдем индекс строки товара в документе по товару который добавляем
    var indexItem = widget.orderCustomer?.itemsOrderCustomer.indexWhere(
            (element) => element.uid == widget.product.uid && element.uidCharacteristic == widget.productCharacteristic.uid) ??
        -1;

    // Если нашли товар в списке документа
    double count = 0;
    if (indexItem >= 0) {
      var itemList = widget.orderCustomer?.itemsOrderCustomer[indexItem];
      count = itemList?.count ?? 0 + 1;
    } else {
      count = 1;
    }

    textFieldCountController.text = doubleToString(count);
  }

  _addToDocument() {

    double count = 0;
    try {
      count = double.parse(textFieldCountController.text);
    } on Error catch (e) {
      showErrorMessage(e.toString(), context);
    }

    String uidUnit = widget.product.uidUnit;
    String nameUnit = widget.product.nameUnit;
    double price = widget.price;
    double discount = 0.0;
    double sum = price * count;

    // Найдем индекс строки товара в документе по товару который добавляем
    var indexItem = widget.orderCustomer?.itemsOrderCustomer.indexWhere(
            (element) => element.uid == widget.product.uid && element.uidCharacteristic == widget.productCharacteristic.uid) ??
        -1;

    // Если нашли товар в списке документа
    if (indexItem >= 0) {
      var itemList = widget.orderCustomer?.itemsOrderCustomer[indexItem];
      itemList?.price = price;
      itemList?.count = count;
      itemList?.discount = discount;
      itemList?.sum = count * price;
    } else {
      var countElements = widget.orderCustomer?.itemsOrderCustomer.length ?? 0;

      ItemOrderCustomer itemOrderCustomer = ItemOrderCustomer(
          uidOrderCustomer: widget.orderCustomer?.uid ?? '',
          numberRow: countElements + 1,
          uid: widget.product.uid,
          name: widget.product.name,
          uidCharacteristic: widget.productCharacteristic.uid,
          nameCharacteristic: widget.productCharacteristic.name,
          uidUnit: uidUnit,
          nameUnit: nameUnit,
          count: count,
          price: price,
          discount: discount,
          sum: sum);

      widget.orderCustomer?.itemsOrderCustomer.add(itemOrderCustomer);
    }
    showMessage('В документ додано товар: ' + widget.product.name, context);

    setState(() {});
  }
}
