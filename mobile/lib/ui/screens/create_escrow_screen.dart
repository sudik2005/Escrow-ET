import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exception.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../widgets/app_controls.dart';
import '../widgets/brand_card.dart';

class CreateEscrowScreen extends ConsumerStatefulWidget {
  const CreateEscrowScreen({super.key});

  @override
  ConsumerState<CreateEscrowScreen> createState() => _CreateEscrowScreenState();
}

class _CreateEscrowScreenState extends ConsumerState<CreateEscrowScreen> {
  final _buyerPhone = TextEditingController();
  final _itemName = TextEditingController();
  final _amount = TextEditingController();
  final _pin = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _buyerPhone.dispose();
    _itemName.dispose();
    _amount.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = ref.read(authControllerProvider).session?.token;
    final phone = _buyerPhone.text.trim();
    final item = _itemName.text.trim();
    final amount = _amount.text.trim();
    final pin = _pin.text.trim();
    if (token == null || phone.isEmpty || item.isEmpty || amount.isEmpty) {
      return;
    }
    if (pin.length < 4) {
      setState(() => _error = 'PIN must be at least 4 characters.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(escrowApiProvider).create(
        token: token,
        buyerPhone: phone,
        itemName: item,
        amount: amount,
        pin: pin,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = 'Something went wrong. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New escrow')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          BrandCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hold the buyer’s payment until they confirm delivery.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _buyerPhone,
                    label: 'Buyer phone',
                    hint: '+2519...',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _itemName,
                    label: 'Item',
                    hint: 'What is being sold',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _amount,
                    label: 'Amount (ETB)',
                    hint: '850.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _pin,
                    label: 'Delivery PIN',
                    hint: '4–12 characters',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(label: 'Create escrow', busy: _busy, onPressed: _submit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
