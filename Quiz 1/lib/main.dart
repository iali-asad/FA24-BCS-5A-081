// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const green = Color(0xFF0F6E56);

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: green),
      home: const RegistrationPage(),
    ));

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String gender = 'Female', option = 'Option 1', item = 'Item 2', dept = 'CS';
  Map<String, bool> hobbies = {'Reading': true, 'Sports': false};

  Widget tf(String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  Widget lbl(String t) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget dd(String label, String value, List<String> items,
          void Function(String) set) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => set(v!)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Web background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [
                      Icon(Icons.school, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Student Registration',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE1F5EE),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        tf('Student Name', Icons.person_outline),
                        tf('Registration Number', Icons.badge_outlined),
                        lbl('Gender'),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'Male', label: Text('Male')),
                            ButtonSegment(value: 'Female', label: Text('Female')),
                          ],
                          selected: {gender},
                          onSelectionChanged: (s) =>
                              setState(() => gender = s.first),
                        ),
                        const SizedBox(height: 12),
                        lbl('Hobbies'),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final h in hobbies.keys)
                              FilterChip(
                                label: Text(h),
                                selected: hobbies[h]!,
                                onSelected: (v) =>
                                    setState(() => hobbies[h] = v),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        dd('Option List', option,
                            ['Option 1', 'Option 2', 'Option 3'],
                            (v) => option = v),
                        dd('Selection List', item,
                            ['Item 1', 'Item 2', 'Item 3'],
                            (v) => item = v),
                        dd('Department', dept, ['CS', 'SE', 'AI', 'EE'],
                            (v) => dept = v),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                              onPressed: () {},
                              child: const Text('Submit')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
