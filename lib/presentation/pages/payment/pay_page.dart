import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/deeplink_callback_service.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

class PayPage extends StatelessWidget {
  final Object? payload;

  const PayPage({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    if (payload == null) {
      return const _ErrorView(message: 'Tautan pembayaran kosong atau tidak ditemukan.');
    }

    if (payload is String) {
      return _ErrorView(message: payload as String);
    }

    if (payload is! DeeplinkPaymentData) {
      return const _ErrorView(message: 'Format data tautan pembayaran tidak dikenali.');
    }

    final data = payload as DeeplinkPaymentData;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(
        title: 'Konfirmasi Pembayaran',
        onBack: () => _handleCancel(context, data),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Merchant Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        AppAvatar(name: data.merchantName, size: 64),
                        const SizedBox(height: 14),
                        const Text(
                          'Pembayaran Kepada',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.merchantName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: AppColors.line),
                        const SizedBox(height: 24),
                        const Text(
                          'TOTAL TAGIHAN',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(data.amount),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Transaction Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Transaksi',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(label: 'Deskripsi', value: data.description),
                        if (data.reference != null && data.reference!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _DetailRow(label: 'Referensi/Invoice', value: data.reference!),
                        ],
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Merchant ID', value: data.merchantId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Buttons
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'Konfirmasi & Bayar',
                  onPressed: () {
                    context.go('/pin', extra: {
                      'kind': 'deeplink',
                      'merchant_id': data.merchantId,
                      'merchant_name': data.merchantName,
                      'amount': data.amount,
                      'description': data.description,
                      'reference': data.reference,
                      'callback': data.callbackUrl,
                    });
                  },
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Batalkan Pembayaran',
                  variant: AppButtonVariant.outline,
                  onPressed: () => _handleCancel(context, data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancel(BuildContext context, DeeplinkPaymentData data) {
    if (data.callbackUrl != null && data.callbackUrl!.isNotEmpty) {
      debugPrint('[PayPage] Mengirim callback cancelled ke: ${data.callbackUrl}');
      DeeplinkCallbackService.notifyCancelled(
        callbackUrl: data.callbackUrl!,
        reference: data.reference,
      );
    }
    context.go('/home');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppTopBar(
        title: 'Pembayaran Gagal',
        onBack: () => context.go('/home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.red,
              size: 72,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tautan Tidak Valid',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.slate500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Kembali ke Beranda',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
