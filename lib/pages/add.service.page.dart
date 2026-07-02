import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddServicePage extends StatelessWidget {
  const AddServicePage({super.key});

  final List<Map<String, String>> categories = const [
    {
      'label': 'ELECTRICIAN',
      'url':
          'https://media.istockphoto.com/id/1049775258/photo/smiling-handsome-electrician-repairing-electrical-box-with-pliers-in-corridor-and-looking-at.jpg?s=612x612&w=0&k=20&c=stdWozouV2XsrHk2xXD3C31nT90BG7ydZvcpAn1Fx7I=',
    }, // Replace with actual
    {
      'label': 'CARPENTER',
      'url':
          'https://s3-media0.fl.yelpcdn.com/bphoto/y2N9GweV0RhaXx9dYbXHTA/l.jpg',
    },
    {
      'label': 'PAINTER',
      'url':
          'https://www.shutterstock.com/image-vector/worker-repair-service-plumber-handyman-260nw-2234725577.jpg',
    },
    {
      'label': 'PLUMBER',
      'url':
          'https://cdn.prod.website-files.com/5e593fb060cf877cf875dd1f/679085ac60c170e5ebba4b34_recBrwtY2JtNJji6k_image_1.webp',
    },
    {
      'label': 'CLEANING',
      'url':
          'https://www.shutterstock.com/shutterstock/videos/3684051321/thumb/4.jpg?ip=x480',
    },
    {
      'label': 'INTERIOR',
      'url':
          'https://s3-media0.fl.yelpcdn.com/bphoto/tuGs0mGEDRuE8omqeINuKQ/l.jpg',
    },
    {
      'label': 'RENOVATION',
      'url':
          'https://cdn.prod.website-files.com/5e593fb060cf877cf875dd1f/677c007c62c5db1e8a3b1317_handyman-webflow-template.png',
    },
    {
      'label': 'PEST CONTROL',
      'url':
          'https://img.freepik.com/free-photo/people-disinfecting-together-dangerous-area_23-2148848569.jpg?semt=ais_hybrid&w=740&q=80',
    },
  ];

  final List<Map<String, String>> services = const [
    {
      'icon': 'Toilet Repair',
      'title': 'Toilet Repair',
      'desc':
          'Fast, reliable toilet fixes that restore comfort and functionality.',
    },
    {
      'icon': 'Faucet Installation',
      'title': 'Faucet Installation',
      'desc': 'Expert faucet installation and repair for every style.',
    },
    {
      'icon': 'Sewer Inspection',
      'title': 'Sewer Inspection',
      'desc': 'Advanced camera inspections to prevent damage.',
    },
    {
      'icon': 'Sewer Inspection',
      'title': 'Sewer Inspection',
      'desc': 'Advanced camera inspections to prevent damage.',
    }, // Duplicate in screenshot, adjust if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9FBFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 20.w),
                Text(
                  'HOME SERVICE',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: Color(0xFFFF6725),
                  ),
                  child: Text(
                    '+ ADD HOME SERVICE',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
              ],
            ),
            // Categories Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.12,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    cardWidget(
                      categories[index]['label'].toString(),
                      categories[index]['url'].toString(),
                    ),
                  ],
                );
              },
            ),

            // We Provide Quality Services
            Center(
              child: Text(
                'What We Offer',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Center(
              child: Text(
                'We Provide Quality Services',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Services Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                ServiceCard(
                  title: 'Toilet Repair',
                  desc:
                      'Fast, reliable toilet fixes that restore proper function.',
                  imageUrl:
                      'https://media.gettyimages.com/id/2192255408/vector/plumbing-line-icon-set-group-of-object-pipe-bathtub-boiler-faucet-repair.jpg?s=612x612&w=gi&k=20&c=IgKlfAmPPCWSHJy7L_KlG4bjVyB_If33cqFTI8X51Ng=',
                ),
                ServiceCard(
                  title: 'Faucet Installation',
                  desc: 'Expert faucet fitting that ensures smooth water flow.',
                  imageUrl:
                      'https://media.istockphoto.com/id/1140334314/vector/plumber-master-with-wrench-fixing-kitchen-faucet.jpg?s=612x612&w=0&k=20&c=5XTiydIT32QfXU-x8WVM6rSeWpy6TopGU66RNfPunw4=',
                ),
                ServiceCard(
                  title: 'Sewer Inspection',
                  desc: 'Advanced sewer checks to detect issues early.',
                  imageUrl:
                      'https://media.istockphoto.com/id/2194903933/vector/plumbers-and-plumbing-thin-line-icons-editable-stroke-icons-include-plumbing-pipes-leaky.jpg?s=612x612&w=0&k=20&c=V2EAWro2g_Xk72Bl9c0LJ78ylpTxzZaZcyct56nqwCc=',
                ),
                ServiceCard(
                  title: 'Drain Cleaning',
                  desc: 'Prevent damage with professional drain cleaning.',
                  imageUrl:
                      'https://media.istockphoto.com/id/1363041172/vector/water-tank-pipe-pipeline-and-sewerage-cleaning-service-by-cleaner.jpg?s=612x612&w=0&k=20&c=OPh5837hpAV13c5fsr3daJrrzFK1E4HjSEhiDdgZwN0=',
                ),
              ],
            ),

            // Why We Are / Easy Solutions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Who We Are',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Easy Solutions For Plumbing and Home Repair Needs',
                    style: GoogleFonts.inter(fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Chip(
                        padding: EdgeInsets.zero,
                        label: Text(
                          'Tech Expertise',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      Chip(
                        padding: EdgeInsets.zero,
                        label: Text(
                          'Advanced Tools',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      Chip(
                        padding: EdgeInsets.zero,
                        label: Text(
                          'Smart Solutions',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Hire Experts'),
                  ),
                ],
              ),
            ),

            // Plumber Image
            Image.network(
              'https://as1.ftcdn.net/jpg/05/94/89/64/1000_F_594896473_PmXb07nS8Odld7O3op4E5Vi2USzODYYc.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),

            // Affordable Pricing
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.price_check, size: 40, color: Colors.orange),
                  Text(
                    'Affordable Pricing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quality service doesn\'t have to be costly. We offer transparent, fair pricing on every job.',
                  ),
                ],
              ),
            ),

            // Featured Projects
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Projects',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See Full Gallery >',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FeaturedProject(
                    imageUrl:
                        'https://images.finehomebuilding.com/app/uploads/2016/04/09114955/021181bs116-01_xlg.jpg',
                    title: 'Drain Overhaul',
                    subtitle: 'Complete drain system upgrade',
                  ),
                  FeaturedProject(
                    imageUrl:
                        'https://www.thespruce.com/thmb/e-MxaOBy4AKp4JW1XFZGbrkDaIw=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-to-install-a-sink-drain-2718789_hero_5078-64538f6f90d545c7af0728e4bf8f894e.jpg',
                    title: 'Sink Installation',
                    subtitle: 'New kitchen sink setup',
                  ),
                  FeaturedProject(
                    imageUrl:
                        'https://gharpedia.com/_next/image/?url=https%3A%2F%2Fcloudfrontgharpediabucket.gharpedia.com%2Fuploads%2F2021%2F12%2FBest-Way-to-Install-a-Bathroom-Sink-Drain-01-0504130013.jpg&w=3840&q=75',
                    title: 'Drain Overhaul',
                    subtitle: 'Complete drain system upgrade',
                  ),
                ],
              ),
            ),

            // Latest Insights
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Our Latest Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.network(
                    'https://wg.scene7.com/is/image/wrenchgroup/insulate-pipes-info-ps22wi001wg?&wid=362',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'How to Protect Your Pipes During Cold Weather',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Read More >',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget cardWidget(String title, String url) {
    return Container(
      width: 160.w,
      height: 129.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String desc;
  final String imageUrl;

  const ServiceCard({
    super.key,
    required this.title,
    required this.desc,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICON / IMAGE
          SizedBox(
            height: 60,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
          const SizedBox(height: 14),

          // TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),

          // DESCRIPTION
          Text(
            desc,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class FeaturedProject extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  const FeaturedProject({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black54),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(title),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
