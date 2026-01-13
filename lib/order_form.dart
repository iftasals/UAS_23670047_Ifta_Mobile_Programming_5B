import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_list.dart';
import 'contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderFormPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final String currentUser; // Tambahkan parameter untuk user saat ini

  const OrderFormPage({
    Key? key,
    this.productData,
    required this.currentUser, // Wajib ada current user
  }) : super(key: key);

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Map<String, dynamic>? _selectedProduct;
  DateTime _selectedDate = DateTime.now();
  String? _selectedPayment;
  bool _isLoading = false;
  int _selectedIndex = 1;
  String _storedUserName = '';
  bool _isEditing = false;
  String? _editingOrderId;

  // Daftar pesanan lokal (untuk simulasi jika API tidak berfungsi)
  List<Map<String, dynamic>> _localOrders = [];

  final List<Map<String, dynamic>> _products = [
    {'id': '1', 'name': 'Black Forest', 'price': 150000.0},
    {'id': '2', 'name': 'Red Velvet', 'price': 180000.0},
    {'id': '3', 'name': 'Tiramisu', 'price': 200000.0},
    {'id': '4', 'name': 'Cheesecake', 'price': 175000.0},
    {'id': '5', 'name': 'Chocolate Lava', 'price': 120000.0},
    {'id': '6', 'name': 'Mille Crepe', 'price': 220000.0},
  ];

  List<String> paymentMethods = [
    'Transfer Bank',
    'Cash on Delivery',
    'E-Wallet',
    'Kartu Kredit',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1'; // Set default value

    // PERBAIKAN: Inisialisasi _selectedProduct dari widget.productData
    if (widget.productData != null) {
      final productName = widget.productData!['name'];
      _selectedProduct = _products.firstWhere(
        (p) => p['name'] == productName,
        orElse: () => _products[0],
      );
    }

    // Ambil nama dari SharedPreferences
    _loadUserName();

    // Load data pesanan lokal
    _loadLocalOrders();
  }

  // Fungsi untuk memuat nama pengguna dari SharedPreferences
  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('user_name');

      if (storedName != null && storedName.isNotEmpty) {
        setState(() {
          _storedUserName = storedName;
          _nameController.text = storedName;
        });
      } else if (widget.currentUser.isNotEmpty) {
        // Jika tidak ada di SharedPreferences, gunakan currentUser
        // Cek jika bukan "Budi" atau "Sari"
        if (widget.currentUser.toLowerCase() != 'budi' &&
            widget.currentUser.toLowerCase() != 'sari') {
          setState(() {
            _storedUserName = widget.currentUser;
            _nameController.text = widget.currentUser;
          });
        }
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  // Fungsi untuk menyimpan nama ke SharedPreferences
  Future<void> _saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      setState(() {
        _storedUserName = name;
      });
    } catch (e) {
      print('Error saving user name: $e');
    }
  }

  // Fungsi untuk memuat pesanan dari shared preferences
  Future<void> _loadLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('local_orders');
      if (ordersJson != null) {
        final List<dynamic> ordersList = json.decode(ordersJson);
        setState(() {
          _localOrders = ordersList.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Error loading local orders: $e');
    }
  }

  // Fungsi untuk menyimpan pesanan ke shared preferences
  Future<void> _saveLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = json.encode(_localOrders);
      await prefs.setString('local_orders', ordersJson);
    } catch (e) {
      print('Error saving local orders: $e');
    }
  }

  // Fungsi untuk mendapatkan pesanan pengguna saat ini
  List<Map<String, dynamic>> _getUserOrders() {
    return _localOrders.where((order) {
      // Filter berdasarkan nama pengguna
      final customerName =
          order['customerName']?.toString().toLowerCase() ?? '';
      final currentName = _nameController.text.trim().toLowerCase();

      // Gunakan nama dari form sebagai filter
      return customerName == currentName;
    }).toList();
  }

  double get totalPrice {
    if (_selectedProduct == null) return 0;
    int quantity = int.tryParse(_quantityController.text) ?? 1;
    double price = (_selectedProduct!['price'] as num).toDouble();
    return price * quantity;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Fungsi untuk reset semua field form
  void _resetForm() {
    setState(() {
      _selectedProduct = null;
      _selectedPayment = null;
      _selectedDate = DateTime.now();
      _quantityController.text = '1';
      _isEditing = false;
      _editingOrderId = null;

      // Kembalikan ke nama yang disimpan
      _nameController.text = _storedUserName;

      _phoneController.clear();
      _addressController.clear();
      _notesController.clear();

      // Reset form validation
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
        // Set nilai kembali untuk quantity
        _quantityController.text = '1';
      }
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data dengan benar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi: Hindari nama "Budi" dan "Sari"
    final customerName = _nameController.text.trim().toLowerCase();
    if (customerName == 'budi' || customerName == 'sari') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama "Budi" dan "Sari" tidak diperbolehkan untuk pemesanan',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simpan nama ke SharedPreferences
    await _saveUserName(_nameController.text.trim());

    setState(() => _isLoading = true);

    final orderId = _isEditing && _editingOrderId != null
        ? _editingOrderId!
        : DateTime.now().millisecondsSinceEpoch.toString();

    final orderData = {
      'id': orderId,
      'productId': _selectedProduct!['id'],
      'productName': _selectedProduct!['name'],
      'customerName': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'quantity': _quantityController.text,
      'totalPrice': totalPrice.toStringAsFixed(0),
      'deliveryDate': _selectedDate.toIso8601String(),
      'paymentMethod': _selectedPayment!,
      'notes': _notesController.text,
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // Simulasi API call
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (_isEditing) {
          // Update pesanan yang sudah ada
          final index = _localOrders.indexWhere(
            (order) => order['id'] == orderId,
          );
          if (index != -1) {
            _localOrders[index] = orderData;
          }
        } else {
          // Tambah pesanan baru
          _localOrders.add(orderData);
        }
        await _saveLocalOrders();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Pesanan ${_selectedProduct!['name']} berhasil diperbarui!'
                  : 'Pesanan ${_selectedProduct!['name']} berhasil!',
            ),
            backgroundColor: const Color(0xFFB5E7A0),
          ),
        );

        // Reset form setelah submit
        _resetForm();
      } else {
        throw Exception('Gagal mengirim pesanan');
      }
    } catch (e) {
      // Jika API gagal, simpan ke local storage
      print('API Error: $e');

      if (_isEditing) {
        // Update pesanan yang sudah ada
        final index = _localOrders.indexWhere(
          (order) => order['id'] == orderId,
        );
        if (index != -1) {
          _localOrders[index] = orderData;
        }
      } else {
        // Tambah pesanan baru
        _localOrders.add(orderData);
      }
      await _saveLocalOrders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Pesanan berhasil diperbarui (disimpan lokal): ${_selectedProduct!['name']}'
                : 'Pesanan berhasil (disimpan lokal): ${_selectedProduct!['name']}',
          ),
          backgroundColor: const Color(0xFFB5E7A0),
        ),
      );

      // Reset form setelah submit
      _resetForm();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk menghapus pesanan (CRUD - Delete)
  Future<void> _deleteOrder(String orderId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _localOrders.removeWhere((order) => order['id'] == orderId);
              });
              await _saveLocalOrders();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengedit pesanan (CRUD - Update)
  void _editOrder(Map<String, dynamic> order) {
    setState(() {
      _isEditing = true;
      _editingOrderId = order['id'];
      _selectedProduct = _products.firstWhere(
        (p) => p['id'] == order['productId'],
        orElse: () => _products[0],
      );
      _nameController.text = order['customerName'];
      _phoneController.text = order['phone'];
      _addressController.text = order['address'];
      _quantityController.text = order['quantity'];
      _selectedPayment = order['paymentMethod'];
      _selectedDate = DateTime.parse(order['deliveryDate']);
      _notesController.text = order['notes'];
    });

    // Scroll ke atas form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Fungsi untuk melihat detail pesanan (CRUD - Read)
  void _viewOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Pesanan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Produk', order['productName']),
              _buildDetailItem('Pelanggan', order['customerName']),
              _buildDetailItem('Telepon', order['phone']),
              _buildDetailItem('Alamat', order['address']),
              _buildDetailItem('Jumlah', '${order['quantity']} pcs'),
              _buildDetailItem('Total Harga', 'Rp ${order['totalPrice']}'),
              _buildDetailItem('Metode Bayar', order['paymentMethod']),
              _buildDetailItem(
                'Tanggal Kirim',
                order['deliveryDate'].split('T')[0],
              ),
              _buildDetailItem('Catatan', order['notes']),
              _buildDetailItem('Status', order['status']),
              _buildDetailItem('Dibuat', order['createdAt'].split('T')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editOrder(order);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProductListPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContactPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userOrders = _getUserOrders();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan teks putih
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFFB6C1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cake,
                      size: 40,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Form Pemesanan Kue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Selamat datang, ${_storedUserName.isNotEmpty ? _storedUserName : widget.currentUser}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Pesanan
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildOrderForm(),

                    // Tampilkan pesanan pengguna saat ini DI BAWAH FORM
                    if (userOrders.isNotEmpty) _buildUserOrders(userOrders),

                    // Tambah spacer di bawah
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildOrderForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Reset Form dan Status Edit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isEditing) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 14, color: Colors.orange[800]),
                        const SizedBox(width: 4),
                        Text(
                          'Mengedit Pesanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(_isEditing ? 'Batal Edit' : 'Reset Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing
                        ? Colors.orange[100]
                        : Colors.grey[300],
                    foregroundColor: _isEditing
                        ? Colors.orange[800]
                        : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildSectionTitle('Pilih Jenis Kue'),
            const SizedBox(height: 15),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedProduct,
              decoration: _inputDecoration('Pilih Kue'),
              items: _products.map((product) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: product,
                  child: Text(
                    '${product['name']} - Rp ${product['price'].toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedProduct = value),
              validator: (value) =>
                  value == null ? 'Pilih produk terlebih dahulu' : null,
            ),
            const SizedBox(height: 20),
            if (_selectedProduct != null) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          decoration: _inputDecoration(''),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan jumlah';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Jumlah harus angka';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8E8FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8C5F0)),
                          ),
                          child: Text(
                            'Rp ${totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC084D0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            _buildSectionTitle('Metode Pembayaran'),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedPayment,
              decoration: _inputDecoration('Pilih Metode Pembayaran'),
              items: paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(
                    method,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPayment = value),
              validator: (value) =>
                  value == null ? 'Pilih metode pembayaran' : null,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal Pengiriman',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Catatan Tambahan',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: _inputDecoration('Tulis catatan...'),
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 25),
            _buildSectionTitle('Data Pemesan'),
            const SizedBox(height: 15),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Nama Lengkap'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                final name = value.trim().toLowerCase();
                if (name == 'budi' || name == 'sari') {
                  return 'Nama "Budi" dan "Sari" tidak diperbolehkan';
                }
                return null;
              },
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              'No. Telepon',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration('08xxxxxxxxxx'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'No. telepon tidak boleh kosong';
                }
                if (value.length < 10) {
                  return 'No. telepon minimal 10 digit';
                }
                return null;
              },
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              'Alamat Lengkap',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: _inputDecoration('Jl. ...'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing
                      ? Colors.orange
                      : const Color(0xFFFF6B9D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        _isEditing ? 'Update Pesanan' : 'Pesan Sekarang',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserOrders(List<Map<String, dynamic>> orders) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pesanan Saya (${orders.length})'),
          const SizedBox(height: 10),
          ...orders.reversed.map((order) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.cake, color: Color(0xFFFF6B9D)),
                title: Text(order['productName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rp ${order['totalPrice']}'),
                    Text('Tanggal: ${order['deliveryDate'].split('T')[0]}'),
                    Text('Status: ${order['status']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: () => _viewOrderDetails(order),
                      color: Colors.blue,
                      tooltip: 'Lihat Detail',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editOrder(order),
                      color: Colors.green,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteOrder(order['id']),
                      color: Colors.red,
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF424242),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
