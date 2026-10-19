# Ukuran Figma: status konfirmasi

Semua font memakai Fira Sans (Open Sans menunggu revamp). Nilai dengan status
**Usulan** dipakai sementara dan perlu dicek di Figma Dev Mode; ubah satu baris di file
token yang disebut. Spacing 4/8/16/32 memakai `FigmaSize.spacingSmall/Medium/Large/ExtraLarge`,
ikon 24/36 `FigmaSize.weightIconSmall/Medium`, outline 1 `FigmaSize.weightOutline`.

## Welcome

| Elemen | Nilai | Token | Status |
| --- | --- | --- | --- |
| Back, more | 24 | `FigmaSize.weightIconSmall` | Dikonfirmasi |
| Logo | 60×60 | `CustomSizes.Welcome.emblem` | Dikonfirmasi |
| "Hi, Lara Croft!" | SemiBold 20 | `typographySizeHeadingSmall20` | Dikonfirmasi |
| Deskripsi | Regular 14 | `typographySizeDisplaySmall14` | Dikonfirmasi |
| "Mulai dari sini" + ikon | SemiBold 14, ikon 24 | `typographySizeDisplaySmall14`, `weightIconSmall` | Dikonfirmasi |
| Kartu: judul / subjudul | SemiBold 14 / Regular 12 | `DisplaySmall14` / `DisplayTiny12` | Dikonfirmasi |
| Kartu: ikon kiri / chevron | 36 / 20 | `weightIconMedium` / `CustomSizes.QuickAction.chevron` | Dikonfirmasi |
| Kartu: padding / radius / shadow | 16 / 8 / 0,2 blur 10 #BEC3D0 40% | `spacingLarge` / `QuickAction.cornerRadius` / `CustomSizes.Shadow` | Dikonfirmasi |
| Header → logo | 32 | `spacingExtraLarge` | Usulan |
| Logo → sapaan → deskripsi | 16 → 4 | `spacingLarge` → `spacingSmall` | Usulan |
| Deskripsi → "Mulai dari sini" → kartu | 32 → 8 | `spacingExtraLarge` → `spacingMedium` | Usulan |
| Jarak antarkartu | 8 | `spacingMedium` | Usulan |
| Ikon → teks, judul → subjudul | 12, 2 | `QuickAction.iconTextGap`, `QuickAction.titleGap` | Usulan |
| Tile ikon: ikon di dalam | 24 dalam 36, latar `colorsSurfaceWarning` | `weightIconSmall` | Usulan |

## Pesan dan jawaban

| Elemen | Nilai | Token | Status |
| --- | --- | --- | --- |
| Bubble user | padding 12/8, radius 12, maks 310, Regular 14 putih | `CustomSizes.Bubble` | Usulan |
| Jawaban | Regular 14/21, jarak antarblok 16 | `DisplaySmall14`, `spacingLarge` | Usulan |
| Tanggal | Regular 12 secondary, `d MMM yyyy`, jarak 16 | `DisplayTiny12` | Usulan |
| Loading | ikon 16 berdenyut 0,8 s, Regular 12 secondary | `CustomSizes.Status.icon`, `CustomMotion.StatusPulse` | Usulan |
| Opsi | padding 16, radius 8, stroke 1, radio 24, jarak 8, indikator → teks 12 | `CustomSizes.Option` | Usulan |
| Media | lebar 240, gambar 137, radius 8, padding caption 12, SemiBold 14 | `CustomSizes.Media` | Usulan |
| Tabel | header SemiBold 14, isi Regular 14, padding baris 8, divider 1 | `spacingMedium`, `weightOutline` | Usulan |

Divider 0,5 pada usulan awal menjadi 1 karena `.scaledToArtwork` membulatkan ke point utuh.

## Action dan lainnya

| Elemen | Nilai | Token | Status |
| --- | --- | --- | --- |
| Chip / link / suggestion | tinggi 40, padding 16, pill, ikon 16, SemiBold 14 (suggestion Regular 14) | `CustomSizes.Action` | Usulan |
| Tombol penuh | tinggi 48, radius 8, #37474F, SemiBold 14 putih bergaris bawah | `CustomSizes.Action`, `CustomColors.FilledAction` | Usulan (warna) |
| Scroll ke terbaru | 40 putih + shadow, 8 di atas divider | `CustomSizes.ScrollToLatest` | Usulan |
| Preview jawaban sebelumnya | 48 | `CustomSizes.MessageList.previousAnswerPreview` | Usulan |
| Divider atas composer | 1, `colorsOutlineNetral` | `weightOutline` | Usulan |
| Tombol stop | 24, kotak 8 radius 2 | `CustomSizes.Composer.stopMark*` | Usulan |

Belum dibuat karena belum ada pemakainya: CTA gradient "Optimize now", varian gelap
(Premier/Private), small icon, `icon-thumbnail`.
