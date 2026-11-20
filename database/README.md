# LearnHire — Database Design 

## Tentang

Folder ini berisi rancangan database untuk platform **LearnHire** versi sederhana (Job Portal).

Database ini dirancang untuk **MariaDB 10.4.32 / MySQL 8.0+** dan dioptimalkan untuk dijalankan di **XAMPP**.

> **PENTING:** Database ini BELUM terhubung dengan frontend React.  
> Pada tahap ini, database hanya berupa rancangan/desain untuk keperluan presentasi.

> **Catatan Perubahan:** Versi ini merupakan penyederhanaan dari database TalentForge sebelumnya.  
> Fitur **kursus online** (`courses`, `course_categories`, `course_enrollments`) dan **lamaran kerja** (`job_applications`) telah **dihilangkan**.  
> Sebagai gantinya, ditambahkan tabel baru **`company_likes`** untuk fitur Like perusahaan.

---

## Struktur File

```text
database1/
├── schema.sql          ← SQL schema lengkap + seed data (MySQL / XAMPP)
├── erd/
│   ├── ERD.md          ← Dokumentasi ERD, kamus data & analisis normalisasi
│   └── erd.html        ← Visualisasi diagram interaktif Mermaid.js (buka di browser)
└── README.md           ← Petunjuk import & ringkasan arsitektur basis data
```

---

## Cara Import ke XAMPP

1. Buka **XAMPP Control Panel** dan start **Apache** serta **MySQL**
2. Buka **phpMyAdmin** di `http://localhost/phpmyadmin`
3. Klik tab **Import**
4. Pilih file `schema.sql`
5. Klik **Go/Eksekusi**

Atau melalui terminal MySQL:
```bash
mysql -u root -p < schema.sql
```

---

## Daftar Tabel (6 Tabel)

| No | Tabel | Deskripsi |
|:--|:------|:----------|
| 1 | `users` | Data pengguna (user biasa & admin). Kolom `cv_url` dihapus. |
| 2 | `companies` | Data perusahaan penyedia lowongan kerja |
| 3 | `job_categories` | Kategori industri/bidang pekerjaan |
| 4 | `jobs` | Data lowongan pekerjaan |
| 5 | `company_likes` | Like pengguna terhadap perusahaan (tabel baru) |
| 6 | `support_messages` | Pesan bantuan/support dari user ke admin |

---

## Tabel yang Dihilangkan dari Versi Sebelumnya

| Tabel Lama | Alasan Penghapusan |
|:-----------|:-------------------|
| `job_applications` | Fitur lamaran kerja dihilangkan |
| `course_categories` | Fitur kursus online dihilangkan |
| `courses` | Fitur kursus online dihilangkan |
| `course_enrollments` | Fitur kursus online dihilangkan |

---

## Relationship Antar Tabel

- `jobs.company_id` → `companies.id` (Many-to-One) — ON DELETE RESTRICT
- `jobs.category_id` → `job_categories.id` (Many-to-One) — ON DELETE SET NULL
- `company_likes.user_id` → `users.id` (Many-to-One) — ON DELETE CASCADE
- `company_likes.company_id` → `companies.id` (Many-to-One) — ON DELETE CASCADE
- `support_messages.user_id` → `users.id` (Many-to-One) — ON DELETE CASCADE

---

## Akun Demo (Seed Data)

| Peran | Email | Password |
|:------|:------|:---------|
| Admin | `admin@learnhire.com` | `admin123` |
| Admin | `admin2@learnhire.com` | `admin123` |
| User | `budi@example.com` | `user123` |
| User | `sari@example.com` | `user123` |
| User | `andi@example.com` | `user123` |
| User | `rina@example.com` | `user123` |
| User | `dimas@example.com` | `user123` |

---

## Data Seed Tersedia

| Tabel | Jumlah Data |
|:------|:------------|
| `users` | 7 akun (2 admin + 5 user) |
| `companies` | 6 perusahaan |
| `job
