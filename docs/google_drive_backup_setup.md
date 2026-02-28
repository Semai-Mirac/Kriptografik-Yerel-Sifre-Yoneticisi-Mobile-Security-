# Google Drive Yedekleme Kurulumu

Bu projede yedekleme Google Drive `appDataFolder` alanına yapılır ve yüklenen içerik AES-256 ile şifrelenmiş metindir.

## 1) Google Cloud projesi

1. Google Cloud Console'da bir proje oluştur.
2. `Google Drive API` servisini etkinleştir.
3. `OAuth consent screen` yapılandır (External veya Internal).

## 2) OAuth Client ID'ler

Aşağıdaki istemcileri oluştur:

- Android OAuth Client
  - Package name: `com.semaimi.cipherguard`
  - SHA-1 ve SHA-256 ekle
- iOS OAuth Client
  - Bundle ID: iOS Runner bundle id ile aynı olmalı
- Web OAuth Client

## 3) Flutter sabitlerini doldur

`lib/constants/oauth_config.dart` dosyasına değerleri gir:

- `kGoogleWebClientId` = Web OAuth Client ID
- `kGoogleIosClientId` = iOS OAuth Client ID

## 4) Android SHA anahtarları (debug)

PowerShell:

`keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android`

Bu çıktıda görünen SHA-1 ve SHA-256 değerlerini Android OAuth Client'a ekle.

## 5) Test

1. Uygulamayı aç.
2. Giriş yap.
3. Şifre listesi ekranında bulut simgesine bas.
4. Google hesap seçimi sonrası `Yedek Google Drive hesabına yüklendi.` mesajını doğrula.

## Not

`appDataFolder` kullanıcıya Drive arayüzünde görünmez; uygulamaya özel gizli alandır.


