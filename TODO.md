# AIcoach TODO

Son guncelleme: 2026-06-20

Bu dosya "nerede kalmistik?" sorusunun kisa cevabi icin tutulur.
Bir is tamamlandikca ilgili satir `[ ]` yerine `[x]` yapilir.

## Aktif Odak

iOS signing/TestFlight hazirligi ve gercek cihaz/simulator uzerinde uctan uca
Firebase + Claude akisini dogrulama.

## Bu Turda Tamamlanan

- [x] Operasyonel TODO takip dosyasi olusturuldu.
- [x] Repo hijyeni yapildi: `.DS_Store` dosyalari temizlendi, `.vscode/` ve
      Firebase debug/cache ciktilari ignore edildi.
- [x] Commit oncesi versiyona alinacak dosya seti netlestirildi.
- [x] README default Flutter metninden urun odakli proje rehberine cevrildi.
- [x] Firebase proje ayarlari ve platform config dosyalari dogrulandi.
- [x] Anthropic secret/model config akisi deploy oncesi kontrol edildi.
- [x] Ilk duzenli MVP commit'i olusturuldu.
- [x] iOS release/TestFlight runbook'u eklendi.

## Mevcut Durum

- [x] Urun kapsami `requirements.md` icinde tanimli.
- [x] Roadmap `docs/roadmap.md` icinde fazlara ayrilmis.
- [x] Flutter projesi olusturuldu.
- [x] Riverpod uygulama girisi ve app state kuruldu.
- [x] Tema/design component temeli eklendi.
- [x] 5 tabli uygulama shell'i hazir: Home, Progress, Write, Coach, Profile.
- [x] Auth katmani icin repository yapisi eklendi.
- [x] Essay yazma ekrani, word count, credit kontrolu ve analiz karti eklendi.
- [x] Mock essay analiziyle widget testi geciyor.
- [x] Firebase Functions tarafinda `submitEssay` fonksiyonu yazildi.
- [x] Claude/Anthropic analiz cevabini Firestore'a yazma akisi tasarlandi.
- [x] `flutter analyze` temiz.
- [x] `flutter test` temiz.
- [x] iOS simulator uzerinde uygulama iPhone 15 ile calistirildi.
- [x] Apple Sign-In entitlement iOS Runner target'ina eklendi.
- [x] iOS AppIcon default Flutter logosundan custom AI Coach ikonuna cevrildi.
- [x] iOS release build `--no-codesign` ile basariyla uretildi.

## Siradaki Isler

- [x] Repo hijyeni: `.DS_Store`, uretilmis dosyalar ve ignore durumunu kontrol et.
- [x] Commit oncesi hangi dosyalarin versiyona alinacagini netlestir.
- [x] README'yi default Flutter metninden urun odakli proje ozetine cevir.
- [x] Firebase proje ayarlarini ve platform config dosyalarini dogrula.
- [x] Anthropic secret/model config akisini deploy oncesi kontrol et.
- [x] iOS simulator veya Android emulator uzerinde uygulamayi calistir.
- [x] iOS icin custom AppIcon setini default Flutter ikonundan degistir.
- [ ] Apple Developer Team ID / signing ayarlarini Xcode Runner target'ina bagla.
- [x] Firebase project'i Blaze plana gecir, `ANTHROPIC_API_KEY` secret'ini set et ve Functions deploy et.
- [ ] Her push oncesi guvenlik kontrollerini calistir; temiz sonuc almadan push yapma.
- [ ] `npm audit` uuid/firebase-admin moderate advisory'sini upstream uyumlu fix
      ciktiginda kapat; `npm audit fix --force` ile Admin SDK downgrade yapma.
- [ ] Yeni Firebase projesinde Google Sign-In iOS OAuth client'i uret, plist'i yenile ve iOS URL scheme'i yeni client id ile guncelle.
- [x] Firestore rules'i yeni Firebase projesine deploy et ve aktif release'i
      dogrula. Rules client tarafindan kredi/skor/essay yazimini engelleyecek
      sekilde daraltildi.
- [x] Firestore default database icin delete protection'i ac.
- [ ] Firestore PITR/backup politikasini Blaze/butce karariyla degerlendir.
- [x] Client-side credit/essay write fallback'i release akistan cikarildi; kredi dusme ve analiz yazma varsayilan olarak callable backend'den gecer.
- [ ] TestFlight icin signed IPA/archive uret ve yukle.
- [ ] Gercek Firebase auth akisini test et.
- [ ] Gercek essay submit + Claude analiz akisini uctan uca test et.
- [ ] Progress ekranini Firestore verileriyle daha anlamli hale getir.
- [ ] Coach report uretme ve saklama akisini ekle.
- [ ] Challenge modellerini ve temel challenge ekranlarini tamamla.
- [ ] RevenueCat credit satin alma akisini ekle.
- [ ] Analytics, notification ve Crashlytics entegrasyonlarini ekle.

## Notlar

- Su an `main` branch'indeyiz.
- Son MVP commit mesaji: `Build AI Coach Flutter MVP`; kesin hash icin
  `git log -1 --oneline` kontrol edilmeli.
- Calisma agaci commit sonrasi temiz olmalidir; yeni calisma baslamadan
  `git status --short` ile kontrol edilmeli.
- Local keychain kontrolunde `security find-identity -v -p codesigning`
  sonucu `0 valid identities found`; signed IPA/TestFlight icin Xcode'a Apple
  Developer hesabi/sertifikasi eklenmeli.

## Commit Dosya Seti

Commit'e alinacaklar:

- `.gitignore`, `.firebaserc`, `firebase.json`, `.metadata`,
  `analysis_options.yaml`, `pubspec.yaml`, `pubspec.lock`, `README.md`,
  `requirements.md`, `TODO.md`.
- `docs/**` dokumantasyon dosyalari.
- `lib/**` Flutter uygulama kodu.
- `test/**` test dosyalari.
- `functions/.gitignore`, `functions/package.json`,
  `functions/package-lock.json`, `functions/src/**`, `functions/tsconfig.json`.
- Flutter platform scaffold dosyalari: `android/**`, `ios/**`, `linux/**`,
  `macos/**`, `web/**`, `windows/**`.
- `.DS_Store` silme kayitlari.

Commit'e alinmayacaklar:

- `.dart_tool/`, `.flutter-plugins-dependencies`, `.idea/`, `.vscode/`,
  `build/`, `*.iml`.
- `functions/node_modules/`, `functions/lib/`.
- `ios/Pods/`, `ios/.symlinks/`, `ios/Flutter/ephemeral/` ve diger Flutter
  uretilmis iOS dosyalari.
- `android/local.properties`, generated Android plugin dosyalari ve local
  Gradle ciktilari.

Dikkat notlari:

- `ios/Runner/GoogleService-Info.plist` real dosyasi commit disidir; sadece
  `ios/Runner/GoogleService-Info.plist.example` commitlenir. Daha once pushlanan
  Google/Firebase key rotate ve restrict edilmelidir.
- Android icin `android/app/google-services.json` su an yok; Firebase config
  kontrolunde tamamlanmali ve real dosya commitlenmemelidir.
- `ios/Runner/photo2.jpg` kodda referanslanmiyor ve `.gitignore` ile commit
  disi birakildi.

## Firebase Config Kontrolu

Dogru / hazir gorunenler:

- `.firebaserc` default proje alias'i `dear-diary-483614`.
- `firebase.json` Functions source olarak `functions/` klasorunu gosteriyor ve
  deploy oncesi `npm --prefix "$RESOURCE_DIR" run build` calistiriyor.
- `firebase.json` `firestore.rules` dosyasini deploy config'ine bagliyor.
- `ios/Runner/GoogleService-Info.plist` localde mevcut olmali; git tarafinda
  ignore edilir.
- iOS Firebase bundle id `com.aicoach.aiCoach`; Xcode project bundle id ile
  eslesiyor.
- Eski Google Sign-In URL scheme'i `Info.plist` icinden kaldirildi; yeni
  Firebase projesinde iOS OAuth client uretilince yeni scheme eklenmeli.
- Uygulama Firebase init basarisiz olursa mock repository akisine dusuyor; bu
  local preview icin bilincli fallback.

Eksik / dikkat isteyenler:

- Android icin `android/app/google-services.json` yok.
- Yeni `ios/Runner/GoogleService-Info.plist` icinde `CLIENT_ID` ve
  `REVERSED_CLIENT_ID` yok; gercek Google auth testi oncesi Firebase Auth
  Google provider / iOS OAuth client kurulumu tamamlanmali.
- Android Gradle tarafinda `com.google.gms.google-services` plugin'i henuz
  ekli degil; native Android Firebase init icin tamamlanmali.
- `lib/firebase_options.dart` yok ve `Firebase.initializeApp()` options almadan
  cagriliyor. Web/desktop Firebase hedeflenecekse FlutterFire config yeniden
  uretilmeli.
- Gercek Firebase auth ve callable function testi icin ilk hedef iOS simulator
  veya iOS cihaz olmali; Android testi config tamamlanana kadar beklemeli.
- Firestore rules `users/{userId}` update iznini yalnizca profil/auth alanlariyla
  sinirlar; kredi, skor, essay, analiz ve error stat yazimi backend'e aittir.
- Firestore `(default)` database `nam5` lokasyonunda olusturuldu ve delete
  protection acildi. PITR maliyet/veri saklama karari nedeniyle simdilik kapali.

## Anthropic Config Kontrolu

Dogru / hazir gorunenler:

- `functions/src/index.ts` icinde `ANTHROPIC_API_KEY` `defineSecret` ile
  tanimli ve `submitEssay` callable function'ina `secrets` listesiyle bagli.
- `ANTHROPIC_API_KEY` Firebase Secret Manager'da set edildi; deploy loglarinda
  yalnizca secret version metadata'si goruldu, secret degeri aciga cikmadi.
- `submitEssay` Cloud Functions v2 callable olarak `us-central1` bolgesinde
  `nodejs24` runtime ile ACTIVE durumda.
- Secret eksikse function `failed-precondition` hatasi donduruyor; sessiz
  sekilde bos key ile Claude'a istek atmiyor.
- Claude request'i backend'den `https://api.anthropic.com/v1/messages`
  endpoint'ine gidiyor; Flutter tarafinda API key yok.
- Default model `claude-sonnet-4-6`; 2026-06-18'de resmi Anthropic model
  dokumaninda gecerli API model ID olarak dogrulandi.
- Local emulator icin `functions/.secret.local.example` eklendi; gercek
  `functions/.secret.local` dosyasi git tarafindan ignore ediliyor.
- `npm --prefix functions run build` temiz geciyor.
- Cloud Functions Artifact Registry cleanup policy `us-central1` icin 7 gun
  retention ile kuruldu.

Eksik / dikkat isteyenler:

- Model ID bilincli olarak pinlenmis durumda; yeni Anthropic modeline gecmek
  istenirse `ANTHROPIC_MODEL` deploy/runtime config'i bilincli guncellenmeli.
- Firebase CLI `firebase-functions` paketini newer major icin uyariyor; breaking
  change riski nedeniyle ayri bakilmali.

## Push Guvenlik Kapisi

Her push oncesi su kontroller temiz gecmeli:

- `git status --short --ignored` ile real Firebase config ve local secret
  dosyalarinin ignored kaldigi dogrulanir.
- Workspace ve commit history icinde gercek secret pattern'leri aranir:
  Google API key, Anthropic/OpenAI key, JWT, private key, service-role token.
- `git log --all -- ios/Runner/GoogleService-Info.plist
  android/app/google-services.json lib/firebase_options.dart` bos donmeli.
- `flutter analyze --no-pub` ve `flutter test --no-pub` temiz gecmeli.
- `npm --prefix functions audit --omit=dev --audit-level=high` high/critical
  bulmamalidir; moderate advisory'ler takip maddesine baglanir.
- Push sadece bu kontrollerden sonra yapilir.
