import 'package:bus_ticket_app/features/customer/viewmodels/my_tickets_viewmodel.dart';
import 'package:bus_ticket_app/widgets/my_ticket_widgets/EmptyTicketWidget.dart';
import 'package:bus_ticket_app/widgets/my_ticket_widgets/ticket_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

class MyTicketsPages extends StatefulWidget {
  const MyTicketsPages({super.key});

  @override
  State<MyTicketsPages> createState() => _MyTicketsPagesState();
}

class _MyTicketsPagesState extends State<MyTicketsPages> {
  late MyTicketsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I<MyTicketsViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Đơn hàng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _viewModel.fetchOrders(),
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Làm mới',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                child: const TabBar(
                  indicatorColor: Color(0xFF1E88E5),
                  indicatorWeight: 3,
                  labelColor: Color(0xFF1E88E5),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelColor: Colors.grey,
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                  tabs: [
                    Tab(text: 'Hiện tại'),
                    Tab(text: 'Đã đi'),
                    Tab(text: 'Đã hủy'),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<MyTicketsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (viewModel.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                viewModel.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => viewModel.fetchOrders(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return TabBarView(
                      children: [
                        _buildOrderList(viewModel.currentOrders),
                        _buildOrderList(viewModel.pastOrders),
                        _buildOrderList(viewModel.cancelledOrders),
                      ],
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

  Widget _buildOrderList(List orders) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _viewModel.fetchOrders(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: const EmptyTicketWidget(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return TicketCardWidget(
            order: orders[index],
          );
        },
      ),
    );
  }
}
