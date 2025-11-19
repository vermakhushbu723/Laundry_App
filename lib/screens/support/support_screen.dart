import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.support_agent, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'re here to assist you 24/7',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Contact Options
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildContactCard(
                    context: context,
                    icon: Icons.phone,
                    title: 'Call Us',
                    subtitle: '+91 98765 43210',
                    color: Colors.green,
                    onTap: () => _copyToClipboard(
                      context,
                      '+919876543210',
                      'Phone number',
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildContactCard(
                    context: context,
                    icon: Icons.email,
                    title: 'Email Us',
                    subtitle: 'support@laundryapp.com',
                    color: Colors.blue,
                    onTap: () => _copyToClipboard(
                      context,
                      'support@laundryapp.com',
                      'Email',
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildContactCard(
                    context: context,
                    icon: Icons.message,
                    title: 'WhatsApp',
                    subtitle: 'Chat with us on WhatsApp',
                    color: Colors.green.shade700,
                    onTap: () => _copyToClipboard(
                      context,
                      '+919876543210',
                      'WhatsApp number',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // FAQs Section
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFAQItem(
                    question: 'How do I place an order?',
                    answer:
                        'You can place an order by going to the Services screen, selecting your desired service, choosing a pickup date and time, and confirming your booking.',
                  ),
                  _buildFAQItem(
                    question: 'What are your pickup timings?',
                    answer:
                        'We offer flexible pickup timings from 8:00 AM to 8:00 PM. You can choose your preferred time slot while placing an order.',
                  ),
                  _buildFAQItem(
                    question: 'How can I track my order?',
                    answer:
                        'You can track your order status in real-time from the Orders screen. You\'ll receive notifications for each status update.',
                  ),
                  _buildFAQItem(
                    question: 'What is your cancellation policy?',
                    answer:
                        'You can cancel your order before pickup without any charges. Once the order is picked up, cancellation may incur a small fee.',
                  ),
                  _buildFAQItem(
                    question: 'How do I update my profile?',
                    answer:
                        'Go to your Profile from the Dashboard menu, tap the edit icon, make your changes, and save them.',
                  ),
                  _buildFAQItem(
                    question: 'What payment methods do you accept?',
                    answer:
                        'We accept cash on delivery, UPI, credit/debit cards, and digital wallets for your convenience.',
                  ),
                  const SizedBox(height: 30),

                  // Quick Links
                  const Text(
                    'Quick Links',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildQuickLinkCard(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    onTap: () {
                      // TODO: Navigate to About Us
                    },
                  ),
                  _buildQuickLinkCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // TODO: Navigate to Privacy Policy
                    },
                  ),
                  _buildQuickLinkCard(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      // TODO: Navigate to Terms
                    },
                  ),
                  _buildQuickLinkCard(
                    icon: Icons.star_outline,
                    title: 'Rate Our App',
                    onTap: () {
                      // TODO: Open app store for rating
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
