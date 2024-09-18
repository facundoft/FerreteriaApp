import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Services/Database.dart';
import 'carrito_user.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  int _stockQuantity = 1;
  late ProductsRepository _productsRepository;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _productsRepository = ProductsRepository(Supabase.instance.client);
  }

  void _increaseStock() {
    setState(() {
      _stockQuantity++;
    });
  }

  void _decreaseStock() {
    setState(() {
      if (_stockQuantity > 1) {
        _stockQuantity--;
      }
    });
  }

  void _addToCart() async {
    int? id;
    final user = Supabase.instance.client.auth.currentUser;
    final client = Supabase.instance.client;
    final _clientRepository = ProductsRepository(client);

    if (user != null && user.userMetadata != null) {
      final userEmail = user.userMetadata?['email'];

      if (userEmail != null) {

        id = await _clientRepository.getUserIdByEmail(userEmail);
      }
    }

    if (id == null) {


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el producto al carrito: ID de usuario no disponible')),
      );
      return;
    }

    try {
      await _productsRepository.addProductToCart(id, _product.id, _stockQuantity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto añadido al carrito')),
      );
    } catch (e) {
      print('\n Error al añadir al carrito: $e \n');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Ferretería'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // Ruta de la imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          // Contenido encima de la imagen de fondo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [

                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            _product.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _product.name,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Precio: \$${_product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Descripción: ${_product.description}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.white),
                        onPressed: _decreaseStock,
                      ),
                      Text(
                        '$_stockQuantity',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: _increaseStock,
                      ),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: _addToCart,
                        child: Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }






}
