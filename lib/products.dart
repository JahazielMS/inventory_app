import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final baseUrl = dotenv.get("BASE_URL");
    try {
      final dio = Dio();
      final response = await dio.get('$baseUrl/products');
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Products: ${response.data}');
      }

      if (response.data['ok'] == true) {
        setState(() {
          _products = response.data['products'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar los productos';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching products: $e');
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono del producto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.shopping_bag, color: Colors.blue.shade700, size: 30),
            ),
            const SizedBox(width: 16),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Sin nombre',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price'] ?? '0.00'}',
                    style: TextStyle(fontSize: 16, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Stock y badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _getStockColor(product['stock'] ?? 0), borderRadius: BorderRadius.circular(20)),
              child: Text(
                'Stock: ${product['stock'] ?? 0}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas en desktop/tablet
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8, // Proporción de las tarjetas
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildGridProductCard(product);
      },
    );
  }

  Widget _buildGridProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen/Icono del producto
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Icon(Icons.shopping_bag, color: Colors.blue.shade700, size: 50),
          ),

          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Sin nombre',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product['price'] ?? '0.00'}',
                  style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: _getStockColor(product['stock'] ?? 0), size: 16),
                    const SizedBox(width: 4),
                    Text('${product['stock'] ?? 0} disponibles', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock > 10) return Colors.green;
    if (stock > 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Cargando productos...')]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _fetchProducts, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay productos disponibles', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Catálogo de Productos'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchProducts)],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : _products.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                // Diseño responsivo basado en el ancho de pantalla
                if (constraints.maxWidth < 600) {
                  // Mobile - Lista vertical
                  return ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  );
                } else if (constraints.maxWidth < 1200) {
                  // Tablet - Grid de 2 columnas
                  return _buildProductGrid();
                } else {
                  // Desktop - Grid de 3 columnas
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildGridProductCard(product);
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: _fetchProducts, tooltip: 'Actualizar productos', child: const Icon(Icons.refresh)),
    );
  }
}
