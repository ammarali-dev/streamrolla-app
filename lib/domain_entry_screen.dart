import 'package:flutter/material.dart';
import 'webview_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DomainEntryScreen extends StatefulWidget {
  const DomainEntryScreen({super.key});

  @override
  State<DomainEntryScreen> createState() => _DomainEntryScreenState();
}

class _DomainEntryScreenState extends State<DomainEntryScreen> {
  final TextEditingController _domainController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<List<String>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await http.get(
        Uri.parse('http://public.streamrolla.com/api/discovery/websites'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<String> domains = List<String>.from(data['data']);
          return domains
              .where((d) => d.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
    return [];
  }

  void _navigateToStore({String? selectedValue}) {
    if (_formKey.currentState!.validate() || selectedValue != null) {
      String input = selectedValue ?? _domainController.text.trim();
      
      if (input.isEmpty) return;

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
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return _fetchSuggestions(textEditingValue.text);
                  },
                  onSelected: (String selection) {
                    _domainController.text = selection;
                    _navigateToStore(selectedValue: selection);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Sync the internal autocomplete controller with our domain controller
                    controller.addListener(() {
                      _domainController.text = controller.text;
                    });

                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
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
                      onFieldSubmitted: (value) {
                        _domainController.text = value;
                        _navigateToStore();
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 48,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option, style: const TextStyle(color: Colors.white)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
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
