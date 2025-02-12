import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String orderId;
  final double totalAmount; // Add total amount as a parameter

  const PaymentPage({Key? key, required this.orderId, required this.totalAmount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a payment method:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // Credit/Debit Card Payment
            PaymentOption(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              totalAmount: totalAmount, // Pass the total amount
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentProcessingPage(
                      orderId: orderId,
                      paymentMethod: 'Credit/Debit Card',
                      totalAmount: totalAmount,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // UPI Payment
            PaymentOption(
              icon: Icons.account_balance_wallet,
              title: 'UPI',
              totalAmount: totalAmount, // Pass the total amount
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentProcessingPage(
                      orderId: orderId,
                      paymentMethod: 'UPI',
                      totalAmount: totalAmount,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // PayPal Payment
            PaymentOption(
              icon: Icons.paypal,
              title: 'PayPal',
              totalAmount: totalAmount, // Pass the total amount
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentProcessingPage(
                      orderId: orderId,
                      paymentMethod: 'PayPal',
                      totalAmount: totalAmount,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final double totalAmount;
  final VoidCallback onTap;

  const PaymentOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.totalAmount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 30, color: Colors.black),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentProcessingPage extends StatelessWidget {
  final String orderId;
  final String paymentMethod;
  final double totalAmount;

  const PaymentProcessingPage({
    Key? key,
    required this.orderId,
    required this.paymentMethod,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processing Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Processing payment with $paymentMethod...',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Amount: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Complete payment process and navigate back
                Navigator.popUntil(context, (route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment Successful with $paymentMethod!')),
                );
              },
              child: const Text('Simulate Success'),
            ),
          ],
        ),
      ),
    );
  }
}
