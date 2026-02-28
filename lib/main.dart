import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

export 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ImmersiveSticky ile Navbar + Durum çubuğunu aynı anda GİZLER.
  // Parmağınızla yukarıdan kaydırınca birlikte inerler.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const MyApp());
}

