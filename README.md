# CultGuard — Azərbaycan Mədəni İrsinin Rəqəmsal Mühafizəçisi

CultGuard Azərbaycanın mədəni irsini (xalça naxışları, muğam, milli alətlər) Generativ AI
dövründə icazəsiz mənimsənilmədən qoruyan və monetizasiya edən LegalTech + AI Qoruma
Platformasıdır. Bu repo — CulTech Hakatonu üçün hazırlanmış Flutter MVP-dir
(Web + iOS + Android).

## Ekranlar

| Ekran | Nə edir |
| --- | --- |
| **Splash & Onboarding** | Rəqəmsal tor yayılır, Azərbaycan medalyonu (göl + səkkizguşə + buta) xətt-xətt çəkilir və AI node-larına "rəqəmsallaşır"; loqo `Hero` ilə onboarding-ə uçur, sloqan `AnimatedOpacity` ilə görünür. Platformaya giriş dairəvi "lens" keçidi ilə açılır. |
| **İdarə Paneli** | 1,240 AI DNT · 89 pozuntu · $12.4K gəlir KPI-ları (count-up + sparkline), canlı insident axını, platformalar üzrə risk, irs portfeli, skanerə sürətli keçid. |
| **AI DNT Skaner** | Şəkil/audio yükləmə (və ya 3 demo nümunə), laser-skan HUD, 5 mərhələli boru kəməri + konsol, nəticə modalı (🔴 İcazəsiz / 🟢 Lisenziyalı, mənşə, oxşarlıq göstəricisi, AI DNT barkodu), "Müəllif Hüququ İddiası Qaldır" və "B2B Lisenziyası Al". |
| **B2B Marketplace & API** | Təsdiqlənmiş datasetlər (filtrlə), `cg_live_…` / `cg_test_…` Bearer açar generatoru (kopyala/gizlət + curl nümunəsi), Starter / Enterprise / Cultural Sovereign planları. |

Responsiv: **≥ 800 px** xüsusi sidebar (1180 px-dən geniş rejim), **< 800 px** Material 3 alt naviqasiya.

## Arxitektura

Qəti Clean Architecture — hər feature `domain → data → presentation` laylarına bölünür,
asılılıqlar yalnız içəriyə yönəlir.

```
lib/
├── main.dart                     # bootstrap + DI
├── app.dart                      # MaterialApp.router
├── core/
│   ├── config/                   # AppConfig (--dart-define)
│   ├── di/                       # get_it kompozisiya kökü
│   ├── domain/                   # paylaşılan kernel (HeritageCategory)
│   ├── error/                    # Exception → Failure xəritələnməsi
│   ├── navigation/               # AppShell (sidebar / bottom nav), breakpoints
│   ├── network/                  # CORS-hazır Dio ApiClient
│   ├── router/                   # go_router + StatefulShellRoute
│   ├── theme/                    # Material 3 tema, rənglər, tipoqrafiya
│   ├── usecase/ utils/           # UseCase, Result<T>, formatters
│   └── widgets/                  # ornament path-ları, loqo, paylaşılan UI
└── features/
    ├── splash/        presentation
    ├── dashboard/     domain · data · presentation (DashboardBloc)
    ├── scanner/       domain · data · presentation (ScannerBloc)
    └── marketplace/   domain · data · presentation (MarketplaceBloc, ApiKeyCubit)
```

Əsas qərarlar:

- **State management:** `flutter_bloc` + `bloc_concurrency` (`restartable` canlı axın və
  skan ləğvi üçün, `droppable` təkrar kliklərə qarşı).
- **Xətalar:** data layı istisna atır, repository onları `Failure`-a çevirib `Result<T>`
  qaytarır — UI heç vaxt infrastruktur istisnası görmür.
- **Demo vs real backend:** `CG_API_BASE_URL` verilməyibsə bütün data mənbələri oflayn demo
  backend-ə keçir — hakaton səhnəsində internetsiz də işləyir.
- **Performans:** AI DNT barmaq izi (SHA-256 + 48 ölçülü embedding) `compute()` ilə ayrıca
  isolate-də hesablanır (64 KB-dan böyük fayllar üçün), 1 MiB-a qədər seçmə ilə
  məhdudlaşdırılır; bütün animasiyalı painter-lər `RepaintBoundary` ilə izolə edilib,
  path-lar keşlənir.
- **Platformaya uyğunluq:** iOS/Android-də kamera + qalereya (`image_picker`); vebdə və
  desktop-da kamera düyməsi gizlənir və hər seçim birbaşa fayl seçicisinə (`file_picker`)
  düşür — platforma xətası yaranmır. Audio həmişə uzantı siyahısı ilə seçilir (iOS media
  kitabxanası icazəsi tələb olunmur).
- **Material:** Flutter 3.44-də Material ayrıca `material_ui` paketinə köçürülüb; tətbiq və
  `go_router` 18 eyni paketdən istifadə edir.

## İşə salma

```bash
flutter pub get
```

```bash
flutter run -d chrome
```

```bash
flutter run -d ios
```

Real backend ilə (CORS aktiv server tələb olunur):

```bash
flutter run -d chrome --dart-define=CG_API_BASE_URL=https://api.cultguard.az --dart-define=CG_API_KEY=cg_live_xxx
```

Testlər və statik analiz:

```bash
flutter analyze && flutter test
```

## Hakim üçün 60 saniyəlik demo ssenarisi

1. Splash animasiyasını izləyin → onboarding-də "Platformaya daxil ol".
2. İdarə Panelində canlı insident axınını göstərin — "Aktiv Pozuntular" real vaxtda artır.
3. "Skanerə keç" → `midjourney_buta_pattern_v6.png` nümunəsi → "AI DNT Skanını Başlat".
4. Nəticə: **Şirvan Xalçaçılıq Məktəbi — Boteh Naxışı, 96.8%, İcazəsiz** →
   "Müəllif Hüququ İddiası Qaldır".
5. "B2B Lisenziyası Al" → Marketplace → "Açar yarat" → açarı kopyalayın.

## Backend API müqaviləsi (v1)

| Metod | Yol | Təsvir |
| --- | --- | --- |
| GET | `/v1/dashboard/snapshot` | KPI-lar, son insidentlər, platforma riski, portfel |
| GET | `/v1/incidents?since=ISO8601` | Yeni insidentlər (5 s polling) |
| POST | `/v1/dna/match` | `{hash, vector, media_kind, file_name}` → skan nəticəsi |
| POST | `/v1/claims` | Müəllif hüququ iddiası |
| GET | `/v1/marketplace/catalog` | Datasetlər + planlar |
| POST | `/v1/keys` | API açarı (yalnız server tərəfində yaradılır) |
| POST | `/v1/licenses` | Dataset lisenziya sifarişi |

Məxfilik: media faylı cihazdan çıxmır — serverə yalnız lokal hesablanmış AI DNT (hash +
vektor) göndərilir.

CORS: server `OPTIONS` sorğusuna `Access-Control-Allow-Origin`,
`Access-Control-Allow-Methods: GET, POST` və
`Access-Control-Allow-Headers: Authorization, Content-Type` ilə cavab verməlidir. Klient
`withCredentials: false` istifadə edir və yalnız zəruri başlıqları göndərir.

## Lisenziyalar

`assets/fonts/JetBrainsMono-Variable.ttf` — SIL Open Font License 1.1
(`assets/fonts/OFL.txt`).
