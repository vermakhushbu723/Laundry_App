import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Order Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 20),

                  // Service Details
                  _buildSectionCard(
                    'Service Details',
                    Icons.cleaning_services,
                    [
                      _buildDetailRow(
                        'Service Name',
                        widget.order.serviceName,
                        Icons.label_outline,
                      ),
                      _buildDetailRow(
                        'Order ID',
                        '#${widget.order.id}',
                        Icons.tag,
                      ),
                      if (widget.order.amount != null)
                        _buildDetailRow(
                          'Amount',
                          '₹${widget.order.amount!.toStringAsFixed(0)}',
                          Icons.currency_rupee,
                          isHighlight: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pickup Details
                  _buildSectionCard('Pickup Details', Icons.local_shipping, [
                    _buildDetailRow(
                      'Pickup Date',
                      '${widget.order.pickupDate.day}/${widget.order.pickupDate.month}/${widget.order.pickupDate.year}',
                      Icons.calendar_today,
                    ),
                    _buildDetailRow(
                      'Pickup Time',
                      widget.order.pickupTime,
                      Icons.access_time,
                    ),
                    if (widget.order.address != null)
                      _buildDetailRow(
                        'Address',
                        widget.order.address!,
                        Icons.location_on,
                        maxLines: 3,
                      ),
                  ]),
                  const SizedBox(height: 20),

                  // Timeline
                  _buildSectionCard('Order Timeline', Icons.timeline, [
                    _buildTimeline(),
                  ]),

                  // Notes
                  if (widget.order.notes != null &&
                      widget.order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionCard('Notes', Icons.note, [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.order.notes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (widget.order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        statusMessage = 'Your order is pending confirmation';
        break;
      case OrderStatus.picked:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping_outlined;
        statusMessage = 'Your order has been picked up';
        break;
      case OrderStatus.inProcess:
        statusColor = Colors.purple;
        statusIcon = Icons.autorenew;
        statusMessage = 'Your order is being processed';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusMessage = 'Your order has been delivered';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusMessage = 'This order was cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.getStatusText(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlight ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlight ? 20 : 15,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                    color: isHighlight
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final List<Map<String, dynamic>> timelineSteps = [
      {
        'title': 'Order Placed',
        'completed': true,
        'date': widget.order.createdAt,
      },
      {
        'title': 'Pickup Scheduled',
        'completed': widget.order.status != OrderStatus.pending,
        'date': widget.order.status != OrderStatus.pending
            ? widget.order.pickupDate
            : null,
      },
      {
        'title': 'In Process',
        'completed':
            widget.order.status == OrderStatus.inProcess ||
            widget.order.status == OrderStatus.delivered,
        'date': null,
      },
      {
        'title': 'Delivered',
        'completed': widget.order.status == OrderStatus.delivered,
        'date': widget.order.status == OrderStatus.delivered
            ? widget.order.updatedAt
            : null,
      },
    ];

    if (widget.order.status == OrderStatus.cancelled) {
      return Column(
        children: [
          _buildTimelineItem(
            'Order Placed',
            true,
            widget.order.createdAt,
            false,
          ),
          _buildTimelineItem(
            'Order Cancelled',
            true,
            widget.order.updatedAt,
            true,
            isLast: true,
          ),
        ],
      );
    }

    return Column(
      children: List.generate(timelineSteps.length, (index) {
        final step = timelineSteps[index];
        return _buildTimelineItem(
          step['title'],
          step['completed'],
          step['date'],
          false,
          isLast: index == timelineSteps.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineItem(
    String title,
    bool completed,
    DateTime? date,
    bool isCancelled, {
    bool isLast = false,
  }) {
    final color = isCancelled
        ? Colors.red
        : completed
        ? AppColors.primary
        : AppColors.textSecondary.withOpacity(0.3);

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: completed
                  ? Icon(
                      isCancelled ? Icons.close : Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            if (!isLast) Container(width: 2, height: 40, color: color),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
                  color: completed
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.order.status == OrderStatus.delivered ||
        widget.order.status == OrderStatus.cancelled) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reorder,
              icon: const Icon(Icons.refresh),
              label: const Text('Reorder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (widget.order.status == OrderStatus.delivered) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _rateService,
                icon: const Icon(Icons.star_outline),
                label: const Text('Rate Service'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    if (widget.order.status == OrderStatus.pending) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _contactSupport,
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cancelOrder,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _trackOrder,
        icon: const Icon(Icons.my_location),
        label: const Text('Track Order'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel order #${widget.order.id}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _orderService.cancelOrder(widget.order.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate order was cancelled
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel order: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _reorder() {
    // TODO: Navigate to service booking with pre-filled details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to service booking...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _rateService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How would you rate our service?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star_outline, size: 32),
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thank you for rating ${index + 1} stars!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _trackOrder() {
    // TODO: Navigate to live tracking screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live tracking coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _contactSupport() {
    // TODO: Navigate to support screen or open chat
    Navigator.pushNamed(context, '/support');
  }
}
