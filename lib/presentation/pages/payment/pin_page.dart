import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/deeplink_callback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/feature_icon.dart';
import '../../widgets/pin_pad.dart';
import '../../widgets/code_input.dart';

class PinPage extends StatefulWidget {
  final Map<String, dynamic> flowData;
  const PinPage({super.key, required this.flowData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _step = 'pin';
  String _pin = '';
  bool _busy = false;
  bool _hasError = false;

  void _onComplete(String pin) {
    final authState = context.read<AuthBloc>().state;
    bool totpEnabled = false;
    if (authState is AuthAuthenticated) {
      totpEnabled = authState.user.totpEnabled;
    }

    if (_step == 'pin') {
      setState(() {
        _step = 'totp';
        _pin = '';
      });
      return;
    }

    setState(() => _busy = true);
    _processPayment(pin);
  }

  void _processPayment(String code) {
    final flow = widget.flowData;
    final kind = flow['kind'] as String? ?? '';

    final finalOtpCode = code;

    if (kind == 'transfer') {
      // Use OTP from 2FA — for demo we use a hardcoded type
      context.read<PaymentBloc>().add(PaymentTransferRequested(
        amount: (flow['amount'] as num).toDouble(),
        description: flow['note'] as String? ?? 'Transfer',
        otpCode: finalOtpCode, // In production: get from actual 2FA
        otpType: AppConstants.otpTypeTotp,
      ));
    } else if (kind == 'topup') {
      context.read<PaymentBloc>().add(PaymentTopupRequested(
        (flow['amount'] as num).toDouble(),
      ));
    } else if (kind == 'payment' || kind == 'deeplink') {
      // QRIS payment → also uses transfer endpoint
      context.read<PaymentBloc>().add(PaymentTransferRequested(
        amount: (flow['amount'] as num).toDouble(),
        description: flow['description'] as String? ?? 'Pembayaran QRIS',
        otpCode: finalOtpCode,
        otpType: AppConstants.otpTypeTotp,
      ));
    } else if (kind == 'change_pin') {
      // Simulate API delay for changing PIN
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.go('/success', extra: {
            'title': 'Ubah PIN Berhasil',
            'subtitle': 'PIN keamanan kamu telah diperbarui',
            'amount': 0.0,
            'lines': [
              ['Waktu', DateTime.now().toString().substring(0, 19)],
              ['Status', 'Sukses'],
            ],
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.flowData['kind'] as String? ?? '';
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentTransferSuccess) {
          final result = state.result;

          // Kirim callback sukses ke merchant jika alur deeplink
          final callbackUrl = widget.flowData['callback'] as String?;
          if (kind == 'deeplink' && callbackUrl != null && callbackUrl.isNotEmpty) {
            DeeplinkCallbackService.notifySuccess(
              callbackUrl: callbackUrl,
              reference: widget.flowData['reference'] as String?,
              transactionId: result.transactionId,
            );
          }

          context.go('/success', extra: {
            'title': 'Transfer berhasil',
            'subtitle': result.description,
            'amount': result.amount,
            'lines': [
              ['Jumlah', CurrencyFormatter.format(result.amount)],
              ['Saldo setelah', CurrencyFormatter.format(result.balanceAfter)],
              ['Ref', 'DKG${result.transactionId}'],
            ],
          });
        } else if (state is PaymentTopupSuccess) {
          final method = widget.flowData['method'] as String? ?? 'BCA Virtual Account';
          context.go('/success', extra: {
            'title': 'Top up berhasil',
            'subtitle': 'Saldo kamu bertambah',
            'amount': state.amount,
            'lines': [
              ['Metode', method],
              ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
            ],
          });
        } else if (state is PaymentInvalidOtp) {
          setState(() { _busy = false; _hasError = true; _pin = ''; });
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() => _hasError = false);
          });
        } else if (state is PaymentInsufficientBalance) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo tidak mencukupi untuk melakukan pembayaran.'), backgroundColor: AppColors.red),
          );

          // Kirim callback gagal ke merchant jika alur deeplink
          final callbackUrl = widget.flowData['callback'] as String?;
          if (kind == 'deeplink' && callbackUrl != null && callbackUrl.isNotEmpty) {
            DeeplinkCallbackService.notifyFailed(
              callbackUrl: callbackUrl,
              reference: widget.flowData['reference'] as String?,
              errorMessage: 'Saldo tidak mencukupi.',
            );
          }
        } else if (state is PaymentError) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );

          // Kirim callback gagal ke merchant jika alur deeplink
          final callbackUrl = widget.flowData['callback'] as String?;
          if (kind == 'deeplink' && callbackUrl != null && callbackUrl.isNotEmpty) {
            DeeplinkCallbackService.notifyFailed(
              callbackUrl: callbackUrl,
              reference: widget.flowData['reference'] as String?,
              errorMessage: state.message,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                  onPressed: () {
                    if (_step == 'totp') {
                      setState(() {
                        _step = 'pin';
                        _pin = '';
                      });
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
              if (_busy) ...[
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 18),
                      Text('Memproses transaksi…',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate600,
                          )),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _step == 'totp'
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(child: Icon(Icons.security_rounded, size: 26, color: AppColors.primary)),
                              ),
                              const SizedBox(height: 16),
                              const Text('Masukkan Kode TOTP',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  )),
                              const SizedBox(height: 6),
                              const Text('Buka aplikasi authenticator dan masukkan 6 digit kode aktif.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13.5, color: AppColors.slate500)),
                              const SizedBox(height: 60),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 80),
                                transform: _hasError ? (Matrix4.identity()..translate(10.0)) : Matrix4.identity(),
                                child: CodeInput(
                                  value: _pin,
                                  onChanged: (v) {
                                    setState(() => _pin = v);
                                    if (v.length == 6) {
                                      _onComplete(v);
                                    }
                                  },
                                  hasError: _hasError,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text.rich(TextSpan(
                                text: 'Lupa PIN? ',
                                style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12.5, color: AppColors.slate400),
                                children: [
                                  TextSpan(
                                    text: 'Reset',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(child: Icon(Icons.lock_outline_rounded, size: 26, color: AppColors.primary)),
                              ),
                              const SizedBox(height: 16),
                              Text(kind == 'change_pin' ? 'PIN Baru' : 'Masukkan PIN',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  )),
                              const SizedBox(height: 6),
                              Text(kind == 'change_pin' ? 'Masukkan 6 digit PIN keamanan baru kamu' : 'Masukkan 6 digit PIN keamanan kamu',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13.5, color: AppColors.slate500)),
                              const Spacer(),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 80),
                                transform: _hasError ? (Matrix4.identity()..translate(10.0)) : Matrix4.identity(),
                                child: PinPad(
                                  value: _pin,
                                  onChanged: (v) => setState(() => _pin = v),
                                  onComplete: _onComplete,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text.rich(TextSpan(
                                text: 'Lupa PIN? ',
                                style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12.5, color: AppColors.slate400),
                                children: [
                                  TextSpan(
                                    text: 'Reset',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
