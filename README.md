# Deteksi Gelombang PQRST EKG dengan DWT Manual 
## Deskripsi Proyek

Proyek ini merupakan aplikasi berbasis *Graphical User Interface* (GUI) menggunakan MATLAB untuk memproses sinyal elektrokardiogram (EKG/ECG) dan memvisualisasikan wilayah gelombang P, kompleks QRS, dan gelombang T.

Implementasi difokuskan pada penerapan konsep *Discrete Wavelet Transform* (DWT), konstruksi filter digital, konvolusi manual, serta deteksi kandidat puncak R menggunakan algoritma berbasis ambang amplitudo.

---

## Tujuan

- Memahami prinsip dasar pemrosesan sinyal EKG secara digital.
- Mengimplementasikan koefisien filter wavelet Daubechies secara manual.
- Memahami proses konvolusi dan *downsampling* dalam dekomposisi sinyal.
- Mengidentifikasi kandidat puncak R berdasarkan karakteristik amplitudo sinyal.
- Memvisualisasikan wilayah P, QRS, dan T melalui antarmuka GUI MATLAB.

---

## Lingkungan Pemrograman

| Komponen           | Keterangan                                                           |
| ------------------ | -------------------------------------------------------------------- |
| Bahasa pemrograman | MATLAB                                                               |
| Format program     | `.mlx`                                                                 |
| Antarmuka          | MATLAB UI components (`uifigure`, `uipanel`, `uitabgroup`, `uiaxes`) |
| Metode pemrosesan  | Filter wavelet manual dan konvolusi berbasis perulangan              |
| Filter wavelet     | Daubechies-2 (db2), empat koefisien filter                           |
| Input data         | File CSV atau sinyal simulasi                                        |
| Wavelet Toolbox    | Tidak digunakan untuk perhitungan DWT                                |
| Versi MATLAB       | Gunakan versi yang telah diuji kompatibilitasnya                     |

---

## Dataset

Program dirancang untuk membaca sinyal dari **MIT-BIH Arrhythmia Database**, menggunakan file CSV `mitbih_test.csv`.

Dataset ini terdiri dari dua koleksi sinyal detak jantung yang berasal dari dua dataset terkenal dalam klasifikasi detak jantung, yaitu MIT-BIH Arrhythmia Dataset dan The PTB Diagnostic ECG Database . Jumlah sampel dalam kedua koleksi tersebut cukup besar untuk melatih jaringan saraf dalam (deep neural network).

Dataset ini telah digunakan untuk mengeksplorasi klasifikasi detak jantung menggunakan arsitektur jaringan saraf dalam (deep neural network), dan mengamati beberapa kemampuan transfer learning di dalamnya. Sinyal-sinyal tersebut sesuai dengan bentuk elektrokardiogram (EKG) detak jantung untuk kasus normal dan kasus yang terkena berbagai aritmia dan infark miokard. Sinyal-sinyal ini diproses terlebih dahulu dan disegmentasi, dengan setiap segmen sesuai dengan satu detak jantung.

Link: https://www.kaggle.com/datasets/shayanfazeli/heartbeat 

### Asumsi input

- File input bernama `mitbih_test.csv`.
- Data harus memiliki minimal lima baris dan 187 kolom yang dapat dibaca sebagai sinyal.
- Program mengambil lima baris pertama, kemudian menggabungkan datanya menjadi satu vektor sinyal menggunakan `reshape()`.
- Frekuensi sampling diatur melalui variabel `fs` pada program.
- Jika data tidak berhasil dibaca atau dimensinya tidak memenuhi syarat, program menghasilkan sinyal simulasi sebagai alternatif.

**Penting:** Struktur kolom dan label harus diverifikasi berdasarkan file CSV yang digunakan. Program saat ini membaca 187 kolom pertama dari lima baris dan tidak secara eksplisit memisahkan kolom label. Penggabungan beberapa baris juga tidak menjamin terbentuknya rekaman EKG kontinu secara fisiologis.

---

## Fitur Utama

### 1. Graphical User Interface (GUI)

Antarmuka menyediakan panel parameter dan sejumlah tab pemrosesan:

- **Process:** panel input dan parameter.
- **Mallat:** tab untuk pengembangan atau visualisasi dekomposisi Mallat.
- **Filter Bank:** visualisasi sinyal input, koefisien filter, dan koefisien detail.
- **Zero-cross:** tab untuk pengembangan analisis persilangan nol.
- **Gradient:** tab untuk pengembangan analisis gradien.
- **Detection:** visualisasi sinyal EKG dan wilayah deteksi P, QRS, serta T.

Beberapa tab masih berupa kerangka antarmuka dan belum menjalankan algoritma terpisah.

### 2. Manual Wavelet Filter Construction

Program membentuk koefisien *low-pass filter* (`h`) dan *high-pass filter* (`g`) menggunakan persamaan matematis Daubechies-2.

Konstruksi filter dilakukan langsung melalui operasi aritmetika dan akar kuadrat, tanpa memanggil fungsi DWT bawaan MATLAB.

### 3. Manual Convolution

Konvolusi dilakukan menggunakan dua perulangan `for`. Pada setiap posisi, sinyal dikalikan dengan koefisien filter high-pass untuk menghasilkan koefisien detail dengan proses pengambilan sampel setiap dua posisi.

### 4. R-Peak Detection

Kandidat puncak R ditentukan menggunakan tiga kriteria:

- Amplitudo sinyal melebihi ambang yang dihitung dari rata-rata dan simpangan baku sinyal.
- Nilai sinyal lebih besar daripada dua sampel di sekitarnya.
- Jarak antarpuncak memenuhi interval minimum yang ditentukan.

Metode ini merupakan deteksi berbasis ambang amplitudo sederhana, bukan algoritma deteksi QRS klinis yang tervalidasi.

### 5. PQRST Region Visualization

Setelah kandidat puncak R diperoleh, program membentuk sinyal pulsa kotak (*gate signal*) untuk merepresentasikan perkiraan wilayah:

- **QRS:** wilayah sekitar kandidat puncak R.
- **P:** wilayah sebelum kandidat puncak R.
- **T:** wilayah setelah kandidat puncak R.

Ketiga wilayah ditampilkan bersama sinyal EKG untuk memudahkan pemeriksaan visual.

---

## Dasar Teori: DWT dan Filter Bank

*Discrete Wavelet Transform* (DWT) merupakan metode pemrosesan sinyal yang memisahkan komponen sinyal berdasarkan karakteristik frekuensinya melalui filter dan *downsampling*.

### Low-Pass Filter (LPF)

Koefisien `h` digunakan untuk menghasilkan komponen frekuensi yang relatif lebih rendah. Komponen ini dapat mempertahankan variasi sinyal yang lebih lambat.

### High-Pass Filter (HPF)

Koefisien `g` digunakan untuk menghasilkan komponen frekuensi yang relatif lebih tinggi. Komponen ini dapat menonjolkan perubahan amplitudo yang cepat.

Pada proyek ini, koefisien detail hasil filter high-pass divisualisasikan untuk menunjukkan penerapan dasar dekomposisi wavelet. Namun, hasil tersebut belum digunakan sebagai dasar utama deteksi R-peak dalam algoritma saat ini; deteksi R masih dilakukan langsung dari amplitudo sinyal EKG.

---

## Alur Pemrosesan

ECG CSV / Simulated Signal
          |
          v
    Signal Preparation
          |
          v
  Manual Wavelet Filter
     (LPF and HPF)
          |
          v
 Manual Convolution and
      Downsampling
          |
          v
    Detail Coefficients
          |
          v
  R-Peak Detection using
   Amplitude Thresholding
          |
          v
 P / QRS / T Gate Signals
          |
          v
     GUI Visualization
```

## Cara Menjalankan Program

1. Unduh atau *clone* repository ini.
2. Buka MATLAB.
3. Pastikan file `ecg-signal-processing.m` berada di *Current Folder* MATLAB.
4. Jika menggunakan data eksternal, sesuaikan lokasi file `mitbih_test.csv` pada bagian pemuatan data.
5. Jalankan perintah berikut pada MATLAB Command Window:

```matlab
ecg-signal-processing
```

6. Setelah GUI terbuka, klik tombol **Action** pada panel Process.
7. Periksa visualisasi filter, koefisien detail, dan wilayah deteksi pada tab Detection.

Jika file CSV tidak dapat dibaca atau dimensinya tidak sesuai dengan kondisi program, aplikasi akan mencoba menggunakan sinyal simulasi.

---

## Struktur Repository

ecg-signal-processing/
├── README.md
├── ecg-signal-processing.mlx
├── screenshots/
   ├── gui-interface.png
   ├── filter-bank.png
   └── detection-result.png
```

##  Keterbatasan

- Deteksi R-peak menggunakan ambang amplitudo dan jarak minimum antarpuncak.
- Wilayah P, QRS, dan T dibentuk menggunakan interval waktu tetap di sekitar kandidat R, bukan deteksi batas gelombang secara independen.
- Parameter numerik pada panel GUI belum dihubungkan ke fungsi pemrosesan.
- Koefisien detail DWT belum dimanfaatkan untuk menentukan kandidat R-peak.
- Sinyal simulasi hanya digunakan untuk demonstrasi dan tidak merepresentasikan rekaman klinis.
- Penggabungan lima baris CSV menjadi satu vektor dapat menimbulkan diskontinuitas antardetak.
- Akurasi deteksi belum dievaluasi menggunakan anotasi referensi atau metrik kuantitatif.

---

##  Pengembangan Selanjutnya

- Menghubungkan parameter GUI dengan algoritma pemrosesan.
- Mengimplementasikan deteksi batas gelombang P, Q, R, S, dan T secara terpisah.
- Memanfaatkan koefisien wavelet dalam proses deteksi kompleks QRS.
- Menambahkan pemilihan file CSV melalui GUI.
- Mengevaluasi hasil deteksi menggunakan anotasi referensi dan metrik sensitivitas serta *positive predictive value*.
- Membandingkan hasil implementasi manual dengan metode referensi yang sesuai.

---

Tambahkan lisensi jika kode akan didistribusikan atau digunakan kembali oleh pihak lain. Pastikan hak distribusi kode dan dataset telah diperiksa sebelum publikasi.
