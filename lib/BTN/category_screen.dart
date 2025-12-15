import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:Nhom4_ShopOnline/BTN/models/category.dart';
import 'package:Nhom4_ShopOnline/BTN/models/product.dart';
import 'package:get/get.dart';
import 'package:Nhom4_ShopOnline/BTN/product_screen.dart';
import 'controllers/product_controller.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ControllerProduct _productController = Get.find();

  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedSort = 'Mặc định';
  bool _isGridView = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await ProductSnapshot.getProductsByCategoryWithSort(
        widget.category.id,
        _selectedSort,
      );

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Đã xảy ra lỗi khi tải sản phẩm.\n$e';
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = '';
        return AlertDialog(
          title: Text('Tìm sản phẩm'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Nhập tên sản phẩm...'),
            onChanged: (value) {
              searchText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (searchText.trim().isEmpty) return;
                setState(() {
                  _isLoading = true;
                });
                try {
                  final results = await ProductSnapshot.searchProducts(
                    widget.category.id,
                    searchText,
                  );
                  setState(() {
                    _products = results;
                    _isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _error = 'Lỗi tìm kiếm: $e';
                  });
                }
              },
              child: Text('Tìm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          widget.category.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: [
                    'Mặc định',
                    'Giá thấp đến cao',
                    'Giá cao đến thấp',
                    'Đánh giá cao nhất',
                    'Mới nhất'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSort = newValue!;
                    });
                    _loadProducts();
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải sản phẩm...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    return _buildProductGrid();
  }

  Widget _buildProductGrid() {
    if (_products.isEmpty) {
      return Center(child: Text('Không có sản phẩm nào.'));
    }

    return _isGridView
        ? GridView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductItem(product);
      },
    )
        : ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductItem(product);
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.to(() => ProductScreen(product: product,));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  product.img,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(product.price)}',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            RatingBarIndicator(
              rating: product.rate,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 16.0,
              direction: Axis.horizontal,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
