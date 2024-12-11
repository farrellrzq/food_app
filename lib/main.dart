import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Ordering App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainMenuScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/ss.png', height: 200), // Splash screen image
            SizedBox(height: 20),
            Text(
              "burgerQueen",
              style: TextStyle(
                color: Colors.black,
                fontSize: 55,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final int price;
  final String image;
  int quantity;

  Item({required this.name, required this.price, required this.image, this.quantity = 1});
}

class Order {
  final List<Item> items;
  final int total;

  Order({required this.items, required this.total});
}

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final List<Item> foodItems = [
    Item(name: 'Burger Medium', price: 30000, image: 'assets/burger.png'),
    Item(name: 'French fries', price: 12000, image: 'assets/kentang.png'),
    Item(name: 'Chicken nugget', price: 17000, image: 'assets/nugget.png'),
    Item(name: 'Spaghetti', price: 20000, image: 'assets/spag.png'),
  ];

  final List<Item> drinkItems = [
    Item(name: 'Teh Botol', price: 5000, image: 'assets/teh_botol.png'),
    Item(name: 'Cappucino', price: 25000, image: 'assets/cappucino.png'),
    Item(name: 'Americano', price: 18000, image: 'assets/americano.png'),
    Item(name: 'Iced Lemon Tea', price: 10000, image: 'assets/tea.png'),
  ];

  final List<Item> cartItems = [];
  final List<Order> orderHistory = [];

  String selectedCategory = 'All';

  void _addToCart(Item item) {
    setState(() {
      final existingItem = cartItems.firstWhere(
        (cartItem) => cartItem.name == item.name,
        orElse: () => Item(name: '', price: 0, image: ''),
      );
      if (existingItem.name.isEmpty) {
        cartItems.add(Item(name: item.name, price: item.price, image: item.image));
      } else {
        existingItem.quantity++;
      }
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: cartItems,
          onCheckout: _checkout,
        ),
      ),
    );
  }

  void _navigateToOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(orderHistory: orderHistory),
      ),
    );
  }

  void _checkout() {
    final total = cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
    orderHistory.add(Order(items: List.from(cartItems), total: total));
    cartItems.clear();
    setState(() {});
    Navigator.pop(context); // Close cart screen after checkout
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          onSubmit: (name, price, image) {
            setState(() {
              foodItems.add(Item(name: name, price: price, image: image));
            });
          },
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, height: 100, fit: BoxFit.cover);
    } else {
      return Image.file(File(imagePath), height: 100, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Item> displayedItems = selectedCategory == 'Food'
        ? foodItems
        : selectedCategory == 'Drink'
            ? drinkItems
            : [...foodItems, ...drinkItems];

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddProduct,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryButton('All', Icons.fastfood),
                SizedBox(width: 10),
                _buildCategoryButton('Food', Icons.lunch_dining),
                SizedBox(width: 10),
                _buildCategoryButton('Drink', Icons.local_drink),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
              ),
              itemCount: displayedItems.length,
              itemBuilder: (context, index) {
                final item = displayedItems[index];
                return Card(
                  child: Column(
                    children: [
                      _buildImage(item.image),
                      Text(item.name),
                      Text('Rp. ${item.price}'),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.lightBlue),
                        onPressed: () => _addToCart(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 1) _navigateToCart();
          if (index == 2) _navigateToOrderHistory();
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Order History'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, IconData icon) {
    bool isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<Item> cartItems;
  final VoidCallback onCheckout;

  CartScreen({required this.cartItems, required this.onCheckout});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _incrementQuantity(Item item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decrementQuantity(Item item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      }
    });
  }

  void _removeItem(Item item) {
    setState(() {
      widget.cartItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cartItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return ListTile(
                  leading: _buildImage(item.image),
                  title: Text(item.name),
                  subtitle: Text('Rp. ${item.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _decrementQuantity(item),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _incrementQuantity(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                Text('Total: Rp. $total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: widget.onCheckout,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 247, 247), backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Checkout',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, height: 50, width: 50, fit: BoxFit.cover);
    } else {
      return Image.file(File(imagePath), height: 50, width: 50, fit: BoxFit.cover);
    }
  }
}

class OrderHistoryScreen extends StatelessWidget {
  final List<Order> orderHistory;

  OrderHistoryScreen({required this.orderHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: ListView.builder(
        itemCount: orderHistory.length,
        itemBuilder: (context, index) {
          final order = orderHistory[index];
          return ListTile(
            title: Text('Order ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.map((item) {
                return Text('${item.name} x${item.quantity}');
              }).toList(),
            ),
            trailing: Text('Rp. ${order.total}'),
          );
        },
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final Function(String, int, String) onSubmit;

  AddProductScreen({required this.onSubmit});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: selectedImage == null
                    ? Center(child: Text('Pilih Gambar'))
                    : Image.file(selectedImage!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final price = int.tryParse(priceController.text) ?? 0;
                final image = selectedImage?.path ?? '';
                widget.onSubmit(name, price, image);
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
