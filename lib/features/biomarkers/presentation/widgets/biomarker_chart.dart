import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/biomarker.dart';

class BiomarkerChart extends StatelessWidget {
  const BiomarkerChart({super.key, required this.biomarker});

  final Biomarker biomarker;

  @override
  Widget build(BuildContext context) {
    final List<BiomarkerReading> readings = biomarker.readings;
    if (readings.length < 2) {
      return const SizedBox(height: 180);
    }

    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < readings.length; i++)
        FlSpot(i.toDouble(), readings[i].value),
    ];

    final double minValue = readings
        .map((BiomarkerReading r) => r.value)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxValue = readings
        .map((BiomarkerReading r) => r.value)
        .reduce((double a, double b) => a > b ? a : b);
    final double padding = ((maxValue - minValue).abs() * 0.25).clamp(1, 40);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minValue - padding,
          maxY: maxValue + padding,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: (maxValue - minValue + padding * 2) / 4,
            getDrawingHorizontalLine: (double _) =>
                const FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (double value, TitleMeta meta) => Text(
                  value.toStringAsFixed(value.abs() < 10 ? 1 : 0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.round();
                  if (index < 0 || index >= readings.length) {
                    return const SizedBox.shrink();
                  }
                  if (readings.length > 6 && index.isOdd) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MMM').format(readings[index].recordedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: <HorizontalLine>[
              if (biomarker.referenceHigh != null)
                HorizontalLine(
                  y: biomarker.referenceHigh!,
                  color: AppColors.danger,
                  strokeWidth: 1,
                  dashArray: <int>[6, 4],
                ),
              if (biomarker.referenceLow != null)
                HorizontalLine(
                  y: biomarker.referenceLow!,
                  color: AppColors.info,
                  strokeWidth: 1,
                  dashArray: <int>[6, 4],
                ),
            ],
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot _) => AppColors.textPrimary,
              getTooltipItems: (List<LineBarSpot> spots) => spots
                  .map(
                    (LineBarSpot spot) => LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} ${biomarker.unit}',
                      TextStyle(
                        color: AppColors.textInverse,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter:
                    (FlSpot spot, double _, LineChartBarData bar, int index) =>
                        FlDotCirclePainter(
                          radius: index == spots.length - 1 ? 5 : 3,
                          color: AppColors.surface,
                          strokeWidth: 2.5,
                          strokeColor: AppColors.primary,
                        ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryTint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
