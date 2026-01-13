import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_list.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerPhoneController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  // State variables
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRegisterPassword = true;
  bool _isCheckingLogin = true; // Tambahan untuk loading state

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _checkIfAlreadyLoggedIn();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerNameController.dispose();
    _registerPhoneController.dispose();
    super.dispose();
  }

  // NONAKTIFKAN AUTO-LOGIN - User harus login manual
  Future<void> _checkIfAlreadyLoggedIn() async {
    try {
      // Langsung set ke false, tidak perlu cek SharedPreferences
      // User HARUS login manual setiap kali
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
      }

      // Optional: Clear data login lama jika ada
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulasi API call dengan delay
      await Future.delayed(const Duration(seconds: 1));

      // Validasi email dan password (untuk demo)
      // Dalam aplikasi real, gunakan API yang sesuai
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw Exception('Email dan password harus diisi');
      }

      // Data user setelah login berhasil
      final Map<String, dynamic> dummyUser = {
        'email': _emailController.text,
        'name': 'User Demo',
        'phone': '081234567890',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', dummyUser['email']);
      await prefs.setString('name', dummyUser['name']);
      await prefs.setString('phone', dummyUser['phone']);

      if (!mounted) return;

      _showSnackBar('Login berhasil!', Colors.green);

      // Navigasi dengan delay untuk menunjukkan snackbar
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProductListPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulasi proses registrasi dengan delay
      await Future.delayed(const Duration(seconds: 2));

      // Simpan data registrasi untuk demo
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_name', _registerNameController.text);
      await prefs.setString('registered_email', _registerEmailController.text);
      await prefs.setString('registered_phone', _registerPhoneController.text);

      if (!mounted) return;

      _showSnackBar(
        'Registrasi berhasil! Silakan login.',
        const Color(0xFF00B894),
      );

      // Reset form dan kembali ke login
      setState(() {
        _isLogin = true;
        _registerNameController.clear();
        _registerPhoneController.clear();
        _registerEmailController.clear();
        _registerPasswordController.clear();
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saat registrasi: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.red
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: color == Colors.red
            ? SnackBarAction(
                label: 'Tutup',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading saat mengecek status login
    if (_isCheckingLogin) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8F0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side - Brand/Logo
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B9D), Color.fromARGB(255, 240, 159, 210)],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoImage(150),
                    const SizedBox(height: 30),
                    const Text(
                      'RasaRia',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kue Spesial untuk Momen Istimewa',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      child: Text(
                        'Nikmati berbagai pilihan kue terbaik dengan kualitas premium dan rasa yang tak terlupakan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right side - Login/Register Form
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 40,
                ),
                child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final paddingValue = constraints.maxWidth < 350 ? 16.0 : 24.0;
          final isSmallScreen = constraints.maxWidth < 350;

          return SingleChildScrollView(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              children: [
                // Header dengan logo
                Container(
                  padding: EdgeInsets.all(paddingValue * 0.8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF6B9D),
                        Color.fromARGB(255, 240, 159, 210),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildLogoImage(isSmallScreen ? 80 : 100),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        'RasaRia',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'Kue Spesial untuk Momen Istimewa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),

                // Form
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoImage(double size) {
    try {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B9D),
                      Color.fromARGB(255, 240, 159, 210),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.cake_rounded,
                  size: size * 0.6,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B9D), Color.fromARGB(255, 240, 159, 210)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
        ),
        child: Icon(Icons.cake_rounded, size: size * 0.6, color: Colors.white),
      );
    }
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallForm = constraints.maxWidth < 350;
          final buttonHeight = isSmallForm ? 48.0 : 56.0;
          final fontSize = isSmallForm ? 14.0 : 16.0;
          final spacing = isSmallForm ? 16.0 : 20.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selamat Datang!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: isSmallForm ? 24 : 28,
                ),
              ),
              SizedBox(height: isSmallForm ? 6 : 8),
              Text(
                'Masuk untuk melanjutkan pesanan',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isSmallForm ? 13 : 16,
                ),
              ),
              SizedBox(height: isSmallForm ? 24 : 32),

              // Email Field
              _buildTextFieldWithLabel(
                label: 'Email',
                controller: _emailController,
                hintText: 'contoh@email.com',
                icon: Icons.email_outlined,
                isSmall: isSmallForm,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),

              // Password Field
              _buildPasswordFieldWithLabel(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Masukkan password',
                isObscure: _obscurePassword,
                isSmall: isSmallForm,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmallForm ? 8 : 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showSnackBar(
                      'Fitur reset password akan segera tersedia',
                      Colors.blue,
                    );
                  },
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: const Color(0xFFFF6B9D),
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallForm ? 12 : 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallForm ? 20 : 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: buttonHeight * 0.4,
                          width: buttonHeight * 0.4,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: isSmallForm ? 20 : 24),

              // Switch to Register
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontSize: isSmallForm ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _isLogin = false),
                      child: Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: isSmallForm ? 12 : 14,
                          color: const Color(0xFFFF6B9D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallForm = constraints.maxWidth < 350;
          final buttonHeight = isSmallForm ? 48.0 : 56.0;
          final fontSize = isSmallForm ? 14.0 : 16.0;
          final spacing = isSmallForm ? 12.0 : 16.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Buat Akun Baru',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: isSmallForm ? 24 : 28,
                ),
              ),
              SizedBox(height: isSmallForm ? 6 : 8),
              Text(
                'Bergabunglah dengan RasaRia',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isSmallForm ? 13 : 16,
                ),
              ),
              SizedBox(height: isSmallForm ? 24 : 32),

              // Full Name Field
              _buildTextFieldWithLabel(
                label: 'Nama Lengkap',
                controller: _registerNameController,
                hintText: 'Masukkan nama lengkap',
                icon: Icons.person_outline,
                isSmall: isSmallForm,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),

              // Phone Field
              _buildTextFieldWithLabel(
                label: 'Nomor Telepon',
                controller: _registerPhoneController,
                hintText: '081234567890',
                icon: Icons.phone_outlined,
                isSmall: isSmallForm,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  final phoneRegex = RegExp(r'^[0-9]{10,13}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Format nomor telepon tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),

              // Email Field
              _buildTextFieldWithLabel(
                label: 'Email',
                controller: _registerEmailController,
                hintText: 'contoh@email.com',
                icon: Icons.email_outlined,
                isSmall: isSmallForm,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing),

              // Password Field
              _buildPasswordFieldWithLabel(
                label: 'Password',
                controller: _registerPasswordController,
                hintText: 'Minimal 6 karakter',
                isObscure: _obscureRegisterPassword,
                isSmall: isSmallForm,
                onToggleObscure: () => setState(
                  () => _obscureRegisterPassword = !_obscureRegisterPassword,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmallForm ? 24 : 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: buttonHeight * 0.4,
                          width: buttonHeight * 0.4,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: isSmallForm ? 20 : 24),

              // Switch to Login
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        fontSize: isSmallForm ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _isLogin = true),
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: isSmallForm ? 12 : 14,
                          color: const Color(0xFFFF6B9D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isSmall = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmall ? 6 : 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: isSmall ? 14 : 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: isSmall ? 14 : 16,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFFF6B9D),
              size: isSmall ? 20 : 24,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmall ? 14 : 16,
              vertical: isSmall ? 14 : 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isObscure,
    required bool isSmall,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmall ? 6 : 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(fontSize: isSmall ? 14 : 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: isSmall ? 14 : 16,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: const Color(0xFFFF6B9D),
              size: isSmall ? 20 : 24,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF636E72),
                size: isSmall ? 20 : 24,
              ),
              onPressed: onToggleObscure,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmall ? 14 : 16,
              vertical: isSmall ? 14 : 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
