import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late FocusNode _emailAddressFocusNode;
  late FocusNode _passwordFocusNode;
  bool _passwordVisibility = false;
  var _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailAddressFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailAddressFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    // Check if email and password fields are not empty
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter both email and password.";
      });
      return;
    }

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // After sign in, check if user is not null
      if (userCredential.user != null) {
        print('User is signed in with UID: ${userCredential.user!.uid}');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in successfully!'),
            duration: Duration(
                seconds: 2), // Optional: Set the duration of the SnackBar
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('User sign in failed');
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'User not found. Please check your credentials.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Invalid password. Please try again.';
      }
      // Update the _errorMessage
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  void forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email to reset your password:'),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_emailController.text.trim().isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _emailController.text.trim(),
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Password reset link sent to your email.'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  } catch (error) {
                    print('Error sending password reset email: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Failed to send password reset email. Please try again later.'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFEBCA93),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Login',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 50),
                      TextFormField(
                        controller: _emailController,
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
                      ),
                      SizedBox(height: 20),
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
                      ),
                      SizedBox(height: 20),
                      // Display error message if there is one
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          signIn();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.brown,
                          backgroundColor: Colors.brown,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.brown),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.brown,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: forgotPassword,
                        child: RichText(
                          text: TextSpan(
                            text: 'Forgot Password?',
                            style: TextStyle(color: Colors.brown),
                            recognizer: TapGestureRecognizer()
                              ..onTap = forgotPassword,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
