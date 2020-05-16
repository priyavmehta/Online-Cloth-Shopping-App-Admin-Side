import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:priyav_mart_admin/provider/products_provider.dart';
import '../database/category.dart';
import '../database/brand.dart';
import '../database/products.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

class AddProducts extends StatefulWidget {
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {

  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;

  CategoryService categoryService = CategoryService();
  BrandService brandService = BrandService();
  ProductService _productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = new TextEditingController();
  TextEditingController quantityController = new TextEditingController();
  TextEditingController priceController = new TextEditingController(); 
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategeory ="test";
  String _currentBrand;
  List<String> selectedsizes = <String>[];
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;
  List<String> colors = <String>[];
  bool onSale = false;
  bool featured = false;

  @override
  void initState() {
    _getCategories();
    _getBrands();
  }

  List<DropdownMenuItem<String>> getCategoriesDropDown(){
    List<DropdownMenuItem<String>> items = new List();
    for(DocumentSnapshot category in categories){
      items.add(
        new DropdownMenuItem(
          child: Text(category['category']),
          value: category['category'],
        )
      );
    }
    return items;
  }

  _getCategories() async{
    List<DocumentSnapshot> data = await categoryService.getCategories();
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropDown();
      _currentCategeory = categoriesDropDown[0].value;
    });
  }

  List<DropdownMenuItem<String>> getBrandsDropDown(){
    List<DropdownMenuItem<String>> items = new List();
    for(DocumentSnapshot brand in brands){
      items.add(
        new DropdownMenuItem(
          child: Text(brand['brand']),
          value: brand['brand'],
        )
      );
    }
    return items;
  }

  _getBrands() async{
    List<DocumentSnapshot> data = await brandService.getBrands();
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand= brandsDropDown[0].value;
    });
  }

  changeSelectedCategory(String selectedCategory){
    setState(() {
      _currentCategeory = selectedCategory;
    });
  }

  changeSelectedBrand(String selectedBrand){
    setState(() {
      _currentBrand = selectedBrand;
    });
  }

  void changeSelectedSize(String size){
    if(selectedsizes.contains(size)){
      setState(() {
        selectedsizes.remove(size);
      });
    }else{
      setState(() {
        selectedsizes.insert(0, size);
      });
    }
  }

  void _selectImage(Future<File> pickImage,int imageNumber) async{
    File tempImg = await pickImage;
    switch(imageNumber){
      case 1: setState(() => _image1 = tempImg);
      break;
      case 2: setState(() => _image2 = tempImg);
      break;
      case 3: setState(() => _image3 = tempImg);
      break;
    }
  }

  Widget _displayChild1(){
    if(_image1 == null) {
      return  Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: Icon(Icons.add,color: grey,),
      );
    }
    else{
      return Image.file(_image1,fit: BoxFit.fill,width: double.infinity,);
    }
  }

  Widget _displayChild2(){
    if(_image2 == null) {
      return  Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: Icon(Icons.add,color: grey,),
      );
    }
    else{
      return Image.file(_image2,fit: BoxFit.fill,width: double.infinity,);
    }
  }

  Widget _displayChild3(){
    if(_image3 == null) {
      return  Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: Icon(Icons.add,color: grey,),
      );
    }
    else{
      return Image.file(_image3,fit: BoxFit.fill,width: double.infinity,);
    }
  }

  void validateAndUpload() async{
    if(_formKey.currentState.validate()){
      setState(() => isLoading = true);
      if(_image1 != null && _image2 != null && _image3 != null){
        if(selectedsizes.isNotEmpty){

          String imageUrl1;
          String imageUrl2;
          String imageUrl3;

          final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

          final String picture1 = "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task1 = firebaseStorage.ref().child(picture1).putFile(_image1);
          // final String picture2 = "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          // StorageUploadTask task2 = firebaseStorage.ref().child(picture2).putFile(_image2);
          // final String picture3 = "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          // StorageUploadTask task3 = firebaseStorage.ref().child(picture3).putFile(_image3);

          // StorageTaskSnapshot snapshot1 = await task1.onComplete.then((snapshot) => snapshot);
          // StorageTaskSnapshot snapshot2 = await task2.onComplete.then((snapshot) => snapshot);
          
          task1.onComplete.then((snapshot1) async{
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            // imageUrl2 = await snapshot2.ref.getDownloadURL();
            // imageUrl3 = await snapshot3.ref.getDownloadURL();
            //List<String> imageList = [imageUrl1,imageUrl2,imageUrl3];

            _productService.uploadProducts(
              productName: productNameController.text,
              price: double.parse(priceController.text),
              sizes: selectedsizes,
              colors: colors,
              sale: onSale,
              featured: featured,
              images: imageUrl1,
              brand: _currentBrand,
              category: _currentCategeory,
              quantity: int.parse(quantityController.text)
            );
            _formKey.currentState.reset();
            setState(() => isLoading = false);
            Fluttertoast.showToast(msg: "Product Uploaded");
            Navigator.pop(context);
          });

        }else{
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: "Select at least any one size");
        }
      }else{
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: "All 3 images must be provided");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: Text(
          "Add Product",
          style: TextStyle(color: black),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: (){
            Navigator.pop(context);
          },
          color: black,
        //  Icons.close, color: black,
        ),
      ),
      body: Form(
        key: _formKey,
        child: isLoading ? CircularProgressIndicator() : ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlineButton(
                      onPressed: (){
                        _selectImage(ImagePicker.pickImage(source: ImageSource.gallery),1);
                      },
                      borderSide: BorderSide(color: grey.withOpacity(0.5),width: 2.5),
                      child: _displayChild1()
                    ),
                  )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlineButton(
                      onPressed: (){
                        _selectImage(ImagePicker.pickImage(source: ImageSource.gallery),2);
                      },
                      borderSide: BorderSide(color: grey.withOpacity(0.5),width: 2.5),
                      child: _displayChild2()
                    ),
                  )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlineButton(
                      onPressed: (){
                        _selectImage(ImagePicker.pickImage(source: ImageSource.gallery),3);
                      },
                      borderSide: BorderSide(color: grey.withOpacity(0.5),width: 2.5),
                      child: _displayChild3()
                    ),
                  )
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Enter product name with maximum length of 10 characters",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.0
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Text('Available Colors',textAlign: TextAlign.center,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      if(productProvider.selectedColors.contains('red')){
                        productProvider.removeColor('red');
                      }else{
                        productProvider.addColors('red');

                      }
                      setState(() {
                        colors = productProvider.selectedColors;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: productProvider.selectedColors.contains('red') ? Colors.red : grey,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      if(productProvider.selectedColors.contains('yellow')){
                        productProvider.removeColor('yellow');
                      }else{
                        productProvider.addColors('yellow');

                      }
                      setState(() {
                        colors = productProvider.selectedColors;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: productProvider.selectedColors.contains('yellow') ? Colors.red : grey,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      if(productProvider.selectedColors.contains('blue')){
                        productProvider.removeColor('blue');
                      }else{
                        productProvider.addColors('blue');

                      }
                      setState(() {
                        colors = productProvider.selectedColors;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: productProvider.selectedColors.contains('blue') ? Colors.red : grey,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      if(productProvider.selectedColors.contains('green')){
                        productProvider.removeColor('green');
                      }else{
                        productProvider.addColors('green');

                      }
                      setState(() {
                        colors = productProvider.selectedColors;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: productProvider.selectedColors.contains('green') ? Colors.red : grey,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      if(productProvider.selectedColors.contains('white')){
                        productProvider.removeColor('white');
                      }else{
                        productProvider.addColors('white');

                      }
                      setState(() {
                        colors = productProvider.selectedColors;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: productProvider.selectedColors.contains('white') ? Colors.red : grey,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      if(productProvider.selectedColors.contains('black')){
                        productProvider.removeColor('black');
                      }else{
                        productProvider.addColors('black');

                      }
                      setState(() {
                        colors = productProvider.selectedColors;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: productProvider.selectedColors.contains('black') ? Colors.red : grey,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Sale'),
                    SizedBox(width: 10,),
                    Switch(value: onSale, onChanged: (value){
                      setState(() {
                        onSale = value;
                      });
                    }),
                  ],
                ),

                Row(
                  children: <Widget>[
                    Text('Featured'),
                    SizedBox(width: 10,),
                    Switch(value: featured, onChanged: (value){
                      setState(() {
                        featured = value;
                      });
                    }),
                  ],
                ),

              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: productNameController,
                decoration: InputDecoration(
                  hintText: "Product Name"
                ),
                validator: (value){
                  if(value.isEmpty){
                    return "You must enter name of Product";
                  }else if(value.length > 10){
                    return "Product name can't be longer than 10 letters";
                  }
                },
              ),
            ),
            
            // select category
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Category",style: TextStyle(color: Colors.red),),
                ),
                DropdownButton(
                  value: _currentCategeory,
                  items: categoriesDropDown,
                  onChanged: changeSelectedCategory
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Brand",style: TextStyle(color: Colors.red),),
                ),
                DropdownButton(
                  value: _currentBrand,
                  items: brandsDropDown,
                  onChanged: changeSelectedBrand
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: "Enter Quantity"
                ),
                validator: (value){
                  if(value.isEmpty){
                    return "You must enter name of Product";
                  }
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  hintText: "Enter Price"
                ),
                validator: (value){
                  if(value.isEmpty){
                    return "You must enter price of Product";
                  }
                },
              ),
            ),

            Text('Avaailable Sizes', textAlign: TextAlign.center,),

            Row(
              
              children: <Widget>[
                Checkbox(value: selectedsizes.contains('XS'), onChanged: (value) => changeSelectedSize('XS'),),
                Text('XS'),

                Checkbox(value: selectedsizes.contains('S'), onChanged: (value) => changeSelectedSize('S'),),
                Text('S'),

                Checkbox(value: selectedsizes.contains('M'), onChanged: (value) => changeSelectedSize('M'),),
                Text('M'),

                Checkbox(value: selectedsizes.contains('L'), onChanged: (value) => changeSelectedSize('L'),),
                Text('L'),

                Checkbox(value: selectedsizes.contains('XL'), onChanged: (value) => changeSelectedSize('XL'),),
                Text('XL'),
              ],
            ),

            Row(
              children: <Widget>[
                Checkbox(value: selectedsizes.contains('28'), onChanged: (value) => changeSelectedSize('28'),),
                Text('28'),

                Checkbox(value: selectedsizes.contains('30'), onChanged: (value) => changeSelectedSize('30'),),
                Text('30'),

                Checkbox(value: selectedsizes.contains('32'), onChanged: (value) => changeSelectedSize('32'),),
                Text('32'),

                Checkbox(value: selectedsizes.contains('34'), onChanged: (value) => changeSelectedSize('34'),),
                Text('34'),

                Checkbox(value: selectedsizes.contains('36'), onChanged: (value) => changeSelectedSize('36'),),
                Text('36'),
              ],
            ),

            Row(
              children: <Widget>[

                Checkbox(value: selectedsizes.contains('38'), onChanged: (value) => changeSelectedSize('38'),),
                Text('38'),

                Checkbox(value: selectedsizes.contains('40'), onChanged: (value) => changeSelectedSize('40'),),
                Text('40'),

                Checkbox(value: selectedsizes.contains('42'), onChanged: (value) => changeSelectedSize('42'),),
                Text('42'),

                Checkbox(value: selectedsizes.contains('44'), onChanged: (value) => changeSelectedSize('44'),),
                Text('44'),

                Checkbox(value: selectedsizes.contains('46'), onChanged: (value) => changeSelectedSize('46'),),
                Text('46'),

              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FlatButton(
                color: Colors.red,
                textColor: white,
                child: Text('Add product'),
                onPressed: (){
                  validateAndUpload();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}