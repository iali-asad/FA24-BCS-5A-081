import 'package:flutter/material.dart';

void main() {
  runApp(const SalaryCalculatorApp());
}

class SalaryCalculatorApp extends StatelessWidget {
  const SalaryCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salary Calculator',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
        ),
      ),
      home: const SalaryCalculatorPage(),
    );
  }
}

class SalaryCalculatorPage extends StatefulWidget {
  const SalaryCalculatorPage({super.key});

  @override
  State<SalaryCalculatorPage> createState() =>
      _SalaryCalculatorPageState();
}

class _SalaryCalculatorPageState
    extends State<SalaryCalculatorPage> {

  final basicController = TextEditingController();
  final houseRentController = TextEditingController();
  final medicalController = TextEditingController();
  final travelController = TextEditingController();

  double grossSalary = 0;
  double tax = 0;
  double netSalary = 0;

  // Tax rate used for this assignment
  final double taxRate = 10;

  // ---------------- CALCULATIONS ----------------

  double calculateGrossSalary() {
    final basic = double.tryParse(basicController.text) ?? 0;
    final houseRent = double.tryParse(houseRentController.text) ?? 0;
    final medical = double.tryParse(medicalController.text) ?? 0;
    final travel = double.tryParse(travelController.text) ?? 0;

    return basic + houseRent + medical + travel;
  }

  double calculateTax(double gross) {
    return gross * taxRate / 100;
  }

  double calculateNetSalary(double gross, double taxAmount) {
    return gross - taxAmount;
  }

  // ---------------- VALIDATION ----------------

  bool validateInputs() {
    if (basicController.text.trim().isEmpty ||
        houseRentController.text.trim().isEmpty ||
        medicalController.text.trim().isEmpty ||
        travelController.text.trim().isEmpty) {
      showMessage('Please fill all salary fields.');
      return false;
    }

    final values = [
      basicController.text,
      houseRentController.text,
      medicalController.text,
      travelController.text,
    ];

    for (final value in values) {
      final number = double.tryParse(value);

      if (number == null) {
        showMessage('Please enter valid numbers.');
        return false;
      }

      if (number < 0) {
        showMessage('Salary values cannot be negative.');
        return false;
      }
    }

    return true;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------- CALCULATE ----------------

  void calculateSalary() {
    if (!validateInputs()) return;

    final gross = calculateGrossSalary();
    final taxAmount = calculateTax(gross);
    final finalSalary = calculateNetSalary(gross, taxAmount);

    setState(() {
      grossSalary = gross;
      tax = taxAmount;
      netSalary = finalSalary;
    });
  }

  // ---------------- RESET ----------------

  void resetFields() {
    basicController.clear();
    houseRentController.clear();
    medicalController.clear();
    travelController.clear();

    setState(() {
      grossSalary = 0;
      tax = 0;
      netSalary = 0;
    });
  }

  // ---------------- INPUT FIELD ----------------

  Widget salaryField({
    required String title,
    required String hint,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: title,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------- RESULT CARD ----------------

  Widget resultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BUILD UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: const Text(
          'Salary Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_center,
                    color: Colors.white,
                    size: 38,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'HR Payroll Calculator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Calculate your monthly salary quickly and accurately.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SALARY COMPONENTS TITLE
            const Text(
              'Salary Components',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172554),
              ),
            ),

            const SizedBox(height: 14),

            // BASIC SALARY
            salaryField(
              title: 'Basic Salary',
              hint: 'Enter basic salary',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF2563EB),
              controller: basicController,
            ),

            // HOUSE RENT
            salaryField(
              title: 'House Rent Allowance',
              hint: 'Enter house rent allowance',
              icon: Icons.home,
              color: const Color(0xFF7C3AED),
              controller: houseRentController,
            ),

            // MEDICAL
            salaryField(
              title: 'Medical Allowance',
              hint: 'Enter medical allowance',
              icon: Icons.medical_services,
              color: const Color(0xFF059669),
              controller: medicalController,
            ),

            // TRAVEL
            salaryField(
              title: 'Travel Allowance',
              hint: 'Enter travel allowance',
              icon: Icons.directions_car,
              color: const Color(0xFFEA580C),
              controller: travelController,
            ),

            const SizedBox(height: 8),

            // TAX INFORMATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF97316).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.percent,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tax Deduction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Tax Rate: 10%',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // BUTTONS
            Row(
              children: [

                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: calculateSalary,
                      icon: const Icon(Icons.calculate),
                      label: const Text(
                        'Calculate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: resetFields,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFFDC2626),
                        side: const BorderSide(
                          color: Color(0xFFDC2626),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // RESULTS
            if (grossSalary > 0) ...[
              const SizedBox(height: 28),

              const Text(
                'Salary Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172554),
                ),
              ),

              const SizedBox(height: 14),

              resultCard(
                title: 'Gross Salary',
                value:
                    'Rs. ${grossSalary.toStringAsFixed(2)}',
                icon: Icons.payments,
                color: const Color(0xFF2563EB),
              ),

              resultCard(
                title: 'Tax Deduction (10%)',
                value:
                    'Rs. ${tax.toStringAsFixed(2)}',
                icon: Icons.receipt_long,
                color: const Color(0xFFEA580C),
              ),

              const SizedBox(height: 6),

              // FINAL SALARY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF047857),
                      Color(0xFF059669),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 38,
                    ),

                    SizedBox(height: 8),

                    Text(
                      'FINAL NET MONTHLY INCOME',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  border: Border.all(
                    color: const Color(0xFF059669)
                        .withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Rs. ${netSalary.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF047857),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'Professional Payroll • Salary Management',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}