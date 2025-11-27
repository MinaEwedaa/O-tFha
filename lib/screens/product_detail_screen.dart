import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    _buildProductImage(),
                    
                    // Product Info Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          _buildProductName(),
                          
                          const SizedBox(height: 12),
                          
                          // Seller Info with Rating
                          _buildSellerInfo(),
                          
                          const SizedBox(height: 16),
                          
                          // Quantity and Add to Cart Row
                          _buildQuantityAndCartSection(),
                          
                          const SizedBox(height: 20),
                          
                          // Description
                          _buildDescription(),
                          
                          const SizedBox(height: 16),
                          
                          // Tags (In stock, Organic, Ships within 2-3 days)
                          _buildTags(),
                          
                          const SizedBox(height: 24),
                          
                          // Recommended Section
                          _buildRecommendedSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          
          // Title
          Expanded(
            child: Center(
              child: Text(
                'Product Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          // Right side icons
          Row(
            children: [
              Text(
                'العربيّة',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.teal.shade600,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                child: Icon(Icons.shopping_cart_outlined, color: Colors.teal.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal.shade100,
                child: Icon(
                  Icons.person,
                  color: Colors.teal.shade700,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        child: Image.asset(
          widget.product['image'] ?? 'assets/images/background.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image,
                size: 80,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.shade600, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Product Name - ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                widget.product['name'] ?? 'Subname',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Icon(
            Icons.favorite_border,
            color: Colors.teal.shade600,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.person,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product['seller'] ?? 'Seller Name',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(3, (index) => Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.teal.shade600,
                    )),
                    Icon(
                      Icons.star_half,
                      size: 14,
                      color: Colors.teal.shade600,
                    ),
                    Icon(
                      Icons.star_border,
                      size: 14,
                      color: Colors.teal.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndCartSection() {
    return Row(
      children: [
        // Quantity Selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                icon: const Icon(Icons.remove, size: 18),
                color: Colors.teal.shade600,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$quantity',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                color: Colors.teal.shade600,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Add to Cart Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Add to cart logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added $quantity item(s) to cart',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.teal.shade600,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Add to cart',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    const fullDescription = 
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate '
        'libero et velit interdum, ac aliquet odio mattis. Class aptent taciti '
        'sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. '
        'Curabitur tempus urna at turpis condimentum lobortis. Ut commodo '
        'efficitur neque. Ut diam quam, semper iaculis condimentum ac, '
        'vestibulum eu nisl.';
    
    const shortDescription = 
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate '
        'libero et velit interdum, ac aliquet odio mattis. Class aptent taciti '
        'sociosqu ad litora torquent per conubia nostra...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isDescriptionExpanded ? fullDescription : shortDescription,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              isDescriptionExpanded = !isDescriptionExpanded;
            });
          },
          child: Text(
            isDescriptionExpanded ? 'read less' : 'read more',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.teal.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        _buildTag(Icons.check_circle_outline, 'In stock'),
        const SizedBox(width: 12),
        _buildTag(Icons.eco_outlined, 'Organic'),
        const SizedBox(width: 12),
        _buildTag(Icons.local_shipping_outlined, 'Ships within 2-3 days'),
      ],
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    // Sample recommended products
    final recommendedProducts = [
      {
        'image': 'assets/images/background.png',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedProducts.length,
            itemBuilder: (context, index) {
              return _buildRecommendedCard(recommendedProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> product) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Image.asset(
                product['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey.shade400,
                  );
                },
              ),
            ),
          ),
          
          // Product Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, size: 10, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Seller name',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

