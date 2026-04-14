# IT CLUB Application — Deployment Proof

**Project Name:** IT CLUB (Cyber Nauts)  
**Developer:** Mahalakshmi & Team  
**Date of Deployment:** 14 April 2026  
**Version:** v1.0.0  

---

## 1. Deployment Summary

| Field | Details |
|-------|---------|
| **Application Name** | IT CLUB (Cyber Nauts) |
| **Platform** | Android (Flutter) |
| **Package Name** | `com.itclub.college_club_app` |
| **Version** | v1.0.0 |
| **APK Size** | 54.9 MB |
| **Release Date** | 14 April 2026, 10:50 AM IST |
| **Deployment Method** | GitHub Releases |
| **Download URL** | [https://github.com/Mahalakshmi77777/IT_CYBERNUARTS/releases/tag/v1.0.0](https://github.com/Mahalakshmi77777/IT_CYBERNUARTS/releases/tag/v1.0.0) |

---

## 2. Technology Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.x (Dart) |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **Backend (Auth)** | Supabase Authentication |
| **Backend (Database)** | Supabase PostgreSQL |
| **Backend (Storage)** | Supabase Storage (event-images bucket) |
| **Version Control** | Git + GitHub |
| **Deployment** | GitHub Releases (Free Tier) |

---

## 3. Backend Configuration

| Service | Details |
|---------|---------|
| **Supabase Project URL** | `https://mbqoxgkxzkhylisobbco.supabase.co` |
| **Database** | PostgreSQL (hosted by Supabase) |
| **Storage Bucket** | `event-images` (Public) |
| **Authentication** | Email + Password (Supabase Auth) |
| **Row Level Security** | Enabled on all tables |

### Database Tables
- `public.users` — User profiles (linked to Supabase Auth)
- `public.clubs` — Club information
- `public.events` — Event records with cloud-hosted banner URLs
- `public.registrations` — User ↔ Event registrations

---

## 4. Application Features

### Admin Panel
- ✅ Create, edit, and delete events
- ✅ Upload event banner images (stored in Supabase Storage)
- ✅ Set event details: title, description, venue, dates, max participants, tags
- ✅ View registered participants

### User Panel
- ✅ Browse all upcoming events
- ✅ View event details with banner images
- ✅ Register/Unregister for events
- ✅ View personal registered events
- ✅ User profile management

### Security
- ✅ Role-based access control (Admin vs User routing)
- ✅ Row Level Security (RLS) on all database tables
- ✅ Authenticated storage uploads with RLS policies
- ✅ Secure session management via Supabase Auth SDK

---

## 5. Source Code Repository

| Field | Details |
|-------|---------|
| **Repository** | [https://github.com/Mahalakshmi77777/IT_CYBERNUARTS](https://github.com/Mahalakshmi77777/IT_CYBERNUARTS) |
| **Branch** | `main` |
| **Total Commits** | 6 |
| **Latest Commit** | `9e408ae` — fix: resolve UUID type mismatch for club_id + idempotent SQL schema |

### Commit History
```
9e408ae fix: resolve UUID type mismatch for club_id + idempotent SQL schema
bd8131c feat: Supabase migration + warm minimal redesign
e844986 chore: push requested UI updates and robust mock implementations
12ef96e Update app name to cyber nauts and implement hardcoded login profiles
e67fcf5 chore: Integrate Shorebird and update prototype configurations
0709700 Initial commit
```

---

## 6. Release Artifact

| Field | Details |
|-------|---------|
| **File** | `app-release.apk` |
| **Size** | 52.31 MiB (54.9 MB) |
| **SHA-256 Digest** | `33d90dc0c7b3ec2693fb3eaeeb5ee33086a3da9ac9...` |
| **Build Mode** | Release (optimized, tree-shaken) |
| **Min Android SDK** | 21 (Android 5.0 Lollipop) |

---

## 7. Proof of Deployment

### GitHub Release URL (Live & Publicly Accessible)
🔗 **[https://github.com/Mahalakshmi77777/IT_CYBERNUARTS/releases/tag/v1.0.0](https://github.com/Mahalakshmi77777/IT_CYBERNUARTS/releases/tag/v1.0.0)**

### Screenshots Required (Take from your device/browser):
1. **GitHub Release Page** — Open the URL above in a browser and screenshot it
2. **Supabase Dashboard** — Screenshot your project dashboard at [supabase.com/dashboard](https://supabase.com/dashboard)
3. **App Running on Device** — Screenshot the login screen, admin dashboard, and event creation flow

---

## 8. Installation Instructions

1. Download `app-release.apk` from the GitHub Releases link above
2. Transfer the APK to an Android device
3. On the device, go to **Settings → Security → Enable "Install from unknown sources"**
4. Open the APK file and tap **Install**
5. Launch the **IT CLUB** app

---

*This document serves as official proof of deployment for the IT CLUB mobile application.*
*Generated on: 14 April 2026*
