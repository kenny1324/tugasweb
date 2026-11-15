-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 15 Nov 2026 pada 12.00
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

-- ============================================================================
--  DATABASE PENYEDERHANAAN LEARNHIRE  --  learnhire_db_final.sql
--  Website Informasi dan Pencarian Lowongan Pekerjaan Sederhana
--
--  Target Database  : MariaDB 10.4.32 / MySQL 8.0+
--  Target Tools     : phpMyAdmin 5.2.1 / Adminer / MySQL CLI
--  Storage Engine   : InnoDB
--  Default Charset  : utf8mb4
--  Default Collate  : utf8mb4_general_ci
--
--  !!! PERINGATAN / WARNING !!!
--  Skrip ini membangun ulang struktur database `learnhire_db` untuk kebutuhan
--  versi sederhana (Job Portal).
--  Bagian DROP TABLE di bawah akan MENGHAPUS tabel lama jika sudah ada
--  (termasuk tabel courses, course_categories, course_enrollments, job_applications)
--  sehingga SELURUH DATA LAMA PADA TABEL TERSEBUT AKAN HILANG dan digantikan
--  oleh data dummy pada skrip ini.
--  Database di luar `learnhire_db` TIDAK AKAN disentuh atau dihapus.
--
--  Daftar Tabel yang Dipertahankan & Disesuaikan:
--    1. users
--    2. companies
--    3. job_categories
--    4. jobs
--    5. support_messages
--
--  Daftar Tabel Baru:
--    6. company_likes
--
--  Daftar Tabel yang Dihilangkan (fitur kursus & lamaran kerja):
--    - courses
--    - course_categories
--    - course_enrollments
--    - job_applications
-- ============================================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- ----------------------------------------------------------------------------
-- 0. PEMBUATAN & PEMILIHAN DATABASE `learnhire_db`
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `learnhire_db`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `learnhire_db`;

-- ----------------------------------------------------------------------------
-- 1. PENGHAPUSAN TABEL LAMA (Child Tables Dihapus Terlebih Dahulu)
-- ----------------------------------------------------------------------------
-- Hapus tabel lama yang tidak digunakan lagi (fitur kursus & lamaran kerja)
DROP TABLE IF EXISTS `job_applications`;
DROP TABLE IF EXISTS `course_enrollments`;
DROP TABLE IF EXISTS `courses`;
DROP TABLE IF EXISTS `course_categories`;

-- Hapus tabel utama lama jika sudah ada (urutan dari child ke parent)
DROP TABLE IF EXISTS `company_likes`;
DROP TABLE IF EXISTS `support_messages`;
DROP TABLE IF EXISTS `jobs`;
DROP TABLE IF EXISTS `job_categories`;
DROP TABLE IF EXISTS `companies`;
DROP TABLE IF EXISTS `users`;

-- ----------------------------------------------------------------------------
-- 2. STRUKTUR TABEL (Parent Tables Dibuat Terlebih Dahulu)
-- ----------------------------------------------------------------------------

--
-- Struktur dari tabel `users`
-- Menyimpan akun pengguna (Admin & User).
-- Kolom cv_url dihapus karena user tidak lagi dapat melamar pekerjaan.
--
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `avatar` varchar(255) DEFAULT 'default-avatar.png',
  `bio` text DEFAULT NULL,
  `skills` text DEFAULT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Struktur dari tabel `companies`
-- Menyimpan profil dan informasi perusahaan yang dikelola oleh Admin.
--
CREATE TABLE `companies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `logo` varchar(255) DEFAULT 'default-company.png',
  `description` text DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_companies_name` (`name`),
  KEY `idx_companies_industry` (`industry`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Struktur dari tabel `job_categories`
-- Menyimpan kategori industri/bidang pekerjaan.
--
CREATE TABLE `job_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `icon` varchar(50) DEFAULT 'fa-briefcase',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_job_categories_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Struktur dari tabel `jobs`
-- Menyimpan lowongan pekerjaan.
-- Relasi:
--   - company_id  -> companies(id)      [ON DELETE RESTRICT, ON UPDATE CASCADE]
--     Mencegah perusahaan dihapus jika masih memiliki lowongan pekerjaan aktif.
--   - category_id -> job_categories(id) [ON DELETE SET NULL, ON UPDATE CASCADE]
--     Jika kategori dihapus, lowongan tetap tersimpan (kategori menjadi NULL).
--
CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `title` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `requirements` text DEFAULT NULL,
  `salary_min` decimal(15,2) DEFAULT NULL,
  `salary_max` decimal(15,2) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `type` enum('Full-time','Part-time','Contract','Internship') NOT NULL DEFAULT 'Full-time',
  `status` enum('active','closed') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_jobs_company_id` (`company_id`),
  KEY `idx_jobs_category_id` (`category_id`),
  KEY `idx_jobs_status` (`status`),
  KEY `idx_jobs_type` (`type`),
  KEY `idx_jobs_location` (`location`),
  KEY `idx_jobs_title` (`title`),
  CONSTRAINT `fk_jobs_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_jobs_category` FOREIGN KEY (`category_id`) REFERENCES `job_categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Struktur dari tabel `company_likes`
-- Tabel BARU untuk menyimpan Like pengguna terhadap perusahaan yang diminati.
-- Relasi:
--   - user_id    -> users(id)     [ON DELETE CASCADE, ON UPDATE CASCADE]
--   - company_id -> companies(id) [ON DELETE CASCADE, ON UPDATE CASCADE]
-- Ketentuan:
--   - Kombinasi user_id dan company_id bersifat UNIQUE (1 user hanya boleh 1 Like per perusahaan).
--   - Unlike dilakukan dengan DELETE baris pada tabel ini.
--   - Total Like dihitung dinamis dengan COUNT(*).
--
CREATE TABLE `company_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_company_likes_user_company` (`user_id`,`company_id`),
  KEY `idx_company_likes_company_id` (`company_id`),
  CONSTRAINT `fk_company_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_company_likes_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Struktur dari tabel `support_messages`
-- Menyimpan pesan bantuan dan pertanyaan dari user ke admin.
--
CREATE TABLE `support_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `subject` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `reply` text DEFAULT NULL,
  `status` enum('open','in_progress','resolved') NOT NULL DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_support_messages_user_id` (`user_id`),
  KEY `idx_support_messages_status` (`status`),
  CONSTRAINT `fk_support_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------------------------------------------------------
-- 3. DATA DUMMY (Parent Tables Diisi Terlebih Dahulu)
-- ----------------------------------------------------------------------------

--
-- Dumping data untuk tabel `users`
-- Akun Admin: id 1 (admin@learnhire.com), id 2 (admin2@learnhire.com)
-- Akun User : id 3-7 (budi, sari, andi, rina, dimas)
-- Password hash asli dipertahankan tanpa perubahan.
--
INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `address`, `avatar`, `bio`, `skills`, `role`, `created_at`, `updated_at`) VALUES
(1, 'Admin LearnHire', 'admin@learnhire.com', '$2a$10$rAjnZphfXuqsSt8dEgrXWuNx/W0eLGc1rbplrdG8OxDJcEbF4Excm', '081200000001', NULL, 'default-avatar.png', 'Administrator utama sistem LearnHire.', NULL, 'admin', '2026-10-07 12:47:11', '2026-10-07 12:47:11'),
(2, 'Admin Dua', 'admin2@learnhire.com', '$2a$10$rAjnZphfXuqsSt8dEgrXWuNx/W0eLGc1rbplrdG8OxDJcEbF4Excm', '081200000002', NULL, 'default-avatar.png', 'Administrator pendukung operasional LearnHire.', NULL, 'admin', '2026-10-07 12:47:11', '2026-10-07 12:47:11'),
(3, 'Budi Santoso', 'budi@example.com', '$2a$10$5NKumLFknEcQSc5Etn0NeelrGs4YeffC9x91rUpRbqytploUekSv.', '081234567890', 'Jl. Dipatiukur No. 12, Bandung', 'default-avatar.png', 'Fresh graduate Teknik Informatika yang tertarik pada pengembangan web modern.', 'HTML, CSS, JavaScript, React, Git', 'user', '2026-10-07 12:47:11', '2026-10-07 12:47:11'),
(4, 'Sari Dewi', 'sari@example.com', '$2a$10$5NKumLFknEcQSc5Etn0NeelrGs4YeffC9x91rUpRbqytploUekSv.', '081234567891', 'Jl. Kemang Raya No. 8, Jakarta Selatan', 'default-avatar.png', 'Lulusan Statistika yang berfokus pada analisis data dan business intelligence.', 'SQL, Python, Pandas, Excel, Tableau', 'user', '2026-10-07 12:47:11', '2026-10-07 12:47:11'),
(5, 'Andi Pratama', 'andi@example.com', '$2a$10$5NKumLFknEcQSc5Etn0NeelrGs4YeffC9x91rUpRbqytploUekSv.', '081234567892', 'Jl. Darmo Permai III No. 5, Surabaya', 'default-avatar.png', 'Desainer produk digital dengan fokus pada pengalaman pengguna (UX) yang intuitif.', 'Figma, Adobe Illustrator, Prototyping, User Research', 'user', '2026-10-07 12:47:11', '2026-10-07 12:47:11'),
(6, 'Rina Wati', 'rina@example.com', '$2a$10$5NKumLFknEcQSc5Etn0NeelrGs4YeffC9x91rUpRbqytploUekSv.', '081234567893', 'Jl. Malioboro No. 21, Yogyakarta', 'default-avatar.png', 'Spesialis komunikasi dan pemasaran digital dengan pengalaman kampanye media sosial.', 'Copywriting, SEO, Social Media, Canva', 'user', '2026-10-07 12:47:11', '2026-10-07 12:47:11'),
(7, 'Dimas Putra', 'dimas@example.com', '$2a$10$5NKumLFknEcQSc5Etn0NeelrGs4YeffC9x91rUpRbqytploUekSv.', '081234567894', 'Jl. Pemuda No. 30, Semarang', 'default-avatar.png', 'Backend developer dengan minat mendalam pada arsitektur microservices dan API performa tinggi.', 'Node.js, Express, MySQL, Docker', 'user', '2026-10-07 12:47:11', '2026-10-07 12:47:11');

--
-- Dumping data untuk tabel `job_categories`
-- Kategori pekerjaan sesuai database asli
--
INSERT INTO `job_categories` (`id`, `name`, `icon`, `created_at`) VALUES
(1, 'Technology', 'fa-briefcase', '2026-10-07 12:47:12'),
(2, 'Design', 'fa-briefcase', '2026-10-07 12:47:12'),
(3, 'Marketing', 'fa-briefcase', '2026-10-07 12:47:12'),
(4, 'Finance', 'fa-briefcase', '2026-10-07 12:47:12'),
(5, 'Engineering', 'fa-briefcase', '2026-10-07 12:47:12'),
(6, 'Data Science', 'fa-briefcase', '2026-10-07 12:47:12');

--
-- Dumping data untuk tabel `companies`
-- Data perusahaan mitra sesuai database asli dengan deskripsi dan tautan lengkap
--
INSERT INTO `companies` (`id`, `name`, `logo`, `description`, `location`, `website`, `industry`, `created_at`) VALUES
(1, 'Tokopedia', 'default-company.png', 'Tokopedia adalah salah satu perusahaan teknologi dan marketplace e-commerce terdepan di Indonesia yang menghubungkan jutaan penjual dan pembeli.', 'Jakarta', 'https://www.tokopedia.com', 'Technology', '2026-10-07 12:47:12'),
(2, 'Gojek', 'default-company.png', 'Gojek adalah platform on-demand terkemuka di Asia Tenggara yang menyediakan berbagai layanan mulai dari transportasi, pesan-antar makanan, hingga pembayaran digital.', 'Jakarta', 'https://www.gojek.com', 'Technology', '2026-10-07 12:47:12'),
(3, 'Traveloka', 'default-company.png', 'Traveloka adalah platform perjalanan dan gaya hidup terkemuka di Asia Tenggara yang menyediakan akses untuk memesan berbagai kebutuhan perjalanan.', 'Jakarta', 'https://www.traveloka.com', 'Technology', '2026-10-07 12:47:12'),
(4, 'Shopee', 'default-company.png', 'Shopee adalah platform e-commerce terkemuka di Asia Tenggara dan Taiwan yang menawarkan pengalaman berbelanja online mudah, aman, dan cepat.', 'Jakarta', 'https://shopee.co.id', 'E-commerce', '2026-10-07 12:47:12'),
(5, 'Bukalapak', 'default-company.png', 'Bukalapak adalah perusahaan teknologi all-commerce Indonesia yang memberdayakan UMKM melalui solusi retail online dan offline.', 'Jakarta', 'https://www.bukalapak.com', 'E-commerce', '2026-10-07 12:47:12'),
(6, 'Telkom Indonesia', 'default-company.png', 'PT Telkom Indonesia adalah badan usaha milik negara yang bergerak di bidang jasa layanan teknologi informasi dan komunikasi terintegrasi.', 'Bandung', 'https://www.telkom.co.id', 'Telecommunications', '2026-10-07 12:47:12');

--
-- Dumping data untuk tabel `jobs`
-- 24 data lowongan (4 lowongan per perusahaan) dengan deskripsi dan persyaratan realistis
--
INSERT INTO `jobs` (`id`, `company_id`, `category_id`, `title`, `description`, `requirements`, `salary_min`, `salary_max`, `location`, `type`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Frontend Developer', 'Bergabung dengan tim engineering web untuk membangun antarmuka pengguna yang cepat, responsif, dan mudah diakses oleh jutaan pengguna.', '- Minimal S1 Ilmu Komputer, Teknik Informatika, atau bidang terkait\n- Pengalaman minimal 2 tahun dalam pengembangan frontend web\n- Menguasai HTML5, CSS3, JavaScript modern (ES6+)\n- Terbiasa menggunakan React.js dan Git version control\n- Memahami responsive web design dan web performance', 10000000.00, 15000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(2, 2, 6, 'Data Analyst', 'Menganalisis data operasional dan perilaku pengguna untuk menghasilkan actionable insights bagi tim produk dan bisnis.', '- Minimal S1 Statistika, Matematika, Ilmu Komputer, atau bidang terkait\n- Pengalaman minimal 1 tahun sebagai data analyst\n- Mahir menulis query SQL tingkat lanjut\n- Pengalaman dengan tools visualisasi (Tableau, Metabase, atau Looker Studio)\n- Kemampuan problem solving dan komunikasi yang baik', 8000000.00, 12000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(3, 3, 2, 'UI/UX Designer', 'Merancang alur pengguna dan antarmuka aplikasi pemesanan tiket dan hotel yang nyaman dan estetik bagi pengguna mobile dan web.', '- Minimal S1 Desain Komunikasi Visual, Sistem Informasi, atau bidang terkait\n- Portofolio desain UI/UX yang kuat (web & mobile)\n- Mahir menggunakan Figma dan tools prototyping interaktif\n- Memahami metodologi user research dan usability testing\n- Mampu berkolaborasi erat dengan Product Manager dan Developer', 9000000.00, 14000000.00, 'Bali', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(4, 4, 3, 'Marketing Specialist', 'Merencanakan dan mengeksekusi kampanye pemasaran digital, promosi musiman, serta pengelolaan media sosial secara kreatif.', '- Minimal D3/S1 Pemasaran, Komunikasi, atau bidang terkait\n- Pengalaman minimal 1 tahun di bidang digital marketing\n- Menguasai copywriting media sosial dan dasar-dasar analitik kampanye\n- Bersedia bekerja part-time dengan komitmen minimal 20 jam per minggu\n- Memiliki inisiatif tinggi dan kreatif', 5000000.00, 8000000.00, 'Jakarta', 'Part-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(5, 5, 1, 'Backend Engineer', 'Merancang dan memelihara backend service, database, dan RESTful API performa tinggi untuk mendukung ekosistem e-commerce.', '- Minimal S1 Teknik Informatika atau pengalaman relevan\n- Pengalaman minimal 3 tahun dengan Node.js (Express / NestJS)\n- Menguasai perancangan database relasional (MySQL / PostgreSQL)\n- Memahami arsitektur caching (Redis) dan message broker\n- Disiplin dalam pengujian kode (unit test) dan code review', 12000000.00, 18000000.00, 'Bandung', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(6, 6, 5, 'Network Engineer', 'Mengoperasikan, memonitor, dan menyelesaikan gangguan pada infrastruktur jaringan backbone dan data center nasional.', '- Minimal D3/S1 Teknik Elektro, Telekomunikasi, atau Teknik Komputer\n- Pengalaman minimal 2 tahun dalam konfigurasi router/switch (Cisco, Juniper)\n- Menguasai protokol TCP/IP, OSPF, BGP, dan VLAN\n- Memiliki sertifikasi CCNA/CCNP menjadi nilai tambah\n- Bersedia bekerja dalam sistem shift', 7000000.00, 10000000.00, 'Jakarta', 'Contract', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(7, 1, 4, 'Finance Manager', 'Memimpin perencanaan keuangan perusahaan, audit laporan keuangan, dan memastikan kepatuhan pajak serta regulasi perbankan.', '- S1/S2 Akuntansi atau Manajemen Keuangan (memiliki sertifikasi CA/CPA nilai plus)\n- Pengalaman minimal 5 tahun di bidang keuangan perusahaan\n- Menguasai laporan keuangan, budgeting, dan perpajakan Indonesia\n- Terbiasa menggunakan sistem ERP dan Excel tingkat lanjut\n- Memiliki jiwa kepemimpinan yang matang', 15000000.00, 25000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(8, 2, 1, 'Mobile Developer', 'Mengembangkan fitur baru pada aplikasi mobile Android dan iOS menggunakan cross-platform framework.', '- Minimal S1 Teknik Informatika atau pengalaman setara\n- Menguasai Flutter (Dart) atau React Native\n- Pengalaman merilis dan memelihara aplikasi di Google Play Store / App Store\n- Memahami integrasi RESTful API dan state management\n- Terbiasa bekerja secara remote dengan komunikasi asinkron', 10000000.00, 16000000.00, 'Remote', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(9, 3, 3, 'SEO Specialist', 'Meningkatkan visibilitas organik halaman pencarian travel melalui optimasi teknikal SEO, konten artikel, dan backlink.', '- Minimal S1 Pemasaran, Komunikasi, atau bidang terkait\n- Pengalaman minimal 2 tahun di bidang Search Engine Optimization (SEO)\n- Menguasai Google Search Console, Google Analytics, Ahrefs, SEMrush\n- Memahami on-page SEO, technical SEO, dan arsitektur website\n- Mampu menganalisis tren kata kunci', 6000000.00, 9000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(10, 4, 6, 'Data Scientist', 'Membangun algoritma machine learning untuk rekomendasi produk personal, estimasi harga dinamis, dan deteksi kecurangan.', '- S1/S2 Ilmu Komputer, Matematika, Statistika, atau bidang sains data\n- Pengalaman minimal 3 tahun mengimplementasikan model machine learning\n- Mahir Python, scikit-learn, TensorFlow/PyTorch, dan SQL\n- Berpengalaman mengintegrasikan model ke lingkungan produksi\n- Bersedia ditempatkan di kantor regional Singapore', 20000000.00, 30000000.00, 'Singapore', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(11, 5, 1, 'DevOps Engineer', 'Mengelola pipeline CI/CD, cluster server cloud, otomasi deployment, dan sistem monitoring kestabilan aplikasi secara remote.', '- Minimal S1 Ilmu Komputer atau pengalaman relevan\n- Pengalaman minimal 3 tahun dengan Docker, Kubernetes, dan cloud provider (AWS/GCP)\n- Menguasai tools CI/CD (GitHub Actions, GitLab CI, Jenkins)\n- Memahami Infrastructure as Code (Terraform/Ansible)\n- Terbiasa memantau metrik server dengan Prometheus & Grafana', 15000000.00, 22000000.00, 'Remote', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(12, 6, 1, 'System Administrator', 'Memelihara ketersediaan sistem operasi server internal, manajemen akses user, backup data rutin, dan patch keamanan.', '- Minimal D3/S1 Teknologi Informasi atau bidang terkait\n- Pengalaman minimal 2 tahun dalam administrasi server Linux dan Windows Server\n- Memahami virtualisasi (VMware, Proxmox, KVM)\n- Terbiasa melakukan scripting bash/PowerShell untuk otomatisasi\n- Sertifikasi RHCSA menjadi nilai tambah', 8000000.00, 12000000.00, 'Bandung', 'Full-time', 'active', '2026-10-07 12:47:12', '2026-10-07 12:47:12'),
(13, 1, 3, 'Digital Marketing Intern', 'Membantu tim pemasaran dalam riset tren pasar, pengelolaan konten media sosial, dan penyusunan laporan bulanan kampanye.', '- Mahasiswa aktif semester akhir atau fresh graduate jurusan Komunikasi/Pemasaran\n- Bersedia magang penuh waktu (full-time) selama 3-6 bulan\n- Aktif di media sosial dan memiliki kemampuan dasar desain (Canva)\n- Mampu menulis copywriting yang menarik dalam Bahasa Indonesia & Inggris\n- Memiliki motivasi belajar yang tinggi', 3000000.00, 4000000.00, 'Jakarta', 'Internship', 'active', '2026-10-20 09:15:00', '2026-10-20 09:15:00'),
(14, 1, 1, 'QA Engineer', 'Menjalankan pengujian manual dan otomasi pada fitur web checkout untuk menjamin pengalaman berbelanja bebas dari bug kritis.', '- Minimal S1 Teknologi Informasi atau bidang terkait\n- Pengalaman minimal 2 tahun dalam pengujian perangkat lunak (QA)\n- Pengalaman API testing menggunakan Postman\n- Terbiasa menggunakan tools otomasi (Selenium, Cypress, atau Playwright)\n- Memahami proses Agile/Scrum dan tools pelaporan Jira', 8000000.00, 12000000.00, 'Jakarta', 'Contract', 'closed', '2026-10-12 10:30:00', '2026-11-05 14:00:00'),
(15, 2, 2, 'Product Designer', 'Menerjemahkan kebutuhan bisnis dan riset pengguna ke dalam desain antarmuka aplikasi super-app yang intuitif dan mudah dipahami.', '- Minimal S1 Desain, Human-Computer Interaction, atau bidang terkait\n- Pengalaman minimal 3 tahun dalam mendesain aplikasi mobile berskala besar\n- Kemampuan komunikasi visual, wireframing, dan visual polish yang sangat baik\n- Portofolio studi kasus yang menunjukkan proses dari problem hingga solution\n- Menguasai design system dan komponen Figma', 9000000.00, 14000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-15 11:00:00', '2026-10-15 11:00:00'),
(16, 2, 6, 'Data Science Intern', 'Membantu proses eksplorasi data, pembersihan dataset (data cleaning), dan eksperimen model regresi untuk layanan pesan antar.', '- Mahasiswa aktif semester 6 ke atas atau fresh graduate bidang Sains Data/Statistika/Informatika\n- Memahami dasar pemrograman Python (Pandas, NumPy, Matplotlib)\n- Memahami konsep dasar pemodelan statistika dan machine learning\n- Memiliki keingintahuan intelektual dan antusiasme belajar tinggi\n- Durasi magang minimal 4 bulan', 3000000.00, 4500000.00, 'Jakarta', 'Internship', 'active', '2026-10-25 08:45:00', '2026-10-25 08:45:00'),
(17, 3, 1, 'Backend Developer', 'Membangun API mikroservis untuk reservasi penerbangan internasional dengan jaminan response time di bawah 100 milidetik.', '- Minimal S1 Ilmu Komputer atau pengalaman kerja sebanding\n- Pengalaman minimal 3 tahun di backend development (Java, Kotlin, atau Go)\n- Menguasai perancangan sistem RESTful API dan gRPC\n- Memahami database concurrency dan transaksi ACID\n- Pengalaman menggunakan Git dan container Docker', 12000000.00, 18000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-18 13:20:00', '2026-10-18 13:20:00'),
(18, 3, 3, 'Content Writer', 'Menulis artikel panduan wisata domestik, ulasan destinasi terpopuler, dan tips perjalanan hemat untuk blog resmi perusahaan.', '- Minimal S1 Komunikasi, Sastra, Jurnalistik, atau bidang terkait\n- Pengalaman minimal 1 tahun sebagai penulis artikel web\n- Kemampuan riset mandiri dan menulis konten orisinal yang menarik\n- Memahami dasar-dasar penulisan SEO-friendly\n- Komitmen kerja paruh waktu minimal 20 jam per minggu', 4000000.00, 6000000.00, 'Jakarta', 'Part-time', 'closed', '2026-10-10 09:00:00', '2026-11-02 16:30:00'),
(19, 4, 4, 'Financial Analyst', 'Menyusun model proyeksi pendapatan, analisis biaya operasional logistik, dan laporan keuangan komparatif bulanan.', '- Minimal S1 Keuangan, Akuntansi, Ekonomi, atau bidang terkait\n- Pengalaman minimal 2 tahun dalam analisis finansial atau audit\n- Keterampilan financial modelling tingkat lanjut dengan Microsoft Excel\n- Memiliki ketelitian tinggi dan kemampuan interpretasi rasio keuangan\n- Terbiasa menyajikan data kepada tim manajemen senior', 9000000.00, 14000000.00, 'Jakarta', 'Full-time', 'active', '2026-10-22 10:10:00', '2026-10-22 10:10:00'),
(20, 4, 1, 'Frontend Engineer Intern', 'Membantu mengembangkan komponen UI web seller dashboard dengan bimbingan langsung dari senior frontend engineer.', '- Mahasiswa/i aktif atau fresh graduate jurusan Teknik Informatika / Sistem Informasi\n- Memahami konsep dasar HTML, CSS, dan JavaScript\n- Memiliki ketertarikan mendalam mempelajari React.js\n- Memiliki portofolio proyek kuliah atau proyek mandiri di GitHub\n- Durasi magang minimal 4 bulan di kantor Jakarta', 3000000.00, 4500000.00, 'Jakarta', 'Internship', 'active', '2026-11-01 08:30:00', '2026-11-01 08:30:00'),
(21, 5, 2, 'UI Designer', 'Membuat aset visual, ikonografi, dan rancangan tampilan banner promosi aplikasi mobile untuk merchant UMKM.', '- Minimal D3/S1 Desain Komunikasi Visual atau bidang terkait\n- Pengalaman minimal 2 tahun di bidang visual/UI design\n- Menguasai Figma, Adobe Photoshop, dan Illustrator\n- Memahami prinsip dasar tipografi, komposisi warna, dan branding\n- Kontrak kerja 6 bulan dengan opsi perpanjangan', 7000000.00, 11000000.00, 'Jakarta', 'Contract', 'active', '2026-10-28 14:40:00', '2026-10-28 14:40:00'),
(22, 5, 6, 'Data Analyst', 'Menganalisis performa transaksi toko mitra e-commerce dan menyusun visualisasi metrik pertumbuhan transaksi mingguan.', '- Minimal S1 Statistika, Matematika, atau Sistem Informasi\n- Pengalaman minimal 1 tahun di analisis data retail atau marketplace\n- Mahir SQL dan pengolahan data spreadsheet besar\n- Mampu menyusun dashboard interaktif di Looker Studio / Tableau\n- Kemampuan analisis logis dan komunikasi yang jelas', 8000000.00, 12000000.00, 'Jakarta', 'Full-time', 'closed', '2026-10-09 09:30:00', '2026-11-08 11:15:00'),
(23, 6, 5, 'Telecommunication Field Engineer', 'Melakukan instalasi perangkat transmisi serat optik (fiber optic), pengukuran redaman kabel, dan maintenance tower telekomunikasi.', '- Minimal D3/S1 Teknik Telekomunikasi atau Teknik Elektro\n- Pengalaman minimal 1 tahun dalam pemeliharaan jaringan transmisi/fiber optic\n- Mampu menggunakan alat ukur OTDR dan optical power meter\n- Memiliki SIM C dan bersedia ditugaskan di lapangan\n- Memiliki pemahaman standar keselamatan kerja (K3)', 7000000.00, 11000000.00, 'Bandung', 'Full-time', 'active', '2026-10-30 08:00:00', '2026-10-30 08:00:00'),
(24, 6, 5, 'Engineering Intern', 'Mengikuti program pelatihan teknis lapangan mengenai pemeliharaan jaringan telekomunikasi dan pengarsipan topologi kabel.', '- Mahasiswa aktif semester 6 ke atas jurusan Teknik Elektro/Telekomunikasi\n- Memahami konsep dasar jaringan komputer dan transmisi gelombang\n- Bersedia mengikuti program magang selama 3-6 bulan di Bandung\n- Memiliki motivasi kerja lapangan dan disiplin tinggi\n- Mampu bekerja sama dalam tim teknik', 2500000.00, 3500000.00, 'Bandung', 'Internship', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

--
-- Dumping data untuk tabel `company_likes`
-- 15 data Like awal dari akun user (id 3 - 7) untuk menguji popularitas perusahaan.
-- Tidak ada duplikasi kombinasi (user_id, company_id).
-- Tidak ada Like dari akun admin.
--
INSERT INTO `company_likes` (`id`, `user_id`, `company_id`, `created_at`) VALUES
(1, 3, 1, '2026-10-08 09:10:00'),
(2, 3, 2, '2026-10-08 09:12:00'),
(3, 3, 4, '2026-10-09 14:30:00'),
(4, 4, 2, '2026-10-09 10:05:00'),
(5, 4, 3, '2026-10-10 11:20:00'),
(6, 4, 6, '2026-10-12 16:45:00'),
(7, 5, 1, '2026-10-11 08:50:00'),
(8, 5, 2, '2026-10-11 08:55:00'),
(9, 5, 4, '2026-10-13 19:00:00'),
(10, 6, 3, '2026-10-14 13:15:00'),
(11, 6, 4, '2026-10-14 13:18:00'),
(12, 6, 6, '2026-10-15 09:40:00'),
(13, 7, 1, '2026-10-16 20:10:00'),
(14, 7, 2, '2026-10-16 20:12:00'),
(15, 7, 5, '2026-10-17 07:55:00');

--
-- Dumping data untuk tabel `support_messages`
-- Pesan bantuan yang relevan dengan website LearnHire baru
-- (tidak ada lagi pesan terkait pengembalian dana kursus atau status lamaran pekerjaan).
--
INSERT INTO `support_messages` (`id`, `user_id`, `subject`, `message`, `reply`, `status`, `created_at`, `updated_at`) VALUES
(1, 3, 'Kendala Login Akun', 'Halo admin, saya sempat lupa password akun saya dan tidak bisa masuk. Bagaimana cara pemulihannya?', 'Halo Budi, terima kasih telah menghubungi kami. Tim admin telah mengirimkan tautan reset kata sandi ke email Anda. Silakan ikuti instruksi pada email tersebut.', 'resolved', '2026-10-07 12:47:12', '2026-10-08 10:00:00'),
(2, 4, 'Persyaratan Lowongan Data Analyst', 'Halo admin, pada lowongan Data Analyst di Gojek, apakah sertifikasi Tableau menjadi syarat wajib atau nilai plus?', 'Halo Sari, sertifikasi Tableau bersifat nilai tambah (nilai plus). Yang paling diutamakan adalah pemahaman logika SQL dan visualisasi data dasar.', 'resolved', '2026-10-18 15:20:00', '2026-10-19 09:30:00'),
(3, 5, 'Cara Membatalkan Like Perusahaan', 'Saya tidak sengaja menekan tombol Like pada salah satu perusahaan, bagaimana cara membatalkannya?', 'Halo Andi, Anda cukup menekan kembali tombol Like pada halaman profil perusahaan tersebut untuk melakukan Unlike (batal menyukai).', 'in_progress', '2026-11-10 18:05:00', '2026-11-11 08:15:00'),
(4, 6, 'Perubahan Nomor Telepon Profil', 'Apakah nomor kontak di profil saya bisa diperbarui tanpa perlu verifikasi ulang melalui email?', NULL, 'open', '2026-11-12 14:20:00', '2026-11-12 14:20:00');

COMMIT;

-- ----------------------------------------------------------------------------
-- 4. CONTOH QUERY REFERENSI UNTUK WEBSITE
-- ----------------------------------------------------------------------------

-- A. Menghitung Jumlah Like per Perusahaan (Popularitas Perusahaan):
--    SELECT c.id, c.name, c.industry, c.location, COUNT(cl.id) AS total_likes
--    FROM companies c
--    LEFT JOIN company_likes cl ON cl.company_id = c.id
--    GROUP BY c.id, c.name, c.industry, c.location
--    ORDER BY total_likes DESC, c.name ASC;

-- B. Menambahkan Like (User Memberikan Like):
--    INSERT INTO company_likes (user_id, company_id) VALUES (3, 5);

-- C. Membatalkan Like (User Melakukan Unlike):
--    DELETE FROM company_likes WHERE user_id = 3 AND company_id = 5;

-- D. Memeriksa Apakah User yang Sedang Login Sudah Me-Like Suatu Perusahaan:
--    SELECT EXISTS(
--      SELECT 1 FROM company_likes WHERE user_id = 3 AND company_id = 1
--    ) AS is_liked;

-- E. Menampilkan Daftar Lowongan Aktif Beserta Nama Perusahaan dan Kategorinya:
--    SELECT j.id, j.title, j.type, j.location, j.salary_min, j.salary_max,
--           c.name AS company_name, c.logo AS company_logo,
--           k.name AS category_name
--    FROM jobs j
--    JOIN companies c ON c.id = j.company_id
--    LEFT JOIN job_categories k ON k.id = j.category_id
--    WHERE j.status = 'active'
--    ORDER BY j.created_at DESC;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
