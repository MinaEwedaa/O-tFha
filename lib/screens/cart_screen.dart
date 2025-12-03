import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ProductService _productService = ProductService();

  double deliveryFees = 50.00;
  double taxes = 25.00;
  double discount = 20.00;

  double _calculateSubtotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateTotal(List<CartItem> items) {
    return _calculateSubtotal(items) + deliveryFees + taxes - discount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context),
              
              // Cart Content
              Expanded(
                child: StreamBuilder<List<CartItem>>(
                  stream: _productService.getCartStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading cart',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final cartItems = snapshot.data ?? [];

                    if (cartItems.isEmpty) {
                      return _buildEmptyCart();
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Cart Items
                            ...cartItems.map((item) => _buildCartItem(item)),
                            
                            const SizedBox(height: 24),
                            
                            // Order Summary
                            _buildOrderSummary(cartItems),
                            
                            const SizedBox(height: 24),
                            
                            // Checkout Button
                            _buildCheckoutButton(cartItems),
                            
                            const SizedBox(height: 12),
                            
                            // Secure Payment Text
                            Text(
                              'Secure payment powered by Otfha',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to your cart\nfrom the marketplace',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Browse Products',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.teal.shade600),
            onPressed: () => Navigator.pop(context),
          ),
          
          // Title
          Expanded(
            child: Center(
              child: Text(
                'My cart',
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

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      Icons.shopping_bag,
                      size: 30,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Controls
          Column(
            children: [
              // Plus Button
              GestureDetector(
                onTap: () => _updateQuantity(item, item.quantity + 1),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Quantity
              Text(
                '${item.quantity}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Minus Button
              GestureDetector(
                onTap: () {
                  if (item.quantity > 1) {
                    _updateQuantity(item, item.quantity - 1);
                  } else {
                    _showRemoveItemDialog(item);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    try {
      await _productService.updateCartItemQuantity(item.productId, newQuantity);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating quantity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOrderSummary(List<CartItem> items) {
    final subtotal = _calculateSubtotal(items);
    final total = _calculateTotal(items);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal :', 'EGP ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery fees :', 'EGP ${deliveryFees.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Taxes :', 'EGP ${taxes.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Discount:', '-EGP ${discount.toStringAsFixed(2)}', isDiscount: true),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow('Total', 'EGP ${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isDiscount ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(List<CartItem> items) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: items.isEmpty ? null : () => _proceedToCheckout(items),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          'Proceed to checkout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showRemoveItemDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Remove Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Do you want to remove "${item.productName}" from your cart?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _productService.removeFromCart(item.productId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.productName} removed from cart'),
                        backgroundColor: Colors.teal.shade600,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error removing item: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout(List<CartItem> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: items,
          deliveryFees: deliveryFees,
          taxes: taxes,
          discount: discount,
          total: _calculateTotal(items),
        ),
      ),
    );
  }
}
