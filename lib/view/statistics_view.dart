
import 'package:akilli_ajanda_front/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../view_model/statistics_view_model.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel(homeViewModel.tasks),
      child: Consumer<StatisticsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('İstatistikler'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade300,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildChartCard(context, viewModel),
                      const SizedBox(height: 16),
                      _buildInfoCard('Toplam Görev Sayısı', viewModel.totalTaskCount.toString(), context),
                      _buildInfoCard('Tamamlanan Görevler', viewModel.completedTaskCount.toString(), context),
                      _buildInfoCard('Devam Eden Görevler', viewModel.inProgressTaskCount.toString(), context),
                      _buildInfoCard('Bekleyen Görevler', viewModel.pendingTaskCount.toString(), context),
                      _buildInfoCard('Kaçırılan Görevler', viewModel.missedTaskCount.toString(), context),
                      _buildInfoCard('İptal Edilen Görevler', viewModel.cancelledTaskCount.toString(), context),
                      const SizedBox(height: 8),
                      _buildInfoCard('Görev Tamamlama Oranı', '${(viewModel.taskCompletionRate * 100).toStringAsFixed(1)}%', context),
                      _buildInfoCard('En Verimli Gün', viewModel.mostProductiveDay, context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, StatisticsViewModel viewModel) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Görev Durum Dağılımı', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)),
                series: <CircularSeries<ChartData, String>>[
                  PieSeries<ChartData, String>(
                    dataSource: viewModel.taskStatusDistribution,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelMapper: (ChartData data, _) => '${data.y.toInt()}',
                    dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
