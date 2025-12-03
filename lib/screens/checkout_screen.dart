import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double deliveryFees;
  final double taxes;
  final double discount;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.deliveryFees,
    required this.taxes,
    required this.discount,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ProductService _productService = ProductService();
  String selectedPaymentMethod = 'cash_on_delivery';
  bool _isPlacingOrder = false;
  
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values
    _streetController.text = '';
    _cityController.text = '';
    _countryController.text = 'Egypt';
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Information
                      _buildDeliveryInformation(),
                      
                      const SizedBox(height: 24),
                      
                      // Payment Method
                      _buildPaymentMethod(),
                      
                      const SizedBox(height: 24),
                      
                      // Place Order Section
                      _buildPlaceOrderSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Place Order Button
                      _buildPlaceOrderButton(),
                    ],
                  ),
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
                'Checkout',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDeliveryInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery information',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Street
        TextField(
          controller: _streetController,
          decoration: InputDecoration(
            labelText: 'Street Address',
            labelStyle: GoogleFonts.poppins(),
            hintText: 'Enter your street address',
            prefixIcon: Icon(Icons.location_on, color: Colors.teal.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // City
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'City',
            labelStyle: GoogleFonts.poppins(),
            hintText: 'Enter your city',
            prefixIcon: Icon(Icons.location_city, color: Colors.teal.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Phone
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: GoogleFonts.poppins(),
            hintText: 'Enter your phone number',
            prefixIcon: Icon(Icons.phone, color: Colors.teal.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Notes
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            labelStyle: GoogleFonts.poppins(),
            hintText: 'Any special instructions',
            prefixIcon: Icon(Icons.notes, color: Colors.teal.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment method',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Credit Card Option
        _buildPaymentOption(
          value: 'credit_card',
          icon: Icons.credit_card,
          label: 'Credit card',
        ),
        
        const SizedBox(height: 12),
        
        // Cash on Delivery Option
        _buildPaymentOption(
          value: 'cash_on_delivery',
          icon: Icons.money,
          label: 'Cash on delivery',
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade700,
              size: 24,
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.teal.shade600 : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.shade600,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Product Items
        ...widget.cartItems.map((item) => _buildOrderItem(item)),
        
        const SizedBox(height: 16),
        
        // Order Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal :', 'EGP ${widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Delivery fees :', 'EGP ${widget.deliveryFees.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Taxes :', 'EGP ${widget.taxes.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Discount:', '-EGP ${widget.discount.toStringAsFixed(2)}', isDiscount: true),
              const Divider(height: 24, thickness: 1),
              _buildSummaryRow('Total', 'EGP ${widget.total.toStringAsFixed(2)}', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
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
                          size: 25,
                          color: Colors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      Icons.shopping_bag,
                      size: 25,
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
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.quantity}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Price
          Text(
            'EGP ${item.totalPrice.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
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

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: _isPlacingOrder
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Place order',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    // Validate fields
    if (_streetController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your street address');
      return;
    }
    if (_cityController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your city');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final deliveryAddress = '${_streetController.text}, ${_cityController.text}, ${_countryController.text}';
      
      final orderId = await _productService.placeOrder(
        items: widget.cartItems,
        deliveryAddress: deliveryAddress,
        phone: _phoneController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        deliveryFee: widget.deliveryFees,
      );

      if (orderId != null && mounted) {
        _showOrderConfirmationDialog(orderId);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error placing order: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showOrderConfirmationDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.teal.shade600, size: 28),
              const SizedBox(width: 12),
              Text(
                'Order Placed!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your order has been placed successfully!',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 12),
              Text(
                'Order ID: ${orderId.substring(0, 8)}...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment: ${selectedPaymentMethod == 'credit_card' ? 'Credit Card' : 'Cash on Delivery'}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: EGP ${widget.total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to cart
                Navigator.pop(context); // Go back to market
              },
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  color: Colors.teal.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
