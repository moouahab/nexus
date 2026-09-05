part of '../login_page.dart';

class _DesktopRegisterLayout extends StatelessWidget {
  const _DesktopRegisterLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 50, child: _BrandPanel(compact: false)),
        const _CenterDivider(),
        Expanded(
          flex: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 56),
            child: _ScaleToFit(
              width: 660,
              height: 820,
              alignment: const Alignment(-1, -0.2),
              child: Padding(
                padding: const EdgeInsets.only(left: 56, right: 40),
                child: form,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactRegisterLayout extends StatelessWidget {
  const _CompactRegisterLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: _ScaleToFit(
        width: 430,
        height: 1180,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const _BrandPanel(compact: true),
            const SizedBox(height: 24),
            SizedBox(width: 430, child: form),
          ],
        ),
      ),
    );
  }
}

class _TabletPortraitRegisterLayout extends StatelessWidget {
  const _TabletPortraitRegisterLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 56),
      child: _ScaleToFit(
        width: 600,
        height: 1280,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const _BrandPanel(compact: true),
            const SizedBox(height: 42),
            SizedBox(width: 600, child: form),
          ],
        ),
      ),
    );
  }
}

class _TabletLandscapeRegisterLayout extends StatelessWidget {
  const _TabletLandscapeRegisterLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 46,
          child: _ScaleToFit(
            width: 560,
            height: 430,
            child: _BrandPanel(compact: true),
          ),
        ),
        const _CenterDivider(),
        Expanded(
          flex: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _ScaleToFit(
              width: 560,
              height: 980,
              alignment: Alignment.centerLeft,
              child: form,
            ),
          ),
        ),
      ],
    );
  }
}
