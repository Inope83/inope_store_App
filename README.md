<div align="center">
  <img src="assets/logo.png" alt="Inope Store Logo" width="120" height="120" />
  <h1>Inope Store</h1>
  <p><strong>Fashion ba Hotu — Fashion for Everyone</strong></p>
  <p>
    <a href="#features">Features</a> •
    <a href="#tech-stack">Tech Stack</a> •
    <a href="#prerequisites">Prerequisites</a> •
    <a href="#installation">Installation</a> •
    <a href="#configuration">Configuration</a> •
    <a href="#api">API</a>
  </p>
</div>

---

Inope Store is a full-stack fashion e-commerce application built with **Flutter** and **Django REST Framework**, targeted at the Timorese market with a Tetum-language interface. It provides a complete shopping experience from product browsing to checkout, along with a full admin dashboard.

---

## Features

### Customer Features
- **Browse Products** — Grid layout with category filtering and live search
- **Product Details** — Image gallery, size/color selectors, stock indicators, ratings
- **Shopping Cart** — Quantity controls (respects stock limits), live total calculation
- **Checkout** — Cash on Delivery (COD) or Bank Transfer (BNU, Telemor, DST, T-Pay)
- **Order History** — Track order status (Pending / Finished / Cancelled)
- **User Profile** — Edit name/phone, view order stats
- **Wishlist** — Save products for later

### Admin Features
- **Dashboard** — Revenue, product/order/user counts, recent orders
- **Product Management** — CRUD with image upload (multiple), stock tracking
- **Order Management** — View, filter, update status (finish/cancel)
- **Category Management** — CRUD for product categories
- **User Management** — View all users and their roles

### Technical Features
- JWT authentication with automatic token refresh
- Stock validation on both client and server
- Image upload (products, payment proofs)
- Responsive layout (mobile + desktop)
- Environment-based configuration

---

## Screenshots

> *Coming soon — add your app screenshots in `screenshots/` directory.*

| Home | Shop | Product Detail | Cart |
|------|------|---------------|------|
|      |      |               |      |

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Frontend** | Flutter / Dart | >=3.0 |
| **State Management** | GetX | ^4.6.6 |
| **Backend** | Django | >=6.0 |
| **API Framework** | Django REST Framework | >=3.17 |
| **Authentication** | JWT (SimpleJWT) | >=5.5 |
| **Database** | SQLite (dev) / PostgreSQL (prod) | — |
| **Image Handling** | Pillow | >=12.2 |
| **CORS** | django-cors-headers | >=4.9 |
| **Filtering** | django-filter | >=25.2 |

---

## Prerequisites

Make sure you have the following installed:

- **Flutter SDK** (>=3.0) — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (>=3.0, included with Flutter)
- **Python** (>=3.10) — [Install Python](https://www.python.org/downloads/)
- **pip** (Python package manager)
- **Git**

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/inope83/inope_store.git
cd inope_store
```

### 2. Backend Setup (Django)

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate it
# Linux / macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Create a superuser (admin)
python manage.py createsuperuser

# Start the development server
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000/api/`.

### 3. Frontend Setup (Flutter)

Open a new terminal:

```bash
cd inope_store

# Get Flutter dependencies
flutter pub get

# Run the app
flutter run
```

> **For Android emulator**, the app automatically uses `10.0.2.2` to reach the host machine.
> For a **physical device**, set `API_URL` at build time:
> ```bash
> flutter run --dart-define=API_URL=http://<your-lan-ip>:8000/api
> ```

---

## Configuration

### Environment Variables (Backend)

| Variable | Default | Description |
|----------|---------|-------------|
| `DJANGO_SECRET_KEY` | `django-insecure-dev-only-change-me` | Secret key for Django |
| `DJANGO_DEBUG` | `True` | Debug mode (`1`/`true`/`yes`/`on`) |
| `DJANGO_ALLOWED_HOSTS` | `localhost,127.0.0.1,...` | Comma-separated allowed hosts |
| `DJANGO_SECURE_SSL_REDIRECT` | `False` | Redirect HTTP → HTTPS |
| `DJANGO_HSTS_SECONDS` | `0` | HSTS header seconds |

### Admin Email

The backend auto-assigns admin role to the user registered with:

```
angelinorosaleslopes1234@gmail.com
```

You can change this in `backend/config/settings.py` (`ADMIN_EMAIL`).

---

## Running

### Start Backend

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Start Flutter App

```bash
flutter run
```

Or build a release APK:

```bash
flutter build apk --release
```

---

## Project Structure

```
inope_store/
├── backend/                    # Django REST Framework backend
│   ├── accounts/              # User auth & profiles
│   ├── config/                # Django settings
│   ├── shop/                  # Products, cart, orders, wishlist
│   ├── media/                 # Uploaded images
│   ├── db.sqlite3             # Development database
│   ├── manage.py
│   └── requirements.txt
│
├── lib/                        # Flutter frontend
│   ├── controllers/           # GetX controllers (auth, cart, product, order, admin)
│   ├── models/                # Data models (Product, User, CartItem, Order, Wishlist)
│   ├── screens/               # UI screens (Splash, Login, Home, Shop, Cart, Checkout, Profile, Admin)
│   ├── services/              # API service (HTTP client with JWT refresh)
│   ├── utils/                 # Formatting helpers
│   └── widgets/               # Reusable widgets (CustomButton)
│
├── test/                       # Unit & widget tests
├── android/                    # Android platform files
├── ios/                        # iOS platform files
├── web/                        # Web platform files
├── linux/                      # Linux platform files
├── macos/                      # macOS platform files
├── windows/                    # Windows platform files
│
├── pubspec.yaml
└── README.md
```

---

## API Overview

All endpoints are prefixed with `/api/`.

### Authentication (`/api/auth/`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `register/` | Create account (returns JWT) |
| POST | `login/` | Login (returns JWT) |
| GET | `profile/` | Get current user profile |
| PUT | `profile/` | Update profile |
| POST | `logout/` | Logout |
| POST | `token/refresh/` | Refresh JWT |

### Shop (`/api/`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST | `products/` | List / create products |
| GET/PUT/DELETE | `products/<id>/` | Retrieve / update / delete product |
| GET/POST | `categories/` | List / create categories |
| GET/PUT/DELETE | `categories/<id>/` | Manage category |
| GET | `cart/` | List cart items |
| POST | `cart/add/` | Add item to cart |
| PUT/DELETE | `cart/item/<id>/` | Update / remove cart item |
| DELETE | `cart/clear/` | Clear cart |
| GET | `orders/` | List my orders |
| POST | `orders/create/` | Create order from cart |
| GET | `wishlist/` | List wishlist |

### Admin (`/api/admin/`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `admin/orders/` | All orders (filter by `?status=`) |
| PUT | `admin/orders/<id>/status/` | Update order status |
| GET | `admin/stats/` | Dashboard statistics |
| GET | `admin/users/` | List all users |

---

## Running Tests

### Flutter Tests

```bash
flutter test
```

### Django Tests

```bash
cd backend
python manage.py test
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>
    Built with Flutter & Django<br>
    Timor-Leste
  </p>
</div>
