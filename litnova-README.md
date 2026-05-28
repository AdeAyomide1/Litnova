# LitNOVA

> A multi-format reading platform for novels, manga, comics, webtoons, and audio stories — with a Flutter mobile app, Node.js backend, and a React admin panel.

![Status](https://img.shields.io/badge/status-active-brightgreen)
![Mobile](https://img.shields.io/badge/mobile-Flutter-blue)
![Backend](https://img.shields.io/badge/backend-Node.js%20%2F%20Express-green)
![Database](https://img.shields.io/badge/database-PostgreSQL-blue)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## Overview

LitNOVA is a feature-rich reading platform inspired by apps like Tachiyomi and Webtoon. It supports multiple content formats — novels, manga, comics, webtoons, and audio stories — all in one place. Content is sourced from MangaDex and Project Gutenberg via sync scripts, and the platform features a fully customizable reading experience with themes, accent colors, and home screen layouts.

---

## Features

- 📚 **Multi-format support** — Novels, Manga, Comics, Webtoons, Audio Stories
- 🔌 **Extension/Sources system** — Tachiyomi-inspired plugin architecture
- 🎨 **Theme & accent color customization** — Per-user preferences stored with Hive
- 🏠 **Home screen layout customization** — Drag and reorder sections
- 📖 **In-app reader** — Dedicated reader screens per content type
- 🔄 **Content sync** — MangaDex and Project Gutenberg sync scripts
- 🛠️ **Admin panel** — Full React/Vite web dashboard for content management
- 🔐 **Authentication** — User accounts with JWT auth

---

## Tech Stack

### Mobile App
- **Framework** — Flutter (Dart)
- **Local storage** — Hive
- **State management** — Provider / Riverpod

### Backend
- **Runtime** — Node.js
- **Framework** — Express.js
- **Database** — PostgreSQL
- **Auth** — JWT

### Admin Panel
- **Framework** — React
- **Build tool** — Vite

---

## Getting Started

### Prerequisites

- Node.js v18+
- PostgreSQL
- Flutter SDK
- npm / yarn

---

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/litnova.git

# Navigate to backend
cd litnova/backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Fill in your PostgreSQL credentials and JWT secret

# Run database migrations
npm run migrate

# Start the server
npm run dev
```

---

### Mobile App Setup

```bash
# Navigate to mobile app
cd litnova/mobile

# Get Flutter packages
flutter pub get

# Run the app
flutter run
```

---

### Admin Panel Setup

```bash
# Navigate to admin panel
cd litnova/admin

# Install dependencies
npm install

# Start dev server
npm run dev
```

---

## Project Structure

```
litnova/
├── backend/
│   ├── routes/         # API route handlers
│   ├── controllers/    # Business logic
│   ├── models/         # Database models
│   ├── middleware/     # Auth & error handling
│   ├── scripts/        # MangaDex & Gutenberg sync
│   └── server.js       # Entry point
├── mobile/
│   ├── lib/
│   │   ├── screens/    # 15+ app screens
│   │   ├── widgets/    # Reusable components
│   │   ├── models/     # Data models
│   │   └── main.dart   # Entry point
└── admin/
    ├── src/
    │   ├── pages/      # Admin dashboard pages
    │   └── components/ # UI components
    └── index.html
```

---

## API Overview

The backend exposes a RESTful API covering:

- `Auth` — Register, login, token refresh
- `Content` — CRUD for novels, manga, comics, webtoons, audio
- `Chapters` — Chapter listing and content delivery
- `Sources` — Extension/source management
- `Users` — Profile and preferences
- `Admin` — Content moderation and management

---

## Roadmap

- [x] Flutter mobile app (15+ screens)
- [x] Node.js/Express backend
- [x] PostgreSQL database
- [x] React/Vite admin panel
- [x] MangaDex & Gutenberg sync scripts
- [x] Theme & layout customization
- [x] Tachiyomi-inspired extension system
- [ ] Novel chapter reader fix
- [ ] Audio story player
- [ ] Offline reading support
- [ ] Push notifications

---

## Screenshots

> *(Add screenshots of your app screens here)*

---

## Author

**Adebayo Suleiman Ayomide**
Computer Science, 200 Level — Veritas University Abuja
[GitHub](https://github.com/yourusername) · [Portfolio](https://yourportfolio.com)

---

## License

This project is licensed under the MIT License.
