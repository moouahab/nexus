part of '../login_page.dart';

class _CenterDivider extends StatelessWidget {
  const _CenterDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.18);
    final segmentColor = isDark
        ? Colors.white.withValues(alpha: 0.34)
        : Colors.black.withValues(alpha: 0.22);

    return SizedBox(
      width: 42,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 72,
                bottom: constraints.maxHeight * 0.48,
                child: Container(width: 0.7, color: lineColor),
              ),
              Positioned(
                top: constraints.maxHeight * 0.50,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: NexusBrand.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NexusBrand.red.withValues(alpha: 0.45),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.56,
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Container(
                        width: index == 4 ? 1 : 7,
                        height: index == 4 ? 140 : 4,
                        color: segmentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
