# Plan d'implémentation v2 — MultiShop Tchad (App Unifiée)

## Contexte & Analyse du Projet Existant

Le projet actuel est basé sur **6valley v16.5** (6amTech), un e-commerce multi-vendeurs composé de :

- **User app** (`flutter_sixvalley_ecommerce`) — Flutter, 59 features, Provider + GetIt, GoRouter, Dio, ~750 lignes de DI
- **Vendor app** (`sixvalley_vendor_app`) — Flutter, 37 features, Provider + GetIt, routes classiques (pas GoRouter), Dio, ~37K DI
- **Backend** (`Admin V16.5`) — PHP 8.2 / Laravel 12, API REST v1 (customer) + v3 (seller), Passport/Sanctum, MySQL

> [!IMPORTANT]
> **Changement majeur** : Fusionner 2 apps Flutter séparées (96 features combinées) en **une seule app** avec routage basé sur le rôle utilisateur (client vs vendeur), tout en adaptant le modèle de données au cahier des charges Tchad.

---

## Décisions Validées

| # | Question | Décision |
|---|----------|----------|
| 1 | Backend | **Option A** — Adapter le Laravel 12 existant (6valley) |
| 2 | Features non-CDC | **Cachées mais fonctionnelles** — activables par un mécanisme secret développeur uniquement |
| 3 | Format NNI | Carte d'identité nationale : numéro, nom, prénom, date de naissance |
| 4 | Admin mobile | **Non** — l'admin utilise uniquement le panel web Laravel |
| 5 | Stockage photo porte | **Firebase Storage** + **serveur Laravel** (double stockage) |
| 6 | Package Flutter | `com.multishop.tchad` |

---

## Proposed Changes

L'implémentation est organisée en **9 phases** séquentielles.

---

### Phase 1 : Création du Projet Unifié & Structure de Base

Créer le nouveau projet Flutter à partir de l'app User (la plus complète), en y intégrant tout le code Vendor.

#### [NEW] Projet `multishop_tchad` — `com.multishop.tchad`

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart            # Constantes unifiées (base URL, API URIs)
│   │   ├── api_endpoints.dart            # Tous les endpoints (customer v1 + vendor v3)
│   │   └── payment_constants.dart        # Paliers réduction, frais annulation
│   ├── theme/
│   │   ├── light_theme.dart
│   │   ├── dark_theme.dart
│   │   ├── custom_themes.dart
│   │   └── controllers/
│   │       └── theme_controller.dart
│   ├── localization/
│   │   ├── controllers/
│   │   │   └── localization_controller.dart
│   │   ├── app_localization.dart
│   │   └── language_constrants.dart
│   ├── router/
│   │   ├── app_router.dart               # GoRouter unifié avec guards par rôle
│   │   ├── route_names.dart              # Constantes des noms de routes
│   │   └── role_guard.dart               # Middleware de vérification de rôle
│   ├── di/
│   │   └── di_container.dart             # DI unifiée (GetIt) — fusion des 2 containers
│   ├── models/                           # Modèles partagés
│   ├── services/
│   │   ├── datasource/remote/dio/
│   │   │   ├── dio_client.dart
│   │   │   └── logging_interceptor.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   ├── feature_vault/                    # NOUVEAU — Système de features cachées
│   │   ├── feature_vault.dart
│   │   ├── feature_registry.dart
│   │   └── vault_constants.dart
│   ├── helpers/
│   │   ├── api_checker.dart
│   │   ├── date_converter.dart
│   │   ├── price_converter.dart
│   │   ├── network_info.dart
│   │   ├── validate_check.dart
│   │   └── nni_validator.dart            # NOUVEAU — validation NNI
│   └── widgets/                          # Widgets partagés (fusion basewidgets)
│       ├── custom_button_widget.dart
│       ├── custom_textfield_widget.dart
│       ├── custom_snackbar_widget.dart
│       ├── custom_image_widget.dart
│       ├── shimmer_widget.dart
│       └── role_based_widget.dart         # NOUVEAU — widget conditionnel par rôle
├── features/
│   ├── auth/                             # Auth unifiée (Phase 2)
│   ├── customer/                         # Features client CDC (Phase 5)
│   ├── vendor/                           # Features vendeur CDC (Phase 6)
│   ├── shared/                           # Features partagées (Phase 7-8)
│   └── vault/                            # Features cachées non-CDC (Phase 3)
│       ├── auction/                      # Enchères (15 modules client + vendor)
│       ├── ai_shopping/                  # AI Shopping
│       ├── ai/                           # AI Vendor
│       ├── pos/                          # Point of Sale
│       ├── blog/                         # Blog
│       ├── clearance_sale/               # Soldes
│       ├── compare/                      # Comparateur
│       ├── coupon/                       # Coupons avancés
│       ├── deal/                         # Flash deals, Featured deals
│       ├── loyalty_point/                # Points fidélité
│       ├── refer_and_earn/               # Parrainage
│       ├── offline_payment/              # Paiement offline
│       ├── contact_us/                   # Contact
│       ├── support/                      # Tickets support
│       ├── vat_tax/                      # TVA client
│       ├── barcode/                      # Codes-barres vendor
│       ├── delivery_man/                 # Livreurs vendor
│       ├── third_party_deliveryman/      # Livreurs tiers
│       ├── emergency_contract/           # Contacts urgence
│       ├── order_edit/                   # Édition commandes
│       └── vat_management/              # TVA vendor
├── main.dart                             # Point d'entrée unique
└── di_container.dart
```

**Stack technique :**
- Package : `com.multishop.tchad`
- SDK Flutter : `^3.6.0`, Dart : `^3.6.0`
- State management : **Provider** + **GetIt** (existant)
- Routing : **GoRouter** (existant dans User app)
- HTTP : **Dio** (existant)
- Le `pubspec.yaml` fusionne les dépendances des deux apps (superset complet, rien n'est retiré)

---

### Phase 2 : Système FeatureVault — Features Cachées avec Activation Secrète

> [!IMPORTANT]
> **Concept clé** : Toutes les features non-CDC (enchères, AI, POS, blog, etc.) restent dans le code, compilées et fonctionnelles, mais **invisibles** dans l'UI. Seul le développeur d'origine connaît le mécanisme d'activation. Si le client souhaite ces features plus tard, c'est une mise à jour payante.

#### [NEW] `lib/core/feature_vault/`

```dart
// feature_vault.dart — Cœur du système
class FeatureVault {
  static final FeatureVault _instance = FeatureVault._();
  factory FeatureVault() => _instance;
  FeatureVault._();

  final SharedPreferences _prefs;
  
  /// Activation secrète : l'utilisateur doit effectuer une séquence
  /// précise dans l'app pour accéder au panneau développeur.
  /// 
  /// Mécanisme : Sur l'écran "À propos" (Settings), taper 7 fois
  /// sur le numéro de version, puis entrer un code PIN secret
  /// (hash SHA-256 stocké en dur, jamais en clair).
  /// 
  /// Le PIN déverrouille un écran caché avec des toggles par feature.
  
  static const String _vaultKeyPrefix = '_fv_';
  static const String _masterKey = 'v4u1t_m4st3r_k3y'; // Obfusqué
  
  // Hash SHA-256 du PIN secret (seul le dev d'origine le connaît)
  static const String _pinHash = ''; // À remplir au déploiement
  
  bool _isUnlocked = false;
  
  /// Vérifie si une feature est activée
  bool isEnabled(VaultFeature feature) {
    return _prefs.getBool('$_vaultKeyPrefix${feature.key}') ?? false;
  }
  
  /// Active/désactive une feature (nécessite unlock préalable)
  Future<void> toggle(VaultFeature feature, bool enabled) async {
    if (!_isUnlocked) return;
    await _prefs.setBool('$_vaultKeyPrefix${feature.key}', enabled);
  }
  
  /// Tente le déverrouillage avec un PIN
  bool unlock(String pin) {
    final hash = sha256.convert(utf8.encode(pin)).toString();
    _isUnlocked = (hash == _pinHash);
    return _isUnlocked;
  }
}
```

```dart
// feature_registry.dart — Registre de toutes les features cachées
enum VaultFeature {
  auction('auction', 'Enchères', 'Système d\'enchères complet'),
  aiShopping('ai_shopping', 'AI Shopping', 'Recherche par IA'),
  aiVendor('ai_vendor', 'AI Vendeur', 'Génération produits par IA'),
  pos('pos', 'Point de Vente', 'Système POS vendeur'),
  blog('blog', 'Blog', 'Module blog'),
  clearanceSale('clearance_sale', 'Soldes', 'Ventes de liquidation'),
  compare('compare', 'Comparateur', 'Comparaison de produits'),
  couponAdvanced('coupon', 'Coupons', 'Coupons avancés'),
  flashDeals('flash_deals', 'Deals Flash', 'Offres limitées'),
  featuredDeals('featured_deals', 'Deals Vedettes', 'Offres vedettes'),
  loyaltyPoints('loyalty', 'Fidélité', 'Points de fidélité'),
  referAndEarn('refer_earn', 'Parrainage', 'Parrainage et gains'),
  offlinePayment('offline_pay', 'Paiement Offline', 'Paiement hors ligne'),
  supportTickets('support', 'Support', 'Tickets support'),
  vatTax('vat_tax', 'TVA', 'Gestion TVA'),
  barcode('barcode', 'Codes-barres', 'Génération codes-barres'),
  deliveryManagement('delivery_mgmt', 'Livreurs', 'Gestion livreurs'),
  orderEdit('order_edit', 'Édition commande', 'Modification de commande');

  final String key;
  final String label;
  final String description;
  const VaultFeature(this.key, this.label, this.description);
}
```

**Comment ça s'intègre dans l'UI :**

```dart
// Exemple dans le dashboard client — un bouton n'apparaît que si la feature est activée
if (FeatureVault().isEnabled(VaultFeature.auction)) {
  // Afficher la section Enchères dans le menu
  ListTile(title: Text('Enchères'), onTap: () => context.go('/vault/auction')),
}

// Exemple dans le routeur — les routes vault ne sont accessibles que si activées
GoRoute(
  path: '/vault/auction',
  redirect: (context, state) {
    if (!FeatureVault().isEnabled(VaultFeature.auction)) return '/';
    return null;
  },
  builder: (context, state) => const AuctionHomeScreen(),
),
```

**Accès au panneau développeur (séquence secrète) :**
1. Aller dans **Paramètres > À propos**
2. Taper **7 fois** sur le numéro de version de l'app
3. Un champ de saisie PIN apparaît (discret, pas de titre explicite)
4. Saisir le **PIN secret** (ex: `7x9K#mT$2q`)
5. Si correct → Affiche l'écran `VaultControlPanel` avec des toggles pour chaque feature
6. Les changements prennent effet immédiatement
7. Le vault se re-verrouille à la fermeture de l'app

#### [NEW] `lib/features/vault/` — Code des features cachées

Toutes les features non-CDC sont déplacées dans ce dossier. Le code est conservé **intact** et fonctionnel, mais les routes et les éléments UI sont conditionnés par `FeatureVault().isEnabled(...)`.

Structure pour chaque feature vault :
```
features/vault/auction/
├── controllers/     # Intacts depuis User app + Vendor app
├── domain/          # Intacts
├── screens/         # Intacts
└── widgets/         # Intacts
```

Le DI container enregistre les providers vault **de manière conditionnelle** :
```dart
// di_container.dart
if (FeatureVault().isEnabled(VaultFeature.auction)) {
  sl.registerLazySingleton(() => AuctionHomeController(...));
  // ... tous les providers auction
}
```

---

### Phase 3 : Module Auth Unifié

Une seule page de connexion, deux flux d'inscription distincts, le rôle détermine l'interface.

#### [NEW] `lib/features/auth/`

```
features/auth/
├── controllers/
│   ├── auth_controller.dart              # Controller unifié (merge des 2 apps)
│   ├── google_login_controller.dart      # Google Sign-In
│   └── registration_controller.dart      # NOUVEAU — gère les 2 types d'inscription
├── domain/
│   ├── models/
│   │   ├── user_model.dart               # Modèle unifié (role: customer|vendor)
│   │   ├── register_customer_model.dart  # + NNI
│   │   ├── register_vendor_model.dart    # + NNI + shop info
│   │   ├── login_model.dart
│   │   ├── nni_model.dart                # NOUVEAU — modèle NNI
│   │   └── social_login_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── auth_repository_interface.dart
│   └── services/
│       ├── auth_service.dart
│       └── auth_service_interface.dart
├── enums/
│   ├── user_role.dart                    # enum UserRole {customer, vendor}
│   └── from_page.dart
├── screens/
│   ├── login_screen.dart                 # Page connexion unique
│   ├── register_choice_screen.dart       # NOUVEAU — "Client" ou "Vendeur"
│   ├── customer_register_screen.dart     # Inscription client (nom, email, mdp, NNI, tel)
│   ├── vendor_register_screen.dart       # Inscription vendeur (+ magasin, logo, catégorie)
│   ├── vendor_pending_screen.dart        # NOUVEAU — attente validation admin
│   ├── forgot_password_screen.dart
│   ├── otp_verification_screen.dart
│   └── reset_password_screen.dart
└── widgets/
    ├── social_login_widget.dart
    ├── nni_input_widget.dart              # NOUVEAU — champ NNI avec validation
    └── phone_input_widget.dart            # NOUVEAU — téléphone Tchad (Airtel/Moov)
```

**Modèle NNI :**
```dart
class NniModel {
  final String? id;
  final String nniNumber;        // Numéro unique de la carte
  final String firstName;        // Prénom
  final String lastName;         // Nom
  final DateTime dateOfBirth;    // Date de naissance
  final String? placeOfBirth;    // Lieu de naissance (optionnel)
  final String? gender;          // Sexe (optionnel)
  final bool isVerified;
  
  // ... constructeur, fromJson, toJson
}
```

**Modèle d'inscription client (modifié) :**
```dart
class RegisterCustomerModel {
  String? fullName;
  String? email;         // Gmail
  String? password;      // Min 8 chars
  String? phone;         // Airtel ou Moov
  // NNI
  String? nniNumber;
  String? nniFirstName;
  String? nniLastName;
  DateTime? nniDateOfBirth;
}
```

**Modèle d'inscription vendeur (modifié) :**
```dart
class RegisterVendorModel {
  String? fullName;
  String? email;
  String? password;
  String? phone;
  // NNI
  String? nniNumber;
  String? nniFirstName;
  String? nniLastName;
  DateTime? nniDateOfBirth;
  // Magasin
  String? shopName;
  String? shopDescription;
  File? shopLogo;
  String? shopCategory;
}
```

**Flux :**
```
Splash → Login Screen
  ├── Email + Mot de passe → API login → user.role ?
  │     ├── "customer"                          → Dashboard Client
  │     ├── "vendor" + is_active=true           → Dashboard Vendeur
  │     └── "vendor" + is_active=false          → Vendor Pending Screen
  ├── Google Sign-In → API social login → même logique
  └── Pas de compte ? → Register Choice Screen
                          ├── "Client"  → Customer Register (+ NNI)
                          └── "Vendeur" → Vendor Register (+ NNI + Shop)
                                            → Vendor Pending Screen
```

---

### Phase 4 : Routeur Unifié avec Role Guards

#### [NEW] `lib/core/router/app_router.dart`

Remplace le `route_helper.dart` (2019 lignes) de l'app User et la navigation classique du Vendor.

```dart
GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/splash',
  redirect: globalRoleGuard,
  routes: [
    // === ROUTES PUBLIQUES (pas de guard) ===
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register/choice', builder: (_, __) => const RegisterChoiceScreen()),
    GoRoute(path: '/register/customer', builder: (_, __) => const CustomerRegisterScreen()),
    GoRoute(path: '/register/vendor', builder: (_, __) => const VendorRegisterScreen()),
    GoRoute(path: '/vendor-pending', builder: (_, __) => const VendorPendingScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/maintenance', builder: (_, __) => const MaintenanceScreen()),

    // === ROUTES CLIENT (guard: role == customer) ===
    ShellRoute(
      builder: (_, __, child) => CustomerDashboardShell(child: child),
      routes: [
        GoRoute(path: '/customer/home', ...),
        GoRoute(path: '/customer/categories', ...),
        GoRoute(path: '/customer/cart', ...),
        GoRoute(path: '/customer/orders', ...),
        GoRoute(path: '/customer/profile', ...),
      ],
    ),
    // Sous-routes client (pas dans le shell BottomNav)
    GoRoute(path: '/customer/product/:id', ...),
    GoRoute(path: '/customer/checkout', ...),
    GoRoute(path: '/customer/order/:id', ...),
    GoRoute(path: '/customer/order/:id/cancel', ...),
    GoRoute(path: '/customer/order/:id/reduction', ...),
    GoRoute(path: '/customer/shop/:slug', ...),
    GoRoute(path: '/customer/search', ...),
    GoRoute(path: '/customer/wishlist', ...),
    // ...

    // === ROUTES VENDEUR (guard: role == vendor + is_active) ===
    ShellRoute(
      builder: (_, __, child) => VendorDashboardShell(child: child),
      routes: [
        GoRoute(path: '/vendor/dashboard', ...),
        GoRoute(path: '/vendor/products', ...),
        GoRoute(path: '/vendor/orders', ...),
        GoRoute(path: '/vendor/statistics', ...),
        GoRoute(path: '/vendor/profile', ...),
      ],
    ),
    // Sous-routes vendeur
    GoRoute(path: '/vendor/product/add', ...),
    GoRoute(path: '/vendor/product/:id/edit', ...),
    GoRoute(path: '/vendor/order/:id', ...),
    GoRoute(path: '/vendor/shop/edit', ...),
    GoRoute(path: '/vendor/reduction-requests', ...),
    // ...

    // === ROUTES PARTAGÉES ===
    GoRoute(path: '/notifications', ...),
    GoRoute(path: '/chat/:id', ...),
    GoRoute(path: '/settings', ...),

    // === ROUTES VAULT (guard: feature activée) ===
    // Chaque route vault vérifie FeatureVault().isEnabled(...)
    GoRoute(path: '/vault/auction', redirect: vaultGuard(VaultFeature.auction), ...),
    GoRoute(path: '/vault/ai-shopping', redirect: vaultGuard(VaultFeature.aiShopping), ...),
    GoRoute(path: '/vault/pos', redirect: vaultGuard(VaultFeature.pos), ...),
    // ...
  ],
)
```

**`RoleGuard` :**
```dart
String? globalRoleGuard(BuildContext context, GoRouterState state) {
  final auth = Provider.of<AuthController>(context, listen: false);
  final isLoggedIn = auth.isLoggedIn;
  final role = auth.userRole;
  final isVendorActive = auth.isVendorActive;
  final path = state.matchedLocation;
  
  // Routes publiques → pas de guard
  if (isPublicRoute(path)) return null;
  
  // Non connecté → login
  if (!isLoggedIn) return '/login';
  
  // Vendeur non validé → écran d'attente
  if (role == UserRole.vendor && !isVendorActive && path != '/vendor-pending') {
    return '/vendor-pending';
  }
  
  // Client qui tente d'accéder aux routes vendor
  if (role == UserRole.customer && path.startsWith('/vendor')) {
    return '/customer/home';
  }
  
  // Vendeur qui tente d'accéder aux routes customer
  if (role == UserRole.vendor && path.startsWith('/customer')) {
    return '/vendor/dashboard';
  }
  
  return null; // OK
}
```

---

### Phase 5 : Modifications Backend Laravel

#### [MODIFY] Backend Laravel — Nouvelles migrations

##### Table `nni_records` (NOUVELLE)

```sql
CREATE TABLE nni_records (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT UNSIGNED NOT NULL,
    nni_number    VARCHAR(30) NOT NULL UNIQUE,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    place_of_birth VARCHAR(150) NULL,
    gender        ENUM('male','female') NULL,
    document_type ENUM('nni','passport') DEFAULT 'nni',
    is_verified   BOOLEAN DEFAULT FALSE,
    verified_at   TIMESTAMP NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_nni_number (nni_number)
);
```

> [!NOTE]
> Table séparée comme demandé — permet de modifier le schéma NNI indépendamment des users (ajout de champs, vérification externe, historique de mises à jour, etc.)

##### Table `price_reduction_requests` (NOUVELLE)

```sql
CREATE TABLE price_reduction_requests (
    id                    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id              BIGINT UNSIGNED NOT NULL,
    customer_id           BIGINT UNSIGNED NOT NULL,
    vendor_id             BIGINT UNSIGNED NOT NULL,
    original_price        DECIMAL(12,2) NOT NULL,
    requested_reduction   DECIMAL(12,2) NOT NULL,
    proposed_price        DECIMAL(12,2) NULL,
    status                ENUM('pending','accepted','refused','counter_offer',
                               'counter_accepted','counter_refused') DEFAULT 'pending',
    counter_offer_amount  DECIMAL(12,2) NULL,
    round_number          TINYINT UNSIGNED DEFAULT 1,  -- Max 2 allers-retours
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (vendor_id) REFERENCES users(id)
);
```

##### Table `reduction_tiers` (NOUVELLE)

```sql
CREATE TABLE reduction_tiers (
    id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tier      TINYINT UNSIGNED NOT NULL,
    amount    DECIMAL(12,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO reduction_tiers (tier, amount) VALUES
(1, 250), (2, 500), (3, 1000), (4, 1500), (5, 2000),
(6, 2500), (7, 3000), (8, 3500), (9, 4000), (10, 5000), (11, 10000);
```

##### Colonnes ajoutées à `orders`

```sql
ALTER TABLE orders
ADD COLUMN has_reduction BOOLEAN DEFAULT FALSE,
ADD COLUMN reduction_amount DECIMAL(12,2) DEFAULT 0,
ADD COLUMN final_price DECIMAL(12,2) NULL,
ADD COLUMN cancellation_fee DECIMAL(12,2) DEFAULT 1000.00,
ADD COLUMN door_photo_url VARCHAR(500) NULL,
ADD COLUMN door_photo_firebase_url VARCHAR(500) NULL,
ADD COLUMN door_latitude DECIMAL(10,8) NULL,
ADD COLUMN door_longitude DECIMAL(11,8) NULL;
```

##### Nouveaux Endpoints API

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| **POST** | `/api/v1/auth/register` | Inscription client **(modifié: + NNI avec noms/date)** |
| **POST** | `/api/v3/seller/registration` | Inscription vendeur **(modifié: + NNI)** |
| **GET** | `/api/v1/reduction-tiers` | Liste des paliers de réduction |
| **POST** | `/api/v1/customer/order/{id}/request-reduction` | Demander une réduction |
| **GET** | `/api/v1/customer/reduction-requests` | Mes demandes de réduction |
| **GET** | `/api/v3/seller/reduction-requests` | Demandes reçues (vendeur) |
| **PUT** | `/api/v3/seller/reduction-requests/{id}/respond` | Accepter/Refuser/Contre-proposer |
| **POST** | `/api/v1/customer/order/{id}/cancel` | Annuler commande (1000 FCFA fixe) |
| **POST** | `/api/v1/payments/airtel-money` | Paiement Airtel Money (stub) |
| **POST** | `/api/v1/payments/moov-money` | Paiement Moov Money (stub) |
| **GET** | `/api/v1/payments/{id}/status` | Statut paiement |

---

### Phase 6 : Features Client (Customer)

Adaptation des features existantes de l'app User au CDC Tchad. **Rien n'est supprimé** — les features non-CDC sont déplacées dans `features/vault/`.

#### [MODIFY] `lib/features/customer/` — Features CDC actives

| Dossier | Source | Modifications |
|---------|--------|---------------|
| `home/` | User `features/home/` | Simplifier l'accueil : produits vedettes, catégories, recherche. Les deals/clearance sont masqués sauf si vault activé |
| `cart/` | User `features/cart/` | Ajouter **regroupement par magasin**, **bouton demande réduction** |
| `checkout/` | User `features/checkout/` | Modifier: adresse Tchad (quartier/rue/photo porte géolocalisée), paiement Airtel/Moov uniquement |
| `orders/` | User `features/order/` + `order_details/` | Statuts visuels colorés, bouton annulation 1000 FCFA, suivi temps réel |
| `product_details/` | User `features/product_details/` | Adaptation CDC : couleurs visuelles, tailles, marque/modèle |
| `search/` | User `features/search_product/` | Filtres CDC : catégorie, magasin, prix, marque, couleur, taille |
| `wishlist/` | User `features/wishlist/` | Conservé tel quel |
| `profile/` | User `features/profile/` | Ajouter affichage NNI |
| `shop/` | User `features/shop/` | Conservé (vue boutique vendeur) |
| `category/` | User `features/category/` | Conservé |
| `brand/` | User `features/brand/` | Conservé |
| `wallet/` | User `features/wallet/` | Conservé |
| `chat/` | User `features/chat/` | Conservé (communication client-vendeur) |
| `notification/` | User `features/notification/` | Adapter les types au CDC |

#### [NEW] `lib/features/customer/price_reduction/`

```
price_reduction/
├── controllers/
│   └── price_reduction_controller.dart
├── domain/
│   ├── models/
│   │   ├── reduction_tier_model.dart
│   │   └── reduction_request_model.dart
│   ├── repositories/
│   └── services/
├── screens/
│   └── reduction_request_screen.dart
└── widgets/
    ├── tier_selection_widget.dart         # Liste des 11 paliers
    ├── reduction_status_widget.dart       # Statut en temps réel
    └── counter_offer_dialog.dart          # Dialogue contre-proposition
```

#### [NEW] `lib/features/customer/order_cancellation/`

```
order_cancellation/
├── controllers/
│   └── cancellation_controller.dart
├── screens/
│   └── cancellation_screen.dart           # Confirmation + paiement 1000 FCFA
└── widgets/
    ├── cancellation_fee_widget.dart
    └── cancellation_confirmation_dialog.dart
```

#### [MOVE → Vault] Features non-CDC client

Ces features sont déplacées de `features/` vers `features/vault/` et conditionnées par FeatureVault :

| Feature déplacée | VaultFeature enum |
|---|---|
| `auction*` (15 modules) | `VaultFeature.auction` |
| `ai_shopping/` | `VaultFeature.aiShopping` |
| `blog/` | `VaultFeature.blog` |
| `clearance_sale/` | `VaultFeature.clearanceSale` |
| `compare/` | `VaultFeature.compare` |
| `coupon/` | `VaultFeature.couponAdvanced` |
| `deal/` (flash + featured) | `VaultFeature.flashDeals` / `VaultFeature.featuredDeals` |
| `loyaltyPoint/` | `VaultFeature.loyaltyPoints` |
| `refer_and_earn/` | `VaultFeature.referAndEarn` |
| `offline_payment/` | `VaultFeature.offlinePayment` |
| `contact_us/` | `VaultFeature.supportTickets` |
| `support/` | `VaultFeature.supportTickets` |
| `vat_tax/` | `VaultFeature.vatTax` |

---

### Phase 7 : Features Vendeur (Vendor)

Migration des features Vendor app vers le module unifié.

#### [MODIFY] `lib/features/vendor/` — Features CDC actives

| Dossier | Source | Modifications |
|---------|--------|---------------|
| `dashboard/` | Vendor `features/dashboard/` | Stats ventes, CA, commandes, **section demandes réduction** |
| `products/` | Vendor `features/addProduct/` + `product/` | Champs CDC : nom, prix FCFA, catégorie, marque, modèle, couleurs, tailles, stock, 1-5 images, réduction |
| `orders/` | Vendor `features/order/` + `order_details/` | Filtres par statut, changement statut, notif client |
| `shop/` | Vendor `features/shop/` | Modif infos, logo, horaires, zone livraison |
| `statistics/` | Vendor (Syncfusion Charts existant) | Ventes jour/semaine/mois, CA, top produits |
| `profile/` | Vendor `features/profile/` | Ajouter affichage NNI |
| `chat/` | Vendor `features/chat/` | Conservé |
| `notification/` | Vendor `features/notification/` | Adapter types CDC |

#### [NEW] `lib/features/vendor/reduction_requests/`

```
reduction_requests/
├── controllers/
│   └── vendor_reduction_controller.dart
├── screens/
│   ├── reduction_requests_list_screen.dart
│   └── reduction_request_detail_screen.dart
└── widgets/
    ├── reduction_action_widget.dart        # Accepter/Refuser/Contre-proposer
    └── counter_offer_input_widget.dart
```

#### [MOVE → Vault] Features non-CDC vendeur

| Feature déplacée | VaultFeature enum |
|---|---|
| `pos/` | `VaultFeature.pos` |
| `barcode/` | `VaultFeature.barcode` |
| `delivery_man/` | `VaultFeature.deliveryManagement` |
| `third_party_deliveryman/` | `VaultFeature.deliveryManagement` |
| `auction/` | `VaultFeature.auction` |
| `ai/` | `VaultFeature.aiVendor` |
| `coupon/` | `VaultFeature.couponAdvanced` |
| `emergency_contract/` | `VaultFeature.deliveryManagement` |
| `order_edit/` | `VaultFeature.orderEdit` |
| `vat_management/` | `VaultFeature.vatTax` |
| `bank_info/` | Conservé dans vendor (utile pour les paiements) |

---

### Phase 8 : Module Paiement Mobile Money (Stub)

#### [NEW] `lib/features/shared/payment/`

```
payment/
├── controllers/
│   └── payment_controller.dart
├── domain/
│   ├── models/
│   │   ├── payment_model.dart
│   │   └── payment_method.dart           # Enum: airtel_money, moov_money
│   ├── repositories/
│   └── services/
│       ├── payment_service.dart
│       ├── payment_gateway.dart           # Interface abstraite
│       ├── airtel_money_gateway.dart      # STUB
│       └── moov_money_gateway.dart        # STUB
├── screens/
│   ├── payment_method_screen.dart         # Choix Airtel ou Moov
│   ├── payment_processing_screen.dart     # Chargement / WebView API
│   └── payment_result_screen.dart         # Succès / Échec
└── widgets/
    ├── payment_method_card.dart
    └── payment_status_indicator.dart
```

**Architecture Gateway :**
```dart
abstract class PaymentGateway {
  Future<PaymentResult> initiatePayment(PaymentRequest request);
  Future<PaymentStatus> checkStatus(String transactionId);
  Future<RefundResult> refund(String transactionId, double amount);
}

class AirtelMoneyGateway implements PaymentGateway {
  // TODO: Implémenter quand l'API Airtel Money sera disponible
  @override
  Future<PaymentResult> initiatePayment(PaymentRequest request) async {
    throw UnimplementedError('Airtel Money API non encore configurée');
  }
}

class MoovMoneyGateway implements PaymentGateway {
  // TODO: Implémenter quand l'API Moov Money sera disponible
  @override
  Future<PaymentResult> initiatePayment(PaymentRequest request) async {
    throw UnimplementedError('Moov Money API non encore configurée');
  }
}
```

> [!NOTE]
> Quand les endpoints de paiement seront disponibles, il suffira d'implémenter les méthodes dans `AirtelMoneyGateway` et `MoovMoneyGateway` sans toucher au reste du code.

---

### Phase 9 : Notifications, Localisation & Finitions

#### [MODIFY] Notifications FCM

Adapter le système existant aux types CDC :

| Notification | Destinataire | Déclencheur |
|---|---|---|
| Validation magasin | Vendeur | Admin valide/rejette |
| Nouvelle commande | Vendeur | Client passe commande |
| Changement statut | Client | Vendeur modifie statut |
| Annulation | Vendeur | Client annule |
| Demande réduction | Vendeur | Client demande réduction |
| Réponse réduction | Client | Vendeur répond |
| Promotion | Client | Nouvelle offre |
| Rappel panier | Client | Panier abandonné 24h |

#### [MODIFY] Localisation

- Français comme langue par défaut
- Nouvelles clés de traduction pour : réduction, annulation, NNI, photo de porte, Airtel/Moov
- Conserver le système existant (`assets/language/` + `AppLocalization`)

#### [MODIFY] Photo de porte — Double stockage

```dart
class DoorPhotoService {
  final FirebaseStorage _firebaseStorage;
  final DioClient _dioClient;
  
  /// Upload la photo sur Firebase Storage ET sur le serveur Laravel
  Future<DoorPhotoResult> uploadDoorPhoto(File photo, LatLng coordinates) async {
    // 1. Upload Firebase Storage
    final firebaseUrl = await _uploadToFirebase(photo);
    
    // 2. Upload serveur Laravel (via API multipart)
    final serverUrl = await _uploadToServer(photo);
    
    return DoorPhotoResult(
      firebaseUrl: firebaseUrl,
      serverUrl: serverUrl,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    );
  }
}
```

---

## Résumé des fichiers impactés

| Type | Quantité estimée | Description |
|---|---|---|
| **Nouveaux fichiers** | ~55 | FeatureVault, réduction, annulation, NNI, payment stubs, guards, router |
| **Fichiers déplacés** (→ vault) | ~150 | Features non-CDC déplacées dans `features/vault/` |
| **Fichiers modifiés** | ~80 | Auth, checkout, orders, products, models, constants, DI |
| **Fichiers supprimés** | **0** | Aucun fichier supprimé |
| **Migrations Laravel** | 4 | nni_records, price_reduction_requests, reduction_tiers, alter orders |
| **Routes API Laravel** | ~10 | Nouveaux endpoints réduction/annulation/paiement |
| **Modèles Laravel** | ~4 | NniRecord, PriceReductionRequest, ReductionTier + modifs User/Order |

---

## Verification Plan

### Automated Tests

```bash
# Build Flutter (vérification compilation)
flutter build apk --debug

# Analyse statique
flutter analyze

# Tests unitaires
flutter test
```

### Manual Verification

1. **Flux auth client** : Inscription avec NNI → Login → Dashboard client
2. **Flux auth vendeur** : Inscription + shop → Écran pending → (admin valide) → Dashboard vendeur
3. **Role guard** : Client ne voit pas les pages vendeur, et inversement
4. **FeatureVault** : Taper 7x sur version → PIN → activer enchères → visible dans le menu → désactiver → invisible
5. **Commande** : Produits → Panier → Checkout (quartier/rue/photo porte) → Paiement stub → Confirmation
6. **Réduction** : Choisir palier → Envoyer → Vendeur accepte/refuse → Prix mis à jour
7. **Annulation** : Annuler avant expédition → Confirmer 1000 FCFA → Commande annulée
8. **Photo de porte** : Capturer → Vérifier upload Firebase + serveur Laravel
9. **Mode sombre** : Vérifier tous les écrans
10. **Notifications FCM** : Vérifier chaque type de notification

---

## Estimation de Charge

| Phase | Effort estimé |
|---|---|
| Phase 1 : Structure projet unifié | 2-3 jours |
| Phase 2 : FeatureVault (système features cachées) | 2-3 jours |
| Phase 3 : Auth unifiée + NNI | 3-4 jours |
| Phase 4 : Router + Guards | 2-3 jours |
| Phase 5 : Backend Laravel (migrations + API) | 3-5 jours |
| Phase 6 : Features client CDC | 5-7 jours |
| Phase 7 : Features vendeur CDC | 4-6 jours |
| Phase 8 : Paiement Mobile Money (stub) | 1-2 jours |
| Phase 9 : Notifications + localisation + finitions | 2-3 jours |
| **Total** | **~24-36 jours** |
