import 'package:flutter/material.dart';
import '../utils/theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.subtitleColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search for help',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: AppTheme.subtitleColor,
                              ),
                            ),
                            onSubmitted: (value) {
                              // Implement search functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Searching for: $value'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Frequently asked questions
            const Text(
              'Frequently Asked Questions',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 16),

            _buildFAQSection(context),

            const SizedBox(height: 24),

            // Contact support
            const Text('Contact Support', style: AppTheme.subheadingStyle),
            const SizedBox(height: 16),

            _buildContactOptions(context),

            const SizedBox(height: 24),

            // Video tutorials
            const Text('Video Tutorials', style: AppTheme.subheadingStyle),
            const SizedBox(height: 16),

            _buildVideoTutorials(context),

            const SizedBox(height: 24),

            // Help message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: AppTheme.primaryColor),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Our support team is available 24/7 to assist you. '
                      'Average response time is under 2 hours.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How do I reserve a parking spot?',
        'answer':
            'To reserve a parking spot, go to the Map screen, find an available spot, '
            'tap on it, and select "Reserve". You can also go to the Reservation screen '
            'and create a new reservation there.',
      },
      {
        'question': 'How long can I reserve a spot?',
        'answer':
            'You can reserve a parking spot for up to 3 hours at a time. '
            'If you need to extend your reservation, you can do so 15 minutes before '
            'it expires, subject to availability.',
      },
      {
        'question': 'How do I cancel my reservation?',
        'answer':
            'To cancel a reservation, go to the Reservations screen, '
            'find the reservation you want to cancel, and tap "Cancel Reservation". '
            'You can cancel a reservation at any time.',
      },
      {
        'question': 'What if someone is parked in my reserved spot?',
        'answer':
            'If someone is parked in your reserved spot, please report it '
            'through the app by tapping "Report Issue" on your reservation. '
            'You can also contact campus security for immediate assistance.',
      },
      {
        'question': 'How do I update my profile information?',
        'answer':
            'To update your profile information, go to the Profile screen '
            'and tap "Edit Profile". You can update your name, phone number, '
            'and vehicle information there.',
      },
    ];

    return ExpansionPanelList.radio(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.zero,
      children:
          faqs.map<ExpansionPanelRadio>((faq) {
            return ExpansionPanelRadio(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(height: 1.5),
                ),
              ),
              value: faq['question']!,
            );
          }).toList(),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.email_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Email Support',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('support@pmuparking.com'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening email client...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.chat_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Live Chat',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Chat with a support agent'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening live chat...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.phone_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Call Support',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('+966 13 849 9999'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening phone dialer...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _showReportProblemDialog(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('REPORT A PROBLEM'),
        ),
      ],
    );
  }

  Widget _buildVideoTutorials(BuildContext context) {
    final List<Map<String, String>> tutorials = [
      {
        'title': 'How to Reserve a Parking Spot',
        'duration': '2:15',
        'thumbnail': 'assets/images/video_thumbnail_1.jpg',
      },
      {
        'title': 'Using the Interactive Map',
        'duration': '3:42',
        'thumbnail': 'assets/images/video_thumbnail_2.jpg',
      },
      {
        'title': 'Managing Your Reservations',
        'duration': '1:58',
        'thumbnail': 'assets/images/video_thumbnail_3.jpg',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = tutorials[index];
          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Would normally use Image.asset here
                // Image.asset(
                //   tutorial['thumbnail']!,
                //   fit: BoxFit.cover,
                // ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutorial['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tutorial['duration']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Playing tutorial: ${tutorial['title']}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report a Problem'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please describe the issue you\'re experiencing:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Describe your problem here...',
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select problem category:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: 'Reservation Issue',
                    items:
                        [
                          'Reservation Issue',
                          'App Technical Problem',
                          'Account Issue',
                          'Payment Problem',
                          'Other',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {},
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          // Implement file attachment
                        },
                        child: const Text('Attach screenshot or file'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Problem report submitted. Thank you!'),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                },
                child: const Text('SUBMIT'),
              ),
            ],
          ),
    );
  }
}
