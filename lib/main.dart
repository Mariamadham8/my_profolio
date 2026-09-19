import 'package:flutter/material.dart';
import 'package:mariam_portfolio/core/theme/app_theme.dart';
import 'package:mariam_portfolio/features/portfolio/portfolio_page.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mariam Adham | Flutter Engineer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const PortfolioPage(),
    );
  }
}
