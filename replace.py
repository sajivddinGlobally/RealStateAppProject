import sys

file_path = r"c:\Users\Globally-04\Pictures\RealStateAppProject\lib\pages\home.page.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

start_str = "class _LoanServiceState extends ConsumerState<LoanService> {"
end_str = "\n}\n\n/// 🔹 Model\nclass LoanModel {"

start_idx = content.find(start_str)
end_idx = content.find(end_str)

if start_idx == -1 or end_idx == -1:
    print("Could not find start or end block")
    sys.exit(1)

old_block = content[start_idx:end_idx]
commented_old_block = "\n".join(["// " + line for line in old_block.split("\n")])

new_content = """class _LoanServiceState extends ConsumerState<LoanService> {
  String searchLoan = '';
  
  final List<Map<String, String>> loanTypes = [
    {"title": "HOME LOAN", "image": "assets/png/home.png"},
    {"title": "CAR LOAN", "image": "assets/png/car.png"},
    {"title": "PERSONAL LOAN", "image": "assets/png/personal.png"},
    {"title": "BUSINESS LOAN", "image": "assets/png/business.png"},
    {"title": "EDUCATION LOAN", "image": "assets/png/education.png"},
    {"title": "GOLD LOAN", "image": "assets/png/gold.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   CupertinoPageRoute(builder: (context) => MyLoanRequestPage()),
                // );
              },
              child: Container(
                width: double.infinity,
                height: 45.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF24ADD7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "MY LOAN REQUESTS",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: loanTypes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                final item = loanTypes[index];
                return InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   CupertinoPageRoute(
                    //     builder: (context) => LoanServiceDetailsPage(item: item),
                    //   ),
                    // );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item["image"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey.shade300);
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 70.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.h,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                item["title"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 24.w),
                                padding: EdgeInsets.symmetric(vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24ADD7),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Contact",
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // --- OLD COMMENTED CODE ---
"""

new_content_full = new_content + "\n" + commented_old_block

content = content[:start_idx] + new_content_full + content[end_idx:]

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)
print("Success!")
