import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations ?? AppLocalizations(const Locale('tr'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'password': 'Şifre',
      'signIn': 'Giriş Yap',
      'checking': 'Kontrol ediliyor...',
      'passwordEmpty': 'Şifre boş olamaz.',
      'incorrectMasterPassword': 'Ana şifre hatalı.',
      'biometricPrompt': 'Lütfen uygulamaya girmek için parmak izinizi okutun',
      'biometricFailed': 'Parmak izi / biyometrik doğrulama başarısız oldu.',
      'langTurkish': 'Türkçe',
      'langEnglish': 'İngilizce',
      'langItalian': 'İtalyanca',
      'langKorean': 'Korece',
      'selectedLanguage': 'Seçili dil',
      'passwords': 'Şifreler',
      'backupToDrive': 'Google Drive yedekle',
      'logout': 'Çıkış Yap',
      'noRecordsYet': 'Henüz kayıt yok.',
      'confirmDeleteTitle': 'Silmeyi Onayla',
      'confirmDeleteBody': 'kaydını tamamen silmek istediğinize emin misiniz?',
      'cancel': 'Vazgeç',
      'delete': 'Sil',
      'logoutTitle': 'Çıkış Yapılıyor',
      'logoutBody': 'Çıkış yapmak üzeresiniz, emin misiniz?',
      'cancelExit': 'Vazgeçtim',
      'continueAction': 'Devam Et',
      'backupSuccess': 'Yedek Google Drive hesabına yüklendi.',
      'backupFailedPrefix': 'Yedekleme başarısız',
      'category': 'Kategori',
      'username': 'Kullanıcı adı',
      'realPassword': 'Gerçek şifre',
      'close': 'Kapat',
      'decryptFailed': 'Veri bu ana şifre ile çözülemedi.',
      'categorySocial': 'Sosyal Medya',
      'categoryWork': 'İş',
      'categoryPersonal': 'Kişisel',
      'categoryOther': 'Diğer',
      'addPassword': 'Şifre Ekle',
      'editRecord': 'Kaydı Düzenle',
      'title': 'Başlık',
      'titleRequired': 'Başlık zorunlu',
      'usernameOrEmail': 'Kullanıcı adı veya E-posta',
      'usernameRequired': 'Kullanıcı adı zorunlu',
      'newPasswordOptional': 'Yeni Şifre (boşsa değişmez)',
      'passwordRequired': 'Şifre zorunlu',
      'update': 'Güncelle',
      'save': 'Kaydet',
    },
    'en': {
      'password': 'Password',
      'signIn': 'Sign In',
      'checking': 'Checking...',
      'passwordEmpty': 'Password cannot be empty.',
      'incorrectMasterPassword': 'Incorrect master password.',
      'biometricPrompt': 'Please scan your fingerprint to enter the app',
      'biometricFailed': 'Fingerprint / biometric authentication failed.',
      'langTurkish': 'Turkish',
      'langEnglish': 'English',
      'langItalian': 'Italian',
      'langKorean': 'Korean',
      'selectedLanguage': 'Selected language',
      'passwords': 'Passwords',
      'backupToDrive': 'Backup to Google Drive',
      'logout': 'Log Out',
      'noRecordsYet': 'No records yet.',
      'confirmDeleteTitle': 'Confirm Deletion',
      'confirmDeleteBody': 'record will be permanently deleted. Are you sure?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'logoutTitle': 'Logging Out',
      'logoutBody': 'You are about to log out. Are you sure?',
      'cancelExit': 'Cancel',
      'continueAction': 'Continue',
      'backupSuccess': 'Backup uploaded to Google Drive.',
      'backupFailedPrefix': 'Backup failed',
      'category': 'Category',
      'username': 'Username',
      'realPassword': 'Real password',
      'close': 'Close',
      'decryptFailed': 'Data could not be decrypted with this master password.',
      'categorySocial': 'Social Media',
      'categoryWork': 'Work',
      'categoryPersonal': 'Personal',
      'categoryOther': 'Other',
      'addPassword': 'Add Password',
      'editRecord': 'Edit Record',
      'title': 'Title',
      'titleRequired': 'Title is required',
      'usernameOrEmail': 'Username or E-mail',
      'usernameRequired': 'Username is required',
      'newPasswordOptional': 'New Password (leave blank to keep current)',
      'passwordRequired': 'Password is required',
      'update': 'Update',
      'save': 'Save',
    },
    'it': {
      'password': 'Password',
      'signIn': 'Accedi',
      'checking': 'Controllo in corso...',
      'passwordEmpty': 'La password non può essere vuota.',
      'incorrectMasterPassword': 'Password principale non corretta.',
      'biometricPrompt': 'Scansiona la tua impronta digitale per entrare nell\'app',
      'biometricFailed': 'Autenticazione con impronta / biometria non riuscita.',
      'langTurkish': 'Turco',
      'langEnglish': 'Inglese',
      'langItalian': 'Italiano',
      'langKorean': 'Coreano',
      'selectedLanguage': 'Lingua selezionata',
      'passwords': 'Password',
      'backupToDrive': 'Backup su Google Drive',
      'logout': 'Disconnetti',
      'noRecordsYet': 'Nessun record disponibile.',
      'confirmDeleteTitle': 'Conferma eliminazione',
      'confirmDeleteBody': 'verrà eliminato definitivamente. Sei sicuro?',
      'cancel': 'Annulla',
      'delete': 'Elimina',
      'logoutTitle': 'Disconnessione',
      'logoutBody': 'Stai per uscire. Sei sicuro?',
      'cancelExit': 'Annulla',
      'continueAction': 'Continua',
      'backupSuccess': 'Backup caricato su Google Drive.',
      'backupFailedPrefix': 'Backup non riuscito',
      'category': 'Categoria',
      'username': 'Nome utente',
      'realPassword': 'Password reale',
      'close': 'Chiudi',
      'decryptFailed': 'Impossibile decifrare i dati con questa password principale.',
      'categorySocial': 'Social Media',
      'categoryWork': 'Lavoro',
      'categoryPersonal': 'Personale',
      'categoryOther': 'Altro',
      'addPassword': 'Aggiungi Password',
      'editRecord': 'Modifica record',
      'title': 'Titolo',
      'titleRequired': 'Il titolo è obbligatorio',
      'usernameOrEmail': 'Nome utente o E-mail',
      'usernameRequired': 'Il nome utente è obbligatorio',
      'newPasswordOptional': 'Nuova password (vuoto per mantenere)',
      'passwordRequired': 'La password è obbligatoria',
      'update': 'Aggiorna',
      'save': 'Salva',
    },
    'ko': {
      'password': '비밀번호',
      'signIn': '로그인',
      'checking': '확인 중...',
      'passwordEmpty': '비밀번호는 비워둘 수 없습니다.',
      'incorrectMasterPassword': '마스터 비밀번호가 올바르지 않습니다.',
      'biometricPrompt': '앱에 들어가려면 지문을 스캔하세요',
      'biometricFailed': '지문 / 생체 인증에 실패했습니다.',
      'langTurkish': '터키어',
      'langEnglish': '영어',
      'langItalian': '이탈리아어',
      'langKorean': '한국어',
      'selectedLanguage': '선택된 언어',
      'passwords': '비밀번호',
      'backupToDrive': 'Google Drive 백업',
      'logout': '로그아웃',
      'noRecordsYet': '아직 저장된 항목이 없습니다.',
      'confirmDeleteTitle': '삭제 확인',
      'confirmDeleteBody': '항목을 완전히 삭제하시겠습니까?',
      'cancel': '취소',
      'delete': '삭제',
      'logoutTitle': '로그아웃',
      'logoutBody': '로그아웃하려고 합니다. 계속하시겠습니까?',
      'cancelExit': '취소',
      'continueAction': '계속',
      'backupSuccess': 'Google Drive에 백업이 업로드되었습니다.',
      'backupFailedPrefix': '백업 실패',
      'category': '카테고리',
      'username': '사용자 이름',
      'realPassword': '실제 비밀번호',
      'close': '닫기',
      'decryptFailed': '이 마스터 비밀번호로 데이터를 복호화할 수 없습니다.',
      'categorySocial': '소셜 미디어',
      'categoryWork': '업무',
      'categoryPersonal': '개인',
      'categoryOther': '기타',
      'addPassword': '비밀번호 추가',
      'editRecord': '항목 수정',
      'title': '제목',
      'titleRequired': '제목은 필수입니다',
      'usernameOrEmail': '사용자 이름 또는 이메일',
      'usernameRequired': '사용자 이름은 필수입니다',
      'newPasswordOptional': '새 비밀번호 (비워두면 유지)',
      'passwordRequired': '비밀번호는 필수입니다',
      'update': '수정',
      'save': '저장',
    },
  };

  String t(String key) {
    final langCode = _localizedValues.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'tr';
    return _localizedValues[langCode]?[key] ??
        _localizedValues['tr']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['tr', 'en', 'it', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
