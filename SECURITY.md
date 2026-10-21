# Batas keamanan

TanyaAI tidak membuka jaringan sendiri: SSE dan inquiry BE dijalankan host lewat
`TanyaAIService`, termasuk token dan header. Tidak ada penyimpanan pesan permanen.
Jangan log draft atau isi pesan. Font dibundel bersama lisensinya di DesignKit.

Link dari jawaban hanya diteruskan ke host (`.web`, `.deeplink`, `.phone`); scheme
`javascript:`, `file:`, `data:`, dan `about:` tidak pernah bisa diketuk, dan target link
yang masih streaming tidak aktif sebelum tag ditutup. Host tetap memvalidasi domain,
deeplink, dan routing. Transaksi, dokumen, dan PIN memerlukan validasi tersendiri.
