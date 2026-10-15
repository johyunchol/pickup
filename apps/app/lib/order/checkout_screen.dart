import 'package:app_api/app_api.dart';
import 'package:app_core/app_core.dart';
import 'package:app_ui/app_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../cart.dart';
import 'order_widgets.dart';

/// 장바구니를 확인하고 닉네임을 넣어 주문한다. 주문이 되면 그 [Order] 를 들고 돌아간다.
///
/// pickup.pen 에 따로 그린 화면은 없어서 "04 내 주문 상태" 의 카드·버튼 모양을 따른다.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.api, required this.cart});

  final PickupApi api;
  final Cart cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  /// 계약(packages/contract)의 CreateOrderBody.nickname 과 같은 길이 제한
  static const _nicknameMax = 12;

  final _nickname = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _order() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final order = await widget.api.orders.createOrder(
        body: CreateOrderBody(
          nickname: _nickname.text.trim(),
          items: widget.cart.toOrderItems(),
        ),
      );
      if (mounted) Navigator.of(context).pop(order);
    } on Exception catch (e) {
      // 서버가 거절했으면(품절 등) 그 이유를, 닿지 못했으면 다시 시도하라고 보여 준다.
      final message = e is DioException ? e.serverMessage : null;
      setState(() => _error = message ?? '주문을 보내지 못했어요. 잠시 뒤 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cart = widget.cart;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NavBar(title: '주문하기'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: PickupSpace.s5,
                  vertical: PickupSpace.s3,
                ),
                children: [
                  SectionCard(
                    children: [
                      Text('주문 내역', style: text.titleMedium),
                      for (final l in cart.lines)
                        AmountRow(
                          label: '${l.item.name} × ${l.quantity}',
                          amount: l.item.price * l.quantity,
                        ),
                      TotalRow(total: cart.total),
                    ],
                  ),
                  const SizedBox(height: PickupSpace.s5),
                  SectionCard(
                    children: [
                      Text('닉네임', style: text.titleMedium),
                      Text(
                        '음료가 나오면 주문 번호와 함께 불러 드려요.',
                        style: text.bodyMedium?.copyWith(
                          color: PickupColors.textMuted,
                        ),
                      ),
                      TextField(
                        controller: _nickname,
                        maxLength: _nicknameMax,
                        enabled: !_sending,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _canOrder ? _order() : null,
                        decoration: InputDecoration(
                          hintText: '예: 도윤',
                          filled: true,
                          fillColor: PickupColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              PickupRadius.md,
                            ),
                            borderSide: const BorderSide(
                              color: PickupColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              PickupRadius.md,
                            ),
                            borderSide: const BorderSide(
                              color: PickupColors.border,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: PickupSpace.s4),
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
                        _error!,
                        style: text.bodyMedium?.copyWith(
                          color: PickupColors.danger,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PickupSpace.s4,
                PickupSpace.s3,
                PickupSpace.s4,
                PickupSpace.s3,
              ),
              child: FilledButton(
                onPressed: _canOrder ? _order : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PickupRadius.lg),
                  ),
                  // 테마의 글자 스타일을 그대로 써야 번들 글꼴이 따라온다.
                  textStyle: text.titleMedium,
                ),
                child: Text(
                  _sending ? '주문 보내는 중…' : '${formatPrice(cart.total)} 주문하기',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canOrder =>
      !_sending && !widget.cart.isEmpty && _nickname.text.trim().isNotEmpty;
}
