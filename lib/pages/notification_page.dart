import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Flash Sale Started',
      message: 'Up to 70% off on electronics',
      time: 'Now',
      type: NotificationType.promotion,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Order Shipped',
      message: 'Your order #12345 is on the way',
      time: '2h ago',
      type: NotificationType.order,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Price Drop',
      message: 'Item in wishlist dropped by 25%',
      time: '5h ago',
      type: NotificationType.price,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'New Collection',
      message: 'Latest fashion arrivals',
      time: '1d ago',
      type: NotificationType.newArrival,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Limited Stock',
      message: 'Few items left of viewed product',
      time: '2d ago',
      type: NotificationType.stock,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Minimal App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),

          // Notifications List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildNotificationItem(notifications[index]);
            }, childCount: notifications.length),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1),
              borderRadius: BorderRadius.circular(16),
              color: notification.isRead ? Colors.white : Colors.grey.shade50,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Abstract Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getNotificationColor(
                      notification.type,
                    ).withOpacity(0.1),
                  ),
                  child: Center(child: _getNotificationIcon(notification.type)),
                ),

                SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time and Status
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                notification.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(
                                      notification.type,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      // Abstract Divider
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade100,
                              Colors.grey.shade300,
                              Colors.grey.shade100,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return _buildAbstractIcon(Icons.local_offer_outlined);
      case NotificationType.order:
        return _buildAbstractIcon(Icons.local_shipping_outlined);
      case NotificationType.price:
        return _buildAbstractIcon(Icons.attach_money_outlined);
      case NotificationType.newArrival:
        return _buildAbstractIcon(Icons.favorite_outline);
      case NotificationType.stock:
        return _buildAbstractIcon(Icons.inventory_2_outlined);
    }
  }

  Widget _buildAbstractIcon(IconData icon) {
    return Icon(icon, size: 18, color: Colors.black54);
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.price:
        return Colors.green;
      case NotificationType.newArrival:
        return Colors.pink;
      case NotificationType.stock:
        return Colors.amber;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    // Show minimal detail view
    _showMinimalDetail(notification);
  }

  void _showMinimalDetail(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notification.type,
                ).withOpacity(0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.1),
                    ),
                    child: Center(
                      child: _getNotificationIcon(notification.type),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                notification.message,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Dismiss'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Handle action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text('View'),
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
}

enum NotificationType { promotion, order, price, newArrival, stock }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}
