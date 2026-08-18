import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exception.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../widgets/app_controls.dart';

class NewPaymentScreen extends ConsumerStatefulWidget {
  const NewPaymentScreen({super.key});

  @override
  ConsumerState<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends ConsumerState<NewPaymentScreen> {
  final _amount = TextEditingController();
  final _item = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _item.dispose();
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = ref.read(authControllerProvider).session?.token;
    final amount = _amount.text.trim();
    final item = _item.text.trim();
    final phone = _phone.text.trim();
    final pin = _pin.text.trim();
    if (token == null || amount.isEmpty || item.isEmpty || phone.isEmpty) {
      setState(() => _error = 'Amount, product, and buyer phone are required.');
      return;
    }
    if (pin.length < 4) {
      setState(() => _error = 'Delivery PIN must be at least 4 characters.');
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
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Something went wrong. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('New Payment'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'New Payment Link',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a secure link to receive payments in ETB.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _amount,
            label: 'AMOUNT (ETB)',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _item,
            label: 'PRODUCT / SERVICE',
            hint: 'e.g. Graphic Design Services',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _phone,
            label: 'BUYER PHONE',
            hint: '+2519...',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _pin,
            label: 'DELIVERY PIN',
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
          const SizedBox(height: 28),
          AppButton(label: 'GENERATE LINK  →', busy: _busy, onPressed: _submit),
        ],
      ),
    );
  }
}
