import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/receipt.dart';

/// Screen showing list of all uploaded receipts
class ReceiptListPage extends StatefulWidget {
  const ReceiptListPage({super.key});

  @override
  State<ReceiptListPage> createState() => _ReceiptListPageState();
}

class _ReceiptListPageState extends State<ReceiptListPage> {
  final ApiService _apiService = ApiService();

  List<Receipt>? _receipts;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  /// Load receipts from API
  Future<void> _loadReceipts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final receipts = await _apiService.getReceipts();
      setState(() {
        _receipts = receipts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Format date string for display
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Receipts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReceipts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load receipts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadReceipts,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (_receipts == null || _receipts!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No receipts yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload your first receipt to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/upload');
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload Receipt'),
              ),
            ],
          ),
        ),
      );
    }

    // List of receipts
    return RefreshIndicator(
      onRefresh: _loadReceipts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _receipts!.length,
        itemBuilder: (context, index) {
          final receipt = _receipts![index];
          return _buildReceiptCard(receipt);
        },
      ),
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Navigate to detail page
          Navigator.pushNamed(
            context,
            '/receipt/${receipt.id}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Store icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              // Receipt info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.store,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(receipt.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (receipt.itemCount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${receipt.itemCount} items',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Total amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${receipt.currencySymbol}${receipt.total}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
