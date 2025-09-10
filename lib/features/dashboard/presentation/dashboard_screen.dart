import 'dart:ui';

import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/core/utils/date_formatter.dart';
import 'package:dhanra/core/utils/get_bank_image.dart';
import 'package:dhanra/features/transactions/presentation/bank_transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'package:dhanra/features/widgets/shimmer_loading.dart';
import 'package:dhanra/features/transactions/presentation/all_transactions_screen.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'package:dhanra/features/transactions/presentation/add_edit_transaction_screen.dart';
import 'package:dhanra/features/transactions/presentation/banks_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedMonth = '';
  String currentMonth = '';

  String greeting = '';
  final LocalStorageService storage = LocalStorageService();
  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentMonth();
    getMessgae();
  }

  void _getCurrentMonth() {
    DateTime now = DateTime.now();
    final currentMonthIndex = now.month - 1;
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    currentMonth = monthNames[currentMonthIndex];
  }

  void getMessgae() {
    int hours = DateTime.now().hour;

    if (hours >= 1 && hours <= 12) {
      greeting = "Good Morning";
    } else if (hours >= 12 && hours <= 16) {
      greeting = "Good Afternoon";
    } else if (hours >= 16 && hours <= 21) {
      greeting = "Good Evening";
    } else if (hours >= 21 && hours <= 24) {
      greeting = "Good Night";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardBloc()..add(FetchDashboardSms(month: _selectedMonth)),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final isLoading = state.status == DashboardStatus.loading;
          final filteredMessages = state.transactionMessages;

          return Stack(
            alignment: Alignment.topLeft,
            children: [
              Gradients.gradient(
                top: -MediaQuery.of(context).size.height,
                left: -MediaQuery.of(context).size.width,
                right: 0,
                context: context,
              ),
              Image.asset(
                "assets/images/circle_ui.png",
                opacity: const AlwaysStoppedAnimation(.8),
                fit: BoxFit.cover,
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  scrolledUnderElevation: 0.0,
                  centerTitle: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        storage.userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // actions: [
                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   margin: const EdgeInsets.only(right: 15),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withAlpha(15),
                  //     borderRadius: BorderRadius.circular(15),
                  //     border: Border.all(
                  //       color: Colors.white.withAlpha(20),
                  //     ),
                  //   ),
                  //   child: const Icon(
                  //     Icons.notifications_none_rounded,
                  //   ),
                  // ),
                  // ],
                  backgroundColor: Colors.transparent,
                ),
                body: isLoading
                    ? _buildShimmerLoading()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNetAmountCard(
                                state.netAmount,
                                state.totalCreditedAmount,
                                state.totalDebitedAmount,
                                context),
                            const SizedBox(height: 40),
                            _buildTransactionMessagesSection(
                                context, filteredMessages),
                            const SizedBox(height: 20),
                            _buildAccountsSection(context),
                            const SizedBox(height: 80),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const ShimmerCard(height: 50),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: ShimmerDashboardCard()),
              SizedBox(width: 12),
              Expanded(child: ShimmerDashboardCard()),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: ShimmerDashboardCard()),
              SizedBox(width: 12),
              Expanded(child: ShimmerDashboardCard()),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerDashboardCard(isAmountCard: true),
          const SizedBox(height: 24),
          ShimmerLoadingList(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerTransactionItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildNetAmountCard(
    double netAmount,
    double totalCreditedAmount,
    double totalDebitedAmount,
    BuildContext context,
  ) {
    final isPositive = netAmount >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withAlpha(20),
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Opacity(
                    opacity: .03,
                    child: Image.asset(
                      "assets/images/ruppe.png",
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart_outlined),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text(
                            "Dhanra ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                          ),
                          Text(
                            ' $currentMonth',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  RotationTransition(
                                    turns: AlwaysStoppedAnimation(90 / 360),
                                    child: Icon(Icons.arrow_outward_rounded),
                                  ),
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${totalCreditedAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.arrow_outward_rounded),
                                  Text(
                                    'Spends',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${totalDebitedAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -60,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  icon,
                                  color: color,
                                ),
                              ],
                            ),
                            Text(
                              '₹${netAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            final dashboardBloc = context.read<DashboardBloc>();
                            final banks = dashboardBloc.state.accountSummaries
                                .map((a) => a['bank'] as String)
                                .toSet()
                                .toList();
                            banks.add('Cash');
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (context) => TransactionsBloc(),
                                  child: AddEditTransactionScreen(banks: banks),
                                ),
                              ),
                            )
                                .then((_) {
                              if (mounted) {
                                dashboardBloc.add(
                                    FetchDashboardSms(month: _selectedMonth));
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionMessagesSection(
      BuildContext context, List<Map<String, dynamic>> messages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final dashboardBloc = context.read<DashboardBloc>();
                  final banks = dashboardBloc.state.accountSummaries
                      .map((a) => a['bank'] as String)
                      .toSet()
                      .toList();
                  banks.add('Cash');
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) =>
                            TransactionsBloc()..add(const LoadTransactions()),
                        child: AllTransactionsScreen(banks: banks),
                      ),
                    ),
                  )
                      .then((_) {
                    if (mounted) {
                      dashboardBloc
                          .add(FetchDashboardSms(month: _selectedMonth));
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          if (messages.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No transaction messages found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length <= 5 ? messages.length : 5,
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (ctx, index) {
                final message = messages[index];
                final isCredit = message['type'] == 'Credit';
                final color = isCredit ? Colors.green : Colors.red;
                String formattedDate =
                    DateFormatter.formatDate(message['date']);
                String date = formattedDate == 'Invalid date format'
                    ? 'Unknown'
                    : formattedDate;
                // final icon = isCredit ? Icons.trending_up : Icons.trending_down;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 8,
                  minTileHeight: 60,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // color: color.withAlpha(30),
                        color: CategoryKeyWord.parseHexColor(
                                CategoryKeyWord.getIconAndColor(
                                        message['category'])['color'] ??
                                    '')
                            .withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        CategoryKeyWord.getIconAndColor(
                                message['category'])['icon'] ??
                            '',
                      ),
                    ),
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          message['upiIdOrSenderName'] ?? 'Unknown Bank',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        '₹${message['amount'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $date',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    final bloc = context.read<DashboardBloc>();
                    final banks = bloc.state.accountSummaries
                        .map((a) => a['bank'] as String)
                        .toSet()
                        .toList();
                    banks.add('Cash');
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => TransactionsBloc(),
                          child: AddEditTransactionScreen(
                            banks: banks,
                            transaction: message,
                          ),
                        ),
                      ),
                    )
                        .then((_) {
                      bloc.add(FetchDashboardSms(month: _selectedMonth));
                    });
                    _showMessageDetails(message);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final accountSummaries = state.accountSummaries;

        if (accountSummaries.isEmpty) {
          return Container(
            height: 200,
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              border: Border.all(
                color: Colors.white.withAlpha(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "No accounts found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Found ${state.transactionMessages.length} transactions",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Check if SMS parsing is working correctly",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Opacity(
              opacity: .06,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  "assets/images/border.png",
                  height: 230,
                  width: MediaQuery.of(context).size.width - 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 230,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withAlpha(80),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Accounts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final dashboardBloc = context.read<DashboardBloc>();
                          final banks = dashboardBloc.state.accountSummaries
                              .map((a) => a['bank'] as String)
                              .toSet()
                              .toList();
                          banks.add('Cash');
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => BanksListScreen(banks: banks),
                            ),
                          )
                              .then((_) {
                            if (mounted) {
                              dashboardBloc.add(
                                  FetchDashboardSms(month: _selectedMonth));
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withAlpha(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: accountSummaries.length,
                  itemBuilder: (context, index) {
                    final account = accountSummaries[index];
                    final bank = account['bank'] ?? 'Unknown Bank';
                    final lastFourDigits = account['lastFourDigits'] ?? '';
                    final totalReceived = account['totalReceived'] ?? 0.0;
                    final totalSpent = account['totalSpent'] ?? 0.0;
                    final transactionCount = account['transactionCount'] ?? 0;
                    final hasBalanceSms = account['hasBalanceSms'] ?? false;
                    return GestureDetector(
                      onTap: () {
                        final dashboardBloc = context.read<DashboardBloc>();
                        final banks = dashboardBloc.state.accountSummaries
                            .map((a) => a['bank'] as String)
                            .toSet()
                            .toList();
                        banks.add('Cash');
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) => BankTransactionsScreen(
                              bank: bank,
                              banks: banks,
                            ),
                          ),
                        )
                            .then((_) {
                          if (mounted) {
                            dashboardBloc
                                .add(FetchDashboardSms(month: _selectedMonth));
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .8,
                        margin: EdgeInsets.only(
                            right: (index + 1) == accountSummaries.length
                                ? 40
                                : 12,
                            left: index == 0 ? 24 : 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withAlpha(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: GetBankImage.isCashBank(bank)
                                      ? const Icon(
                                          Icons.account_balance_wallet,
                                          size: 26,
                                          color: Colors.black,
                                        )
                                      : GetBankImage.getBankImagePath(bank) ==
                                              null
                                          ? const Icon(
                                              Icons.account_balance,
                                              size: 26,
                                              color: Colors.black,
                                            )
                                          : Image.asset(
                                              GetBankImage.getBankImagePath(
                                                      bank) ??
                                                  '',
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.cover,
                                            ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bank,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (lastFourDigits.isNotEmpty)
                                        Text(
                                          '****$lastFourDigits',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              'Received',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                          ],
                                        ),
                                        if (hasBalanceSms) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withAlpha(50),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'LIVE',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '₹${totalReceived.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        //  netBalance >= 0
                                        //     ? Colors.green
                                        //     : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Spent',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '₹${totalSpent.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$transactionCount transactions',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessageDetails(Map<String, dynamic> message) {
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text(message['bank'] ?? 'Unknown Bank'),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text('Amount: ₹${message['amount'] ?? 'Unknown'}'),
    //         const SizedBox(height: 8),
    //         Text('Type: ${message['type'] ?? 'Unknown'}'),
    //         const SizedBox(height: 8),
    //         Text('Date: ${message['date'] ?? 'Unknown'}'),
    //         const SizedBox(height: 8),
    //         Text('Sender: ${message['sender'] ?? 'Unknown'}'),
    //         const SizedBox(height: 16),
    //         const Text(
    //           'Message:',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         const SizedBox(height: 4),
    //         Text(message['body'] ?? 'No message content'),
    //       ],
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text('Close'),
    //       ),
    //     ],
    //   ),
    // );
  }
}
