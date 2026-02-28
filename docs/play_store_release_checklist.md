# Play Store Yayın + Google Drive Yedekleme (Tek Seferlik Kurulum)

## 1) Paket kimliği (zorunlu)

- Android `applicationId` şu an: `com.semaimi.cipherguard`
- Play Store için benzersiz bir değer kullan (örnek: `com.semaimi.cipherguard`).

Güncellenecek yer:
- `android/app/build.gradle.kts` içindeki `namespace` ve `applicationId`

## 2) Release keystore oluştur

PowerShell örneği:

`keytool -genkey -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000`

Sonra `android/key.properties` oluştur:

```
storePassword=BURAYA_STORE_PASSWORD
keyPassword=BURAYA_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Not: Bu dosya repoya eklenmemeli (gitignore'a eklendi).

## 3) Release SHA parmak izlerini al

`keytool -list -v -alias upload -keystore android/upload-keystore.jks`

Çıktıdaki SHA-1 ve SHA-256 değerlerini kopyala.

## 4) Google Cloud OAuth istemcileri

Google Cloud Console:
- `Google Drive API` etkin
- OAuth consent screen tamam
- OAuth clients oluştur:
  - Android client: package name + release SHA-1/SHA-256
  - Web client
  - iOS client (iOS yayınlayacaksan)

## 5) Flutter OAuth sabitlerini doldur

`lib/constants/oauth_config.dart`:
- `kGoogleWebClientId` = Web client ID
- `kGoogleIosClientId` = iOS client ID (iOS kullanacaksan)

## 6) AAB üret

`flutter build appbundle --release`

Oluşan dosya:
- `build/app/outputs/bundle/release/app-release.aab`

## 7) Play Console

- Uygulama oluştur
- AAB yükle
- App Signing etkinleştir
- Internal testing ile bulut yedekleme butonunu test et

## Notlar

- Son kullanıcıların ekstra yapılandırma yapmasına gerek yok.
- Bu adımlar geliştirici tarafında bir kez yapılır.


