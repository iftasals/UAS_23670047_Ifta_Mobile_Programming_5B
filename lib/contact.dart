import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_list.dart';
import 'order_form.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  int _selectedIndex = 2;
  final String phoneNumber = '088902984704';
  final String emailAddress = 'rasaria.cake@gmail.com';
  final String whatsappNumber = '088902984704';

  Future<void> _launchWhatsApp() async {
    String number = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    }

    final String message = Uri.encodeComponent(
      'Halo Admin,\n'
      'saya ingin meminta informasi lebih lanjut terkait salah satu produk yang ada di aplikasi.\n'
      'Mohon bantuannya.\n'
      'Terima kasih.',
    );

    final Uri url = Uri.parse('https://wa.me/$number?text=$message');

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      print('Error: $e');
      _showError(
        'WhatsApp tidak dapat dibuka. Pastikan WhatsApp sudah terinstall.',
      );
    }
  }

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse('tel:$phoneNumber');

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch Phone';
      }
    } catch (e) {
      print('Error: $e');
      _showError('Aplikasi telepon tidak dapat dibuka.');
    }
  }

  Future<void> _launchEmail() async {
    final Uri url = Uri.parse('mailto:$emailAddress');

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'Could not launch Email';
      }
    } catch (e) {
      print('Error: $e');
      _showError('Aplikasi email tidak dapat dibuka.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin: $text'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
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
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderFormPage(), // ✅ Tanpa parameter
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D),
        title: const Text('Hubungi Kami'),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.pink.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: const Color(0xFFFF6B9D).withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B9D),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cake,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'RasaRia Cake Shop',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kue lezat untuk setiap momen spesial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            const Text(
              'Hubungi Kami',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap untuk langsung membuka aplikasi:',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 25),

            _buildContactCard(
              title: 'WhatsApp',
              subtitle: 'Chat langsung dengan kami',
              icon: Icons.chat,
              color: const Color(0xFF25D366),
              onTap: _launchWhatsApp,
            ),
            const SizedBox(height: 20),

            _buildContactCard(
              title: 'Telepon',
              subtitle: 'Hubungi via telepon',
              icon: Icons.phone,
              color: const Color(0xFFFF6B9D),
              onTap: _launchPhone,
            ),
            const SizedBox(height: 20),

            _buildContactCard(
              title: 'Email',
              subtitle: 'Kirim pesan via email',
              icon: Icons.email,
              color: const Color(0xFFEA4335),
              onTap: _launchEmail,
            ),
            const SizedBox(height: 35),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.grey.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF6B9D),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Informasi Kontak',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildInfoRow(
                      Icons.phone,
                      'Nomor Telepon',
                      phoneNumber,
                      const Color(0xFFFF6B9D),
                      onTap: _launchPhone,
                      onLongPress: () =>
                          _copyToClipboard(phoneNumber, 'Nomor telepon'),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      Icons.email,
                      'Email',
                      emailAddress,
                      const Color(0xFFEA4335),
                      onTap: _launchEmail,
                      onLongPress: () =>
                          _copyToClipboard(emailAddress, 'Email'),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      Icons.access_time,
                      'Jam Operasional',
                      'Senin - Minggu: 08:00 - 21:00',
                      const Color(0xFF98FB98),
                      onTap: null,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      Icons.location_on,
                      'Alamat',
                      'Jl. Kampung Rahayu Raya, Semarang Timur',
                      const Color(0xFF4285F4),
                      onTap: null,
                      onLongPress: () => _copyToClipboard(
                        'Jl. Kampung Rahayu Raya, Semarang Timur',
                        'Alamat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateToPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFF6B9D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withOpacity(0.03)],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios, color: color, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor, {
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      splashColor: iconColor.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: onTap != null
              ? Colors.grey.withOpacity(0.03)
              : Colors.transparent,
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                color: iconColor.withOpacity(0.6),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
