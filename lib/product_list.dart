import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_form.dart';
import 'contact.dart';
import 'login.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String? specialOffer;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.specialOffer,
  });
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [
    Product(
      id: '1',
      name: 'Black Forest',
      description: 'Kue coklat dengan cherry dan whipped cream',
      price: 150000,
      imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587',
      category: 'Kue Tart',
    ),
    Product(
      id: '2',
      name: 'Red Velvet',
      description: 'Kue merah lembut dengan cream cheese frosting',
      price: 180000,
      imageUrl: 'https://images.unsplash.com/photo-1614707267537-b85aaf00c4b7',
      category: 'Kue Tart',
    ),
    Product(
      id: '3',
      name: 'Tiramisu',
      description: 'Kue Italia dengan kopi dan mascarpone',
      price: 200000,
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9',
      category: 'Kue Tart',
    ),
    Product(
      id: '4',
      name: 'Cheesecake',
      description: 'Kue keju lembut dengan berbagai topping',
      price: 175000,
      imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e',
      category: 'Kue Tart',
    ),
    Product(
      id: '5',
      name: 'Chocolate Lava',
      description: 'Kue coklat dengan lelehan coklat di dalamnya',
      price: 120000,
      imageUrl: 'https://images.unsplash.com/photo-1624353365286-3f8d62dadadf',
      category: 'Kue Kecil',
    ),
    Product(
      id: '6',
      name: 'Mille Crepe',
      description: 'Kue lapis dengan banyak layer crepe',
      price: 220000,
      imageUrl: 'https://images.unsplash.com/photo-1559620192-032c64bc86af',
      category: 'Kue Tart',
    ),
  ];

  int _selectedIndex = 0;
  String? userName;
  String _searchText = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Kue Tart',
    'Kue Kecil',
    'Snack',
    'Hampers',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('current_user_name') ?? 'Pelanggan';
    });
  }

  List<Product> get _filteredProducts {
    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchText.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Semua' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _navigateToOrder(Product product) {
    final Map<String, dynamic> productData = {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'category': product.category,
      'specialOffer': product.specialOffer,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderFormPage(productData: productData),
      ),
    );
  }

  void _showProductDetail(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          product.name,
          style: const TextStyle(
            color: Color(0xFFFF6B9D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFFFFF8F0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B9D),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.cake_rounded,
                          size: 80,
                          color: const Color(0xFFFF6B9D).withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (product.specialOffer != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF6B9D),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    product.specialOffer!,
                    style: const TextStyle(
                      color: Color(0xFFFF6B9D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              Text(
                product.description,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 18,
                    color: Color(0xFFFF6B9D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B9D),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToOrder(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFFF8F0),
                  border: Border.all(
                    color: const Color(0xFFFF6B9D).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B9D),
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.cake_rounded,
                          size: 40,
                          color: const Color(0xFFFF6B9D).withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (product.specialOffer != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFF6B9D),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.specialOffer!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF6B9D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B9D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    if (_selectedIndex == index) return;

    if (index == 0) {
      return;
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OrderFormPage()),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ContactPage()),
        (route) => false,
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout', style: TextStyle(color: Color(0xFF212121))),
        content: const Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('current_user_email');
      await prefs.remove('current_user_name');
      await prefs.remove('current_user_phone');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B9D), Color.fromARGB(255, 240, 159, 210)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RasaRia Products',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              '${_filteredProducts.length} Produk Tersedia',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari kue favorit Anda...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B9D)),
                filled: true,
                fillColor: const Color(0xFFFFF8F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF6B9D),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedCategory == category
                                  ? Colors.white
                                  : const Color(0xFF424242),
                            ),
                          ),
                          selected: _selectedCategory == category,
                          selectedColor: const Color(0xFFFF6B9D),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: const Color(0xFFFFF8F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedCategory == category
                                  ? const Color(0xFFFF6B9D)
                                  : const Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          elevation: _selectedCategory == category ? 2 : 0,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cake_rounded,
                          size: 80,
                          color: const Color(0xFFFF6B9D).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildProductItem(_filteredProducts[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateToPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFF6B9D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pesan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Kontak'),
        ],
      ),
    );
  }
}
