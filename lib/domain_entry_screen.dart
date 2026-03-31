import 'package:flutter/material.dart';
import 'webview_screen.dart';

class DomainEntryScreen extends StatefulWidget {
  const DomainEntryScreen({super.key});

  @override
  State<DomainEntryScreen> createState() => _DomainEntryScreenState();
}

class _DomainEntryScreenState extends State<DomainEntryScreen> {
  final TextEditingController _domainController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _navigateToStore() {
    if (_formKey.currentState!.validate()) {
      String input = _domainController.text.trim();
      
      // Remove trailing slash if user typed one
      if (input.endsWith('/')) {
        input = input.substring(0, input.length - 1);
      }
      
      String url;
      // If the input contains a dot (e.g., "example.com"), treat it as a full custom domain
      if (input.contains('.')) {
        url = 'http://$input';
      } else {
        // Otherwise, treat it as a streamrolla subdomain
        url = 'http://$input.public.streamrolla.com';
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(url: url),
        ),
      );
    }
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter Your Domain',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter the full domain of the site you want to visit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _domainController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.red,
                  decoration: InputDecoration(
                    labelText: 'Domain',
                    labelStyle: const TextStyle(color: Colors.redAccent),
                    hintText: 'e.g., ammarswebsite',
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    prefixIcon: const Icon(Icons.language, color: Colors.red),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a domain';
                    }
                    if (value.contains(' ')) {
                        return 'Domain cannot contain spaces';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _navigateToStore(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _navigateToStore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
