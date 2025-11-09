import 'dart:convert';

import 'package:afghan_bazar/blocs/my_orders_bloc.dart';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/models/order_model.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List of orders (simulating dynamic data)
  List<Order> orders = [
    Order(
      orderNo: "105312",
      date: "Aug 30, 2025",
      productName: "SEGO Magic Power | Smart Camera | Bluetooth",
      price: "Af 3,399",
      qty: 1,
      total: "Af 3,498",
      status: "Processing",
    ),
    Order(
      orderNo: "105311",
      date: "Aug 30, 2025",
      productName: "SEGO Magic Power | Smart Camera | Bluetooth",
      price: "Af 3,399",
      qty: 1,
      total: "Af 3,498",
      status: "Paid",
    ),
    // Add more orders here if needed
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final bloc = context.read<MyOrdersBloc>();

    // load initial data
    bloc.getData(null);

    // listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // avoid premature triggers

      switch (_tabController.index) {
        case 0:
          bloc.getData(null); // all orders
          break;
        case 1:
          bloc.getData('paid'); // unpaid orders
          break;
        case 2:
          bloc.getData('delivered'); // to receive orders
          break;
      }
    });
  }

  void _onOrder(int id) async {
    try {
      var response = await AuthService().authGet('ads-details?ad_id=$id');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonList = json.decode(response.body);

        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(product: data.ads[0]),
          ),
        );
      } else {
        throw Exception('Failed to load ads. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ads: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MyOrdersBloc>();
    var items = bloc.getAds();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "All Orders"),
            Tab(text: "To Pay"),
            Tab(text: "To Receive"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (items.isEmpty)
            _emptyPage("No orders")
          else
            _ordersList(items), // Will loop through the orders here
          if (items.isEmpty)
            _emptyPage("No pending payments")
          else
            _ordersList(items),
          if (items.isEmpty)
            _emptyPage("No items to receive")
          else
            _ordersList(items),
        ],
      ),
    );
  }

  Widget _ordersList(List<OrderModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length, // Dynamically count number of items
      itemBuilder: (context, index) {
        final order = items[index]; // Get the current order
        String imageUrl = order.adPhotos?.isNotEmpty == true
            ? "${AuthService.baseHost}/${order.adPhotos![0]}"
            : 'https://via.placeholder.com/150';

        return _orderCard(
          adId: order.adId,
          orderNo: order.id.toString(),
          date: order.createdAt,
          productName: order.adTitle ?? '',
          price: order.price.toString(),
          qty: order.quantity,
          total: order.totalAmount.toString(),
          status: order.status,
          imageUrl: imageUrl,
        );
      },
    );
  }

  Widget _orderCard({
    required int adId,
    required String orderNo,
    required String date,
    required String productName,
    required String price,
    required int qty,
    required String total,
    required String status,
    required String imageUrl, // Dynamic image URL
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Material(
        color: Colors.transparent, // keeps card background
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.green.withOpacity(0.2),
          onTap: () => _onOrder(adId),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order No. $orderNo",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Placed on $date",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const Divider(height: 20),

                // Product Info
                Row(
                  children: [
                    // Dynamic image display
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl, // Use the dynamic image URL
                                fit: BoxFit.cover,
                                height: 55,
                                width: 55,
                              )
                            : const Icon(
                                Icons.image,
                                size: 30,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "$price x$qty",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Total $qty Item(s) $total",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyPage(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

class Order {
  final String orderNo;
  final String date;
  final String productName;
  final String price;
  final int qty;
  final String total;
  final String status;

  Order({
    required this.orderNo,
    required this.date,
    required this.productName,
    required this.price,
    required this.qty,
    required this.total,
    required this.status,
  });
}
