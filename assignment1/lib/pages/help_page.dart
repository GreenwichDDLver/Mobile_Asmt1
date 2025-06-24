import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I track my order?',
      'answer': 'You can track your order in real-time by going to "My Orders" section. Click on your active order to see the live tracking map with your delivery partner\'s location and estimated arrival time.'
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept various payment methods including credit/debit cards (Visa, Mastercard), online banking, e-wallets (TouchNGo, Alipay), and cash on delivery for selected areas.'
    },
    {
      'question': 'How can I cancel my order?',
      'answer': 'You can cancel your order before the restaurant starts preparing it. Go to "My Orders", select your order, and tap "Cancel Order". If the restaurant has already started preparation, cancellation may not be possible or may have additional charges.'
    },
    {
      'question': 'Why was my order cancelled?',
      'answer': 'Orders may be cancelled due to restaurant closure, item unavailability, payment issues, or delivery area restrictions. You will receive a full refund if your order is cancelled.'
    },
    {
      'question': 'How do delivery fees work?',
      'answer': 'Delivery fees vary based on distance, times, weather conditions, and demand. Free delivery may be available for orders above a certain amount or with promotional codes.'
    },
    {
      'question': 'What if my food arrives cold or incorrect?',
      'answer': 'If you\'re not satisfied with your order, please report it immediately through the app. Go to "Order History", select the order, and tap "Report Issue". We\'ll investigate and provide appropriate compensation.'
    },
    {
      'question': 'How do I add special instructions?',
      'answer': 'When placing an order, you can add special instructions in the "Order Notes" section before checkout. This includes cooking preferences, delivery instructions, or allergy information.'
    },
    {
      'question': 'What are the operating hours?',
      'answer': 'Our platform operates 24/7, but restaurant availability varies. Most restaurants operate from 10 AM to 10 PM, while some offer late-night or early morning services. Check individual restaurant hours in the app.'
    }
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildQuickActionsCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Frequently Asked Questions'),
          _buildFAQSection(),
          const SizedBox(height: 24),
          _buildSectionHeader('Contact Us'),
          _buildContactSection(),
          const SizedBox(height: 24),
          _buildSectionHeader('Send Feedback'),
          _buildFeedbackForm(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    Icons.history,
                    'Order History',
                    () => _showSnackBar('Opening Order History...'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    Icons.report_problem,
                    'Report Issue',
                    () => _showReportIssueDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    Icons.live_help,
                    'Live Chat',
                    () => _showSnackBar('Connecting to live chat...'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    Icons.phone,
                    'Call Support',
                    () => _showSnackBar('Calling support: +60 123456789'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: _faqs.map((faq) => _buildFAQItem(faq)).toList(),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, String> faq) {
    return ExpansionTile(
      title: Text(
        faq['question']!,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      leading: const Icon(Icons.help_outline, color: Colors.orange),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            faq['answer']!,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: Colors.orange),
            title: const Text('Email Support'),
            subtitle: const Text('support@fooddelivery.com'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening email client...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.orange),
            title: const Text('Phone Support'),
            subtitle: const Text('+60 3-1234 5678 (24/7)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Calling support...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.orange),
            title: const Text('Live Chat'),
            subtitle: const Text('Available 24/7'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Starting live chat...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.orange),
            title: const Text('Visit Our Office'),
            subtitle: const Text('Kuala Lumpur, Malaysia'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSnackBar('Opening office location...'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Email (Optional)',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Colors.orange),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                hintText: 'Tell us about your experience or suggest improvements...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report an Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: const Text('Food Quality Issue'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Reporting food quality issue...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delivery_dining, color: Colors.orange),
                title: const Text('Delivery Problem'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Reporting delivery problem...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.orange),
                title: const Text('Payment Issue'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Reporting payment issue...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.more_horiz, color: Colors.orange),
                title: const Text('Other Issue'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Reporting other issue...');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      _showSnackBar('Please enter your feedback before submitting');
      return;
    }

    // Simulate feedback submission
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thank You!'),
          content: const Text('Your feedback has been submitted successfully. We appreciate your input and will use it to improve our service.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _feedbackController.clear();
                _emailController.clear();
              },
              child: const Text('OK', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}