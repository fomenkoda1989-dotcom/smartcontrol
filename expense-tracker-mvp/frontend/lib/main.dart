import 'package:flutter/material.dart';
import 'screens/upload_page.dart';
import 'screens/receipt_list_page.dart';
import 'screens/receipt_detail_page.dart';
import 'screens/monthly_summary_page.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        // Handle receipt detail route with ID parameter
        if (settings.name?.startsWith('/receipt/') ?? false) {
          final id = settings.name!.substring('/receipt/'.length);
          return MaterialPageRoute(
            builder: (context) => ReceiptDetailPage(receiptId: id),
          );
        }

        // Handle other named routes
        switch (settings.name) {
          case '/upload':
            return MaterialPageRoute(
              builder: (context) => const UploadPage(),
            );
          case '/receipts':
            return MaterialPageRoute(
              builder: (context) => const ReceiptListPage(),
            );
          case '/summary':
            return MaterialPageRoute(
              builder: (context) => const MonthlySummaryPage(),
            );
          default:
            return null;
        }
      },
    );
  }
}

/// Home page with navigation to main features
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              // App title
              Text(
                'Expense Tracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              // App description
              Text(
                'Track your expenses from receipt photos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Navigation cards
              _buildNavigationCard(
                context: context,
                title: 'Upload Receipt',
                description: 'Take or upload a receipt photo',
                icon: Icons.upload_file,
                color: Colors.blue,
                route: '/upload',
              ),

              const SizedBox(height: 16),

              _buildNavigationCard(
                context: context,
                title: 'My Receipts',
                description: 'View all your receipts',
                icon: Icons.receipt_long,
                color: Colors.green,
                route: '/receipts',
              ),

              const SizedBox(height: 16),

              _buildNavigationCard(
                context: context,
                title: 'Monthly Summary',
                description: 'View spending statistics',
                icon: Icons.bar_chart,
                color: Colors.orange,
                route: '/summary',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return SizedBox(
      width: 400,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),

                const SizedBox(width: 20),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
