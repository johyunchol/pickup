import 'package:app_core/app_core.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

// 주문하기·내 주문 화면이 같이 쓰는 조각. 디자인: design/pickup.pen 의 "04 손님 · 내 주문 상태"

/// 가운데 제목과 뒤로 가기 버튼
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PickupSpace.s4),
        child: Row(
          children: [
            IconButton(
              tooltip: '뒤로',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.chevron_left_rounded, size: 26),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: PickupFontSize.lg),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

/// 흰 바탕 테두리 카드 — 자식 사이를 space-3 으로 띄운다.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PickupSpace.s5),
      decoration: BoxDecoration(
        color: PickupColors.surface,
        borderRadius: BorderRadius.circular(PickupRadius.lg),
        border: Border.all(color: PickupColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PickupSpace.s3,
        children: children,
      ),
    );
  }
}

/// "아메리카노 × 1 ........ 4,500원"
class AmountRow extends StatelessWidget {
  const AmountRow({super.key, required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(label, style: text.bodyMedium)),
        Text(
          formatPrice(amount),
          style: text.bodyMedium?.copyWith(color: PickupColors.textMuted),
        ),
      ],
    );
  }
}

/// 위에 줄을 긋고 합계를 굵게
class TotalRow extends StatelessWidget {
  const TotalRow({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.only(top: PickupSpace.s3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PickupColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '합계 · 매장에서 결제',
              style: pickupFont(
                text.bodyMedium?.copyWith(fontWeight: PickupFontWeight.medium),
              ),
            ),
          ),
          Text(formatPrice(total), style: text.titleMedium),
        ],
      ),
    );
  }
}
