import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _emailAddressController;
  late FocusNode _emailAddressFocusNode;

  late TextEditingController _passwordController;
  late FocusNode _passwordFocusNode;

  late TextEditingController _reenterPasswordController;
  late FocusNode _reenterPasswordFocusNode;

  bool _passwordVisibility = false;
  bool _reenterPasswordVisibility = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _emailAddressController = TextEditingController();
    _emailAddressFocusNode = FocusNode();

    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();

    _reenterPasswordController = TextEditingController();
    _reenterPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailAddressController.dispose();
    _emailAddressFocusNode.dispose();

    _passwordController.dispose();
    _passwordFocusNode.dispose();

    _reenterPasswordController.dispose();
    _reenterPasswordFocusNode.dispose();

    super.dispose();
  }

  Future<void> signUp(GlobalKey<FormState> formKey) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Perform sign-up operation
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailAddressController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Dismiss the dialog after successful sign-up
      Navigator.of(context).pop();

      // Navigate to login page after successful registration
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Dismiss the progress dialog
      Navigator.of(context).pop();

      // Show the error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );

      print('Error during sign up: $e');
    } catch (e) {
      // Dismiss the progress dialog
      Navigator.of(context).pop();

      // Show a generic error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );

      print('Error during sign up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFE6C68E),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Register New Account',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _emailAddressController,
                      focusNode: _emailAddressFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: _emailAddressFocusNode.hasFocus
                              ? Colors.brown
                              : Colors.brown,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.brown,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.brown,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        } else if (!EmailValidator.validate(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_passwordVisibility,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: _passwordFocusNode.hasFocus
                              ? Colors.brown
                              : Colors.brown,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.brown,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.brown,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisibility
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: _passwordFocusNode.hasFocus
                                ? Colors.brown
                                : Colors.brown,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisibility = !_passwordVisibility;
                            });
                          },
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please reenter your password';
                        } else if (!RegExp(r'^(?=.*?[A-Z])').hasMatch(value)) {
                          return 'Password must include at least one uppercase letter';
                        } else if (!RegExp(r'^(?=.*?[a-z])').hasMatch(value)) {
                          return 'Password must include at least one lowercase letter';
                        } else if (!RegExp(r'^(?=.*?[!@#\$&*~])')
                            .hasMatch(value)) {
                          return 'Password must include at least one symbol';
                        } else if (value.length < 9) {
                          return 'Password must be at least 9 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _reenterPasswordController,
                      focusNode: _reenterPasswordFocusNode,
                      obscureText: !_reenterPasswordVisibility,
                      decoration: InputDecoration(
                        labelText: 'Reenter New Password',
                        labelStyle: TextStyle(
                          color: _reenterPasswordFocusNode.hasFocus
                              ? Colors.brown
                              : Colors.brown,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.brown,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.brown,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _reenterPasswordVisibility
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: _reenterPasswordFocusNode.hasFocus
                                ? Colors.brown
                                : Colors.brown,
                          ),
                          onPressed: () {
                            setState(() {
                              _reenterPasswordVisibility =
                                  !_reenterPasswordVisibility;
                            });
                          },
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please reenter your password';
                        } else if (value != _passwordController.text.trim()) {
                          return 'Password does not match!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        // Registration logic goes here
                        try {
                          await signUp(_formKey);

                          // Save email and password after successful registration
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString(
                              'email', _emailAddressController.text.trim());
                          prefs.setString(
                              'password', _passwordController.text.trim());

                          // Navigate to another screen or perform any other action
                        } catch (e) {
                          // Handle registration errors
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown, // Background color
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.dmSerifDisplay(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
