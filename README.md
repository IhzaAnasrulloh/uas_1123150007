# Pengembang
 * Ihza Anasrullah Bil Haq
 * 1123150007
 * TI SE P1 23
 * Teknik Informatika
 * Software Engineering 
 * [Link-Youtube-presentation](https://www.youtube.com/)

#  Kurban Connect

> Aplikasi mobile dompet digital berbasis Flutter.
> Kurban Connect memudahkan pengguna dalam melakukan top-up, transfer, hingga integrasi checkout dengan merchant eksternal — semua dengan keamanan berlapis (Firebase Auth, PIN, dan TOTP).

---

## Tampilan Aplikasi

### Splash Screen

### Login

### Daftar

### Verify Email

## Fitur Utama

### Autentikasi & Keamanan
- **Login** via Google Sign-In dan Email/Password (Firebase Auth)
- **Registrasi** dengan verifikasi email OTP (6 digit, auto-submit, resend timer)
- **2FA tiga metode:**
  - Email OTP (SMTP)
  - Authenticator (TOTP) — *Paling aman*
  - Notifikasi Push OTP (Firebase Cloud Messaging)
- **Verifikasi transaksi dua langkah:** PIN (6 digit) + Kode TOTP (6 digit)

###  Dompet Digital
- **Dashboard** dengan saldo Dana Kurban, Poin Kampus, dan KTM Digital
- **Top-up** via Virtual Account BCA, Kartu Debit/Kredit, dan Alfamart/Indomaret
- **Transfer** sesama pengguna Kurban dan ke bank (BCA, BNI, Mandiri, BRI)


###  Deep Link & Integrasi Merchant
- **Custom URL scheme:** `dompetkampus://pay?...`
- **App Links:** `https://dompetkampus.app/pay?...`
- **Merchant checkout** dengan callback sukses/gagal/batal ke URL merchant
- Simulasi halaman checkout e-commerce ("TokoBelanja")

###  Lainnya
- **Riwayat transaksi** dengan filter (Semua / Kurban Saya / Diterima)
- **Halaman promo** dengan berbagai penawaran
- **Profil akun** dengan status keamanan, ubah PIN, dan biometric toggle
- **Tema** gold/maroon bernuansa islami dengan font PlusJakartaSans
- **Orientasi portrait-only** dengan status bar transparan

---

##  Teknologi

| Kategori | Teknologi |
|---|---|
| **Framework** | Flutter 3.x (Dart SDK ^3.9.2) |
| **State Management** | flutter_bloc ^9.0.0 |
| **Navigasi** | go_router ^14.8.1 (ShellRoute, deep linking) |
| **Autentikasi** | Firebase Auth, Google Sign-In |
| **Push Notification** | Firebase Cloud Messaging |
| **HTTP Client** | Dio ^5.9.2 + pretty_dio_logger |
| **Dependency Injection** | get_it ^8.0.2 |
| **Local Storage** | flutter_secure_storage ^10.0.0, shared_preferences ^2.3.4 |
| **QR Scanner** | mobile_scanner ^7.0.0 |
| **Animasi** | Lottie ^3.3.3, Shimmer ^3.0.0 |
| **Validasi** | email_validator ^3.0.0, equatable ^2.0.8 |
| **Deep Link** | app_links ^6.3.2, url_launcher ^6.3.1 |
| **Internasionalisasi** | intl ^0.19.0 |
| **Image Caching** | cached_network_image ^3.4.1 |
| **Golang Backend** | [Backend](https://github.com/IhzaAnasrulloh/uas_be_1123150007.git) |


---

##  Susunan Project

```
uas_1123150007/
├── android/                        # Konfigurasi Android (Gradle, manifest, keystore)
├── ios/                            # Konfigurasi iOS (Runner, Info.plist)
├── lib/
│   ├── core/                       # Layer inti (konfigurasi global)
│   │   ├── constants/              #   Konstanta app & endpoint API
│   │   ├── error/                  #   Exception & Failure classes
│   │   ├── network/                #   Dio API client (JWT auth, error handling)
│   │   ├── router/                 #   GoRouter (20+ route, ShellRoute, deep link)
│   │   ├── services/               #   DeeplinkService & DeeplinkCallbackService
│   │   ├── theme/                  #   Warna (gold/maroon) & Material3 theme
│   │   └── utils/                  #   AppBlocObserver
│   │
│   ├── data/                       # Data layer (repository impl, datasource, model)
│   │   ├── datasources/            #   Remote (Dio) & Local (SecureStorage)
│   │   ├── models/                 #   UserModel, AccountModel, TransactionModel
│   │   └── repositories/           #   Implementasi Auth, OTP, Account, Payment repo
│   │
│   ├── domain/                     # Domain layer (business logic)
│   │   ├── entities/               #   UserEntity, AccountEntity, TransactionEntity, dll
│   │   ├── repositories/           #   Abstract repository interfaces
│   │   └── usecases/               #   Use case classes (Register, Verify, Transfer, dll)
│   │
│   ├── injection/                  # GetIt dependency injection container
│   │
│   └── presentation/               # Presentation layer (UI & state)
│       ├── blocs/                  #   AuthBloc, OtpBloc, AccountBloc, PaymentBloc
│       ├── pages/                  #   21 halaman dalam 10 direktori:
│       │   ├── account/            #     Profil & pengaturan akun
│       │   ├── auth/               #     Login, register, verifikasi email, 2FA
│       │   ├── home/               #     Dashboard utama
│       │   ├── history/            #     Riwayat transaksi
│       │   ├── merchant/           #     Simulasi checkout merchant
│       │   ├── payment/            #     Pembayaran, PIN, scan QR
│       │   ├── promo/              #     Halaman promosi
│       │   ├── splash/             #     Splash screen
│       │   ├── success/            #     Halaman sukses transaksi
│       │   ├── topup/              #     Top-up saldo
│       │   └── transfer/           #     Transfer (pilih penerima, nominal, konfirmasi)
│       └── widgets/                #   Widget reusable (AppButton, AppField, PinPad, dll)
│
├── pubspec.yaml                    # Konfigurasi Flutter & dependencies
├── analysis_options.yaml           # Linting rules (flutter_lints)
└── README.md                       # Dokumentasi project
```

---

##  Penggunaan

### Alur Registrasi Baru

```
Splash Screen
    ↓
Halaman Registrasi (isi nama, email, password)
    ↓
Verifikasi Email OTP (masukkan 6 digit)
    ↓
Pilih Metode 2FA (SMTP / TOTP / Notifikasi)
    ↓
Selesai → Dashboard
```

### Alur Login

```
Splash Screen
    ↓
Halaman Login (Google Sign-In atau Email/Password)
    ↓
Jika 2FA aktif → Verifikasi 2FA
    ↓
Dashboard
```

### Alur Transfer

```
Dashboard → Pilih "Bagikan"
    ↓
Pilih Penerima (Sesama Kurban / Ke Bank)
    ↓
Masukkan Nominal (keypad, max Rp100.000)
    ↓
Konfirmasi Transfer
    ↓
Verifikasi PIN + TOTP
    ↓
Halaman Sukses
```

### Alur Pembayaran via Deep Link

```
Buka link merchant → dompetkampus://pay?amount=50000&merchant=KantinTeknik&...
    ↓
Halaman Konfirmasi Pembayaran (info merchant & nominal)
    ↓
Konfirmasi → Verifikasi PIN + TOTP
    ↓
Halaman Sukses → Callback ke URL merchant
```


---

