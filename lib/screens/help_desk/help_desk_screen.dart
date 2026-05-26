import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/water_droplets_background.dart';

class HelpDeskScreen extends StatelessWidget {
  const HelpDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Help Desk',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tileBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEECF9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Call Help Desk',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '+1 800 TECH SUM',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tileBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.mail_outline,
                      color: Color(0xFFDB2777),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Email Support',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'help@techsummit2026.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDB2777),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const FaqAccordionList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),);
  }
}

class FaqAccordionList extends StatefulWidget {
  const FaqAccordionList({super.key});

  @override
  State<FaqAccordionList> createState() => _FaqAccordionListState();
}

class _FaqAccordionListState extends State<FaqAccordionList> {
  final List<FaqItemData> _faqs = [
    FaqItemData(
      question: 'Where do I collect my badge?',
      answer: 'Badges can be collected at the main registration desk near the Convention Center entrance. Bring your confirmation email or scan your event QR code.',
      isExpanded: true,
    ),
    FaqItemData(
      question: 'Is there Wi-Fi available?',
      answer: "Yes, high-speed Wi-Fi is available throughout the venue. Connect to 'DFSICON_FREE' and accept the landing page terms to get instant access.",
    ),
    FaqItemData(
      question: 'What are the event hours?',
      answer: 'DFSICON 2026 runs daily from 8:00 AM to 6:00 PM starting October 12, with evening receptions stretching until 8:30 PM.',
    ),
    FaqItemData(
      question: 'Is there a lost and found?',
      answer: 'Yes. Any lost items can be reported or claimed at the on-site Medical and Organizer Station located in Wing B, Ground Floor.',
    ),
    FaqItemData(
      question: 'Are meals provided?',
      answer: 'Complimentary gourmet buffet lunch, morning and afternoon coffee breaks, and evening cocktails are fully included with your delegate pass.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final item = _faqs[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(235),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tileBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    item.isExpanded = !item.isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        item.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (item.isExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    item.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class FaqItemData {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItemData({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}
