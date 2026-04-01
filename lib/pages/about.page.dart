import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://img.freepik.com/free-photo/business-people-shaking-hands-together_53876-20418.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Title & Intro
            const Text(
              'You are home.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We are building a future that is empowered by technology and driven by people. Together we create environments where all of us can thrive.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'You work @ Property.com',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Repeated Mission Card (as in screenshot)
            _buildMissionCard(),
            const SizedBox(height: 16),
            _buildMissionCard(), // Repeated for exact match

            const SizedBox(height: 24),

            // Vision Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vision',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text('Changing the way India experiences property.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mission, Values, etc.
            _buildColoredCard(
              'Mission',
              'To be the first choice of our consumers and partners in discovering, renting, buying, selling and financing a home...',
              Colors.green.shade50,
            ),
            const SizedBox(height: 16),
            _buildColoredCard(
              'Values',
              'Relentless on quality, relentless on innovation...',
              Colors.blue.shade50,
            ),
            const SizedBox(height: 16),
            _buildColoredCard(
              'Integrity',
              'Bound by openness, trust...',
              Colors.orange.shade50,
            ),

            const SizedBox(height: 24),

            // Meet Our Team Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://img.freepik.com/free-photo/group-successful-business-people_53876-13731.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Meet Our Team',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We have a team of diligent professionals with a diverse blend of experience who work together...',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),

            // Life at Propstyle
            const Text(
              'Life at Propstyle',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://img.freepik.com/free-photo/business-people-having-fun-office_23-2149371485.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'At Square Yards, supporting our employees is core to everything we do. We foster a balanced and welcoming work environment...',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),

            // Our Ethos Icons List
            const Text(
              'Our Ethos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildEthosItem(
              Icons.interests,
              'INTEGRITY',
              'We are committed to doing the right thing...',
            ),
            _buildEthosItem(
              Icons.group,
              'TEAMWORK',
              'We believe success is achieved...',
            ),
            _buildEthosItem(
              Icons.lightbulb,
              'TRANSPARENCY',
              'We believe in open and honest...',
            ),
            _buildEthosItem(
              Icons.rocket,
              'INNOVATIVENESS',
              'We are driven to innovate...',
            ),
            _buildEthosItem(
              Icons.person,
              'USERCENTRIC',
              'We put our users at the heart...',
            ),
            _buildEthosItem(
              Icons.trending_up,
              'DYNAMIC',
              'We are dynamic. We adapt...',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You will open doors for buyers, sellers and renters across India and solve the problem of how people interact with property.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Image.network(
                    'https://img.freepik.com/free-photo/business-people-working-together_53876-20417.jpg',
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'You will work with a team of passionate, talented people who are building the future of real estate in India.',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredCard(String title, String content, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildEthosItem(IconData icon, String title, String desc) {
    return

      Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.grey[700]),
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
                  ),
                ),
                Text(desc, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );


  }


}
