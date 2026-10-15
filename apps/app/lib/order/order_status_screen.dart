import 'dart:async';

import 'package:app_api/app_api.dart';
import 'package:app_core/app_core.dart';
import 'package:app_ui/app_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../labels.dart';
import '../shot.dart';
import 'order_widgets.dart';

/// 손님 앱의 갱신 주기 — 사장님이 상태를 넘기면 늦어도 이만큼 뒤에 보인다.
const orderPollInterval = Duration(seconds: 3);

/// 진행 막대의 단계 — 취소는 여기서 빠진다.
const _steps = [
  OrderStatus.received,
  OrderStatus.making,
  OrderStatus.ready,
  OrderStatus.done,
];

// 화면 디자인: design/pickup.pen 의 "04 손님 · 내 주문 상태"
class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({
    super.key,
    required this.api,
    required this.initial,
  });

  final PickupApi api;

  /// 주문하자마자 받은 값 — 첫 화면은 이걸로 바로 그리고, 그 뒤로 폴링한다.
  final Order initial;

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  late Order _order = widget.initial;
  Timer? _timer;
  bool _offline = false;
  bool _cancelling = false;
  String? _cancelError;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 한 번 불러오고 끝나면 다음을 예약한다 — 응답이 늦어도 요청이 겹치지 않는다.
  void _schedule() {
    if (_order.status == OrderStatus.done ||
        _order.status == OrderStatus.cancelled) {
      return;
    }
    _timer = Timer(orderPollInterval, _poll);
  }

  Future<void> _poll() async {
    try {
      final order = await widget.api.orders.getOrder(id: _order.id);
      if (!mounted) return;
      setState(() {
        _order = order;
        _offline = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _offline = true);
    }
    _schedule();
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주문을 취소할까요?'),
        content: const Text('만들기 시작하기 전까지만 취소할 수 있어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('그대로 둘게요'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: PickupColors.danger),
            child: const Text('주문 취소'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() {
      _cancelling = true;
      _cancelError = null;
    });
    try {
      final order = await widget.api.orders.cancelOrder(id: _order.id);
      if (!mounted) return;
      _timer?.cancel();
      setState(() => _order = order);
    } on Exception catch (e) {
      if (!mounted) return;
      // 그사이 제조가 시작됐으면 서버가 그 이유를 알려 준다 — 바뀐 상태도 바로 불러온다.
      final message = e is DioException ? e.serverMessage : null;
      setState(() => _cancelError = message ?? '취소하지 못했어요. 잠시 뒤 다시 시도해 주세요.');
      _timer?.cancel();
      unawaited(_poll());
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final order = _order;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NavBar(title: '내 주문'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: PickupSpace.s5,
                  vertical: PickupSpace.s3,
                ),
                children: [
                  _Hero(order: order, offline: _offline),
                  const SizedBox(height: PickupSpace.s5),
                  if (order.status != OrderStatus.cancelled) ...[
                    _Progress(order: order),
                    const SizedBox(height: PickupSpace.s5),
                  ],
                  SectionCard(
                    children: [
                      Text('주문 내역', style: text.titleMedium),
                      for (final l in order.lines)
                        AmountRow(
                          label:
                              '${nameWithShot(l.name, l.extraShot)} × ${l.quantity}',
                          amount: l.amount,
                        ),
                      TotalRow(total: order.total),
                    ],
                  ),
                  if (order.status != OrderStatus.cancelled) ...[
                    const SizedBox(height: PickupSpace.s5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PickupSpace.s4,
                        vertical: PickupSpace.s3,
                      ),
                      decoration: BoxDecoration(
                        color: PickupColors.primarySoft,
                        borderRadius: BorderRadius.circular(PickupRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 20,
                            color: PickupColors.primary,
                          ),
                          const SizedBox(width: PickupSpace.s3),
                          Expanded(
                            child: Text(
                              '번호가 불리면 왼쪽 픽업대에서 받아 가세요',
                              style: text.bodyMedium?.copyWith(
                                color: PickupColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 제조가 시작되기 전(접수)까지만 취소할 수 있다. 취소하지 못한 이유도 여기에 — 스크롤하지 않아도 보이게.
            if (order.status == OrderStatus.received || _cancelError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PickupSpace.s4,
                  PickupSpace.s3,
                  PickupSpace.s4,
                  PickupSpace.s3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: PickupSpace.s3,
                  children: [
                    if (_cancelError != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PickupSpace.s4,
                          vertical: PickupSpace.s3,
                        ),
                        decoration: BoxDecoration(
                          color: PickupColors.dangerSoft,
                          borderRadius: BorderRadius.circular(PickupRadius.md),
                        ),
                        child: Text(
                          _cancelError!,
                          style: text.bodyMedium?.copyWith(
                            color: PickupColors.danger,
                          ),
                        ),
                      ),
                    if (order.status == OrderStatus.received)
                      OutlinedButton(
                        onPressed: _cancelling ? null : _cancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PickupColors.danger,
                          side: const BorderSide(color: PickupColors.border),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PickupRadius.lg,
                            ),
                          ),
                          textStyle: text.titleMedium,
                        ),
                        child: Text(_cancelling ? '취소하는 중…' : '주문 취소'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.order, required this.offline});

  final Order order;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = order.status;
    final muted = text.bodyMedium?.copyWith(color: PickupColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PickupSpace.s6,
        vertical: PickupSpace.s8,
      ),
      decoration: BoxDecoration(
        color: PickupColors.surface,
        borderRadius: BorderRadius.circular(PickupRadius.lg),
        border: Border.all(color: PickupColors.border),
      ),
      child: Column(
        children: [
          Text(
            '주문 번호',
            style: pickupFont(
              muted?.copyWith(fontWeight: PickupFontWeight.medium),
            ),
          ),
          Text(
            formatOrderNumber(order.number),
            style: text.displayLarge?.copyWith(
              color: PickupColors.primary,
              height: 1.1,
            ),
          ),
          Text('${order.nickname} 님의 주문', style: muted),
          const SizedBox(height: PickupSpace.s4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PickupSpace.s4,
              vertical: PickupSpace.s2,
            ),
            decoration: BoxDecoration(
              color: status.softColor,
              borderRadius: BorderRadius.circular(PickupRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 18, color: status.color),
                const SizedBox(width: PickupSpace.s2),
                Text(
                  status.headline,
                  style: text.titleMedium?.copyWith(color: status.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: PickupSpace.s2),
          Text(
            offline ? '연결이 끊겼어요 — 다시 연결하는 중…' : status.detail,
            style: offline
                ? muted?.copyWith(color: PickupColors.danger)
                : muted,
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final current = _steps.indexOf(order.status);
    final done = order.status == OrderStatus.done;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: PickupSpace.s1,
      children: [
        for (final (i, step) in _steps.indexed)
          Expanded(
            child: _Step(
              step: step,
              at: order.history.where((h) => h.status == step).firstOrNull?.at,
              // 지난 단계는 primary, 지금 단계는 그 상태의 색, 아직 안 온 단계는 흐리게
              color: i < current || (done && i == current)
                  ? PickupColors.primary
                  : i == current
                  ? step.color
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.at, required this.color});

  final OrderStatus step;
  final DateTime? at;

  /// null 이면 아직 오지 않은 단계
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final reached = color != null;
    final fg = color ?? PickupColors.textMuted;
    final local = at?.toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color ?? PickupColors.border,
            borderRadius: BorderRadius.circular(PickupRadius.pill),
          ),
        ),
        const SizedBox(height: PickupSpace.s3),
        Icon(step.icon, size: 20, color: fg),
        const SizedBox(height: PickupSpace.s1),
        Text(
          step.label,
          style: pickupFont(
            TextStyle(
              color: fg,
              fontSize: PickupFontSize.xs,
              fontWeight: reached
                  ? PickupFontWeight.bold
                  : PickupFontWeight.regular,
            ),
          ),
        ),
        Text(
          local == null
              ? ''
              : '${local.hour.toString().padLeft(2, '0')}:'
                    '${local.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: PickupColors.textMuted,
            fontSize: PickupFontSize.xs,
          ),
        ),
      ],
    );
  }
}
