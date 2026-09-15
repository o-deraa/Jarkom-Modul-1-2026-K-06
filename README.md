# JARKOM MODUL 1-2026-K-06

## Anggota Kelompok
|Nama|NRP|
|---|---|
|Dewa Ngakan Gede Wira Adhimukti|5027251063|
|Razana Aulia|5027251127|

## Laporan 
### 1. Membangun The Wired
   
Untuk membangun The Wired, Lain (Router) harus membuat tiga Switch, dengan rincian:
   - Swith 1 menuju Alice dan Mika
   - Switch 2 menuju Chisa
   - Switch 3 menuju Knights dan Eiri

![alt text](image.png)

<break>

### 2 - Menghubungkan Lain ke Internet
Karena The Wired masih terisolasi dari dunia luar, router (Lain) harus dikonfigurasi agar dapat tersambung ke internet. Untuk itu, interface eth0 pada Lain harus dihubungkan dengan NAT. Interface tersebut kemudian dikonfigurasi sebagai DHCP client agar memperoleh alamat IP secara otomatis dari NAT.
   
![alt text](image-1.png)

Konfigurasi yagn dimasukkan ke `/etc/network/interfaces` adalah sebagai berikut:

```
auto eth0
iface eth0 inet dhcp
        hostname alpinet-1
```

![alt text](image-2.png)

Konfigurasi `iface eth0 inet dhcp` membuat interface `eth0` menggunakan DHCP sehingga alamat IP dan konfigurasi jaringan dapat diperoleh secara otomatis dari NAT. Sementara itu, `auto eth0` memastikan interface tersebut diaktifkan secara otomatis ketika konfigurasi jaringan dijalankan.


Setelah konfigurasi diterapkan, dilakukan pengujian konektivitas menggunakan `ping` untuk memastikan bahwa Lain telah dapat terhubung ke jaringan luar.

![alt text](image-4.png)

Tes menunjukkan bahwa Lain sudah berhasil terkoneksi dengan internet melalu NAT.

### 3 - Menghubungkan Sesama Client

Untuk membuat semua client dapat saling berkomunikasi, setiap jaringan client perlu memiliki gateway yang mengarah ke router Lain. Oleh karena itu, interface pada router Lain yang terhubung ke masing-masing switch dikonfigurasi menggunakan IP statis. IP tersebut nantinya akan digunakan sebagai default gateway oleh client pada jaringan masing-masing.

Prefix IP untuk kelompok 6 adalah `192.214.x.x`, sehingga pembagian IP untuk setiap switch adalah sebagai berikut:
- Switch 1: 192.214.1.1 (terhubung dengan eth1)
- Switch 2: 192.214.2.1 (terhubung dengan eth2)
- Switc 3: 192.214.3.1 (terhubung dengan eth3)

![alt text](image-5.png)

Setelah konfigurasi selesai, dilakukan tes menggunakan command `ip a ` untuk memastikan bahwa setiap interface telah memperoleh alamat IP sesuai dengan konfigurasi yang telah ditetapkan.

![alt text](image-6.png)

Hasil tes menunjukkan bahwa `eth1`, e`th2, dan `eth3` masing-masing telah memiliki alamat IP `192.214.1.1/24`, `192.214.2.1/24`, dan `192.214.3.1/24`, sehingga konfigurasi pada setiap interface router telah berhasil dilakukan.

Setelah switch dikonfigurasi, selanjutnya adalah memberikan alamat IP untuk setiap client sesuai dengan switch yang terhubung dengan mereka. Berikut adalah konfigurasi untuk setiap client:

- Alice

    ```bash
    auto eth0
    iface eth0 inet static
        address 192.214.1.2
        netmask 255.255.255.0
        gateway 192.214.1.1
    ```

    ![alt text](image-7.png)



- Mika
  
    ```bash
    auto eth0
    iface eth0 inet static
        address 192.214.1.3
        netmask 255.255.255.0
        gateway 192.214.1.1
    ```
    ![alt text](image-8.png)

- Chisa

    ```bash
    auto eth0
    iface eth0 inet static
        address 192.214.2.2
        netmask 255.255.255.0
        gateway 192.214.2.1
    ```
    ![alt text](image-9.png)

- Knights
    ```bash
    auto eth0
    iface eth0 inet static
        address 192.214.3.2
        netmask 255.255.255.0
        gateway 192.214.3.1
    ```

    ![alt text](image-10.png)

- Eiri
    ```bash
    auto eth0
    iface eth0 inet static
        address 192.214.3.3
        netmask 255.255.255.0
        gateway 192.214.3.1
    ```

    ![alt text](image-11.png)

Selanjutnya akan dilakukan tes untuk melakukan ping antar-client.

- Alice
    ![alt text](image-12.png)

- Mika
    ![alt text](image-13.png)
- Chisa
  ![alt text](image-14.png)
- Knights
  ![alt text](image-15.png)
- Eiri
  ![alt text](image-16.png)

Hasil tes menunjukkan bahwa semua client sudah berhasil terhubung dan berkomunikasi satu sama lainnya.

### 4 Konfigurasi iptables dan DNS Resolver 

Lain ingin agar setiap Client dapat memiliki kemandirian di The Wired. Oleh karena itu, perlu dilakukan konfigurasi DNS resolver pada setiap client serta konfigurasi NAT dan IP forwarding pada router Lain agar setiap client dapat mengakses internet.

Pertama, dilakukan pengecekan terhadap nameserver yang diperoleh Lain dari NAT melalui file /etc/resolv.conf.

![alt text](image-17.png)

Berdasarkan hasil pengecekan, nameserver yang digunakan oleh Lain adalah `192.168.122.1`. IP tersebut kemudian ditambahkan ke file `/etc/resolv.conf` pada masing-masing client agar client dapat melakukan DNS resolution.

- Alice
  ![alt text](image-18.png)

- Mika
  ![alt text](image-19.png)
- Chisa
  ![alt text](image-20.png)
- Knights
  ![alt text](image-21.png)
- Eiri
  ![alt text](image-22.png)

Setelah konfigurasi DNS resolver pada masing-masing client selesai, tahap selanjutnya adalah mengatur NAT pada router Lain menggunakan `iptables`. Pada node Lain, `iptables` telah tersedia sehingga tidak diperlukan instalasi tambahan. Rule NAT ditambahkan menggunakan command berikut:

Karena `iptables` secara bawaan sudah terinstal, maka langkah selanjutnya adalah menambahkan rule berikut ke NAT:

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.214.0.0/16
```
Rule tersebut melakukan Network Address Translation (NAT) terhadap paket yang berasal dari jaringan client `192.214.0.0/16` dan keluar melalui interface `eth0`. Opsi `MASQUERADE` akan mengganti source IP client dengan IP yang dimiliki oleh interface `eth0` pada Lain, sehingga paket dapat diteruskan menuju NAT dan internet.

Setelah konfigurasi NAT dibuat, Lain perlu diatur agar dapat meneruskan paket dari jaringan client menuju jaringan luar. Hal tersebut dilakukan dengan mengaktifkan IP forwarding menggunakan command:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```
Konfigurasi tersebut memungkinkan Lain berfungsi sebagai router yang meneruskan paket dari interface internal (`eth1`, `eth2`, dan `eth3`) menuju `eth0`.

Setelah semua hal di atas dilakukan, kemudian dicek apakah setiap client sudah berhasil terhubung ke internet atau belum dengan cara melakukan command`ping` ke google.com.

- Alice
  ![alt text](image-23.png)
- Mika
  ![alt text](image-24.png)
- Chisa
  ![alt text](image-25.png)
- Knights
  ![alt text](image-26.png)
- Eiri
  ![alt text](image-27.png)
 
 Tes di atas menunjukkan bahwa setiap client berhasil memperoleh response dari google.com. Hal tersebut menunjukkan bahwa konfigurasi DNS resolver, NAT, dan IP forwarding telah berhasil sehingga setiap client dapat terhubung ke internet melalui router Lain.

 ### 5 - Backup Konfigurasi Jaringan

Eiri terus berupaya menanamkan kekacauan ke dalam jaringan. Untuk itu, perlu dibuat agar konfigurasi jaringan tidak hilang saat semua node di-restart. Pada tahap ini, konfigurasi Router Lain terlebih dahulu dibuat agar dapat dipulihkan secara otomatis ketika node kembali dijalankan.

Konfigurasi interface disimpan pada `/etc/network/interfaces,` sedangkan konfigurasi IP forwarding dan NAT perlu dijalankan kembali karena keduanya merupakan konfigurasi runtime yang tidak bertahan setelah container dihentikan.

Sebelum menentukan mekanisme untuk menjalankan konfigurasi tersebut secara otomatis, dilakukan pemeriksaan terhadap proses yang berjalan pada container Lain. Pemeriksaan dilakukan menggunakan command:

```bash
ps -o pid,ppid,args
```
Perintah tersebut digunakan untuk menampilkan Process ID (PID), Parent Process ID (PPID), dan argumen/perintah yang dijalankan oleh setiap proses.

Hasil pemeriksaan pada Router Lain adalah:

![alt text](image-28.png)

Berdasarkan hasil tersebut, dapat diketahui bahwa proses utama container menjalankan `/bin/sh /etc/alpinet-init.sh`dengan PID 83. Proses tersebut kemudian menjalankan Bash dengan PID 84 yakni bash `-i -l`. Parameter -i menunjukkan bahwa Bash dijalankan sebagai interactive shell, sedangkan parameter -l menunjukkan bahwa Bash dijalankan sebagai login shell.

Karena Bash pada container Lain dijalankan sebagai login shell, digunakan `/root/.bash_profile` sebagai file startup untuk menjalankan kembali konfigurasi yang diperlukan. Pada Bash, `.bash_profile` merupakan salah satu file startup yang dibaca ketika login shell dimulai. Oleh karena itu, konfigurasi IP forwarding dan NAT dapat ditempatkan di dalam file tersebut sehingga dijalankan kembali secara otomatis ketika Bash login dimulai.

File `/root/.bash_profile` kemudian diisi dengan:

```bash
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -C POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE
EOF
```

Lalu permissionm file diatur dengan:
```bash
chmod +x /root/.bash_profile
```

Untuk menguji apakah .bash_profile benar-benar dijalankan oleh login shell, dilakukan tes sederhana dengan cara menghapus rule pada NAT menggunakan command berikut.
```bash
iptables -t nat -D POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE
```

Kemudian dicek menggunakan command `iptables -t nat -L POSTROUTING -n -v` dan diperoleh hasil sebagai berikut.

![alt text](image-29.png)

Pengecekan tabel NAT menunjukkan bahwa rule MASQUERADE sudah tidak tersedia

Lalu dibuat sesi Bash baru menggunakan mode interactive dan login dengan command berikut.

```bash
bash -i -l
```

Setelah Bash login dijalankan, tabel NAT diperiksa kembali dan diperoleh hasil sebagai berikut.

![alt text](image-30.png)

![alt text](image-31.png)

Hasilnya menunjukkan rule MASQUERADE kembali tersedia dan membuktikan bahwa konfigurasi pada `/root/.bash_profile` berhasil dijalankan ketika Bash login shell dimulai. IP forwarding juga diperiksa dan mengembalikan angka `1` yagn menandakan bahwa IP forwarding telah aktif.