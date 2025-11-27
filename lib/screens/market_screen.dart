import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context),
              
              const SizedBox(height: 16),
              
              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: 16),
              
              // Category Tabs
              _buildCategoryTabs(),
              
              const SizedBox(height: 16),
              
              // Products Grid
              Expanded(
                child: _buildProductsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // O'tfha Logo
          Image.asset(
            'assets/images/logo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          
          // Right side icons
          Row(
            children: [
              Text(
                'العربية',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.teal.shade600,
                ),
              ),
              const SizedBox(width: 8),
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Icon(Icons.search, color: Colors.grey.shade600, size: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['All', 'Category 1', 'Category 2', 'Category 3'];
    
    return Container(
      height: 45,
      margin: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    // Sample product data
    final products = [
      {
        'image': 'assets/images/background.png', // Placeholder - replace with actual product images
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
      {
        'image': 'assets/images/background.png',
        'seller': 'Seller name',
        'name': 'Product name - subname',
        'price': 'EGX ...',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seller name
                      Row(
                        children: [
                          Icon(
                            Icons.store,
                            size: 10,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product['seller'],
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
                      // Product name
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
                    ],
                  ),
                  // Price
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
          ),
        ],
      ),
    ),
    );
  }
}

