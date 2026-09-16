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

 ### 5 - Setup Recovery Jaringan

Eiri terus berupaya menanamkan kekacauan ke dalam jaringan. Untuk itu, perlu dibuat agar konfigurasi jaringan tidak hilang saat semua node di-restart. Pada tahap ini, konfigurasi Router Lain terlebih dahulu dibuat agar dapat dipulihkan secara otomatis ketika node kembali dijalankan.

Konfigurasi alamat dan gateway interface disimpan pada `/etc/network/interfaces`. Sementara itu, IP forwarding dan rule NAT pada `iptables` merupakan konfigurasi runtime yang berada pada state kernel dan tabel firewall container, sehingga perlu diterapkan kembali ketika container dijalankan kembali.

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

Selanjutnya, akan dilakukan konfigurasi file `/root/.bash_profile` pada masing - masing client.

#### Alice
```bash
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF
```

#### Mika
```bash
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF
```

#### Chisa
```bash
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.2.2
    netmask 255.255.255.0
    gateway 192.214.2.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF
```

#### Knights
```bash
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.3.2
    netmask 255.255.255.0
    gateway 192.214.3.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF
```

#### Eiri
```bash
cat > /root/.bash_profile <<'EOF'
#!/bin/bash

cat > /etc/network/interfaces <<'NETEOF'
auto eth0
iface eth0 inet static
    address 192.214.3.3
    netmask 255.255.255.0
    gateway 192.214.3.1
NETEOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

ifup eth0 2>/dev/null || true
EOF
```

Pada scrip - script di atas, terdapat baris kode `ifup eth0 2>/dev/null || true`. Command `ifup eth0` digunakan untuk mengaktifkan interface berdasarkan konfigurasi pada `/etc/network/interfaces`. Penggunaan `2>/dev/null || true` berfungsi mencegah proses startup berhenti apabila interface sudah berada dalam kondisi aktif.

Selanjutnya, akan dibuat suatu script untuk melakukan verifikasi di `/root/cek_status.sh` pada router Lain. Script akan menampilkan  ringkasan interface (ip -br a) dan status tabel NAT (iptables -t nat -L -v -n) setelah reboot. Berikut adalah isi dari script tersebut:

```bash
cat > /root/cek_status.sh <<'EOF'
#!/bin/sh

echo "===== STATUS INTERFACE ====="
ip -br a

echo
echo "===== STATUS NAT ====="
iptables -t nat -L -v -n
EOF

chmod +x /root/cek_status.sh
```

 Validasi dilakukan melalui dua parameter  utama. Command `ip -br a` berfungsi untuk memastikan seluruh interface jaringan beserta alokasi alamat IP-nya tetap aktif dan terkonfigurasi dengan benar. Command iptables -t nat -L -v -n digunakan untuk mengonfirmasi keberadaan dan konfigurasi rule NAT pada tabel NAT. 

### 6 - Display Filter

Mika mencurigai adanya anomali traffic pada segmen jaringannya. Jalankan generator traffic pada node Mika, lalu lakukan packet sniffing menggunakan Wireshark pada interface node Mika. Terapkan display filter khusus untuk menyaring paket yang berprotokol DNS atau ICMP. Tunjukkan screenshot hasil filter beserta ringkasan paket yang lolos.

Pertama, file harus didownload dan di-unzip terlebih dahulu di dalam node Mika.

```bash
gdown --folder "https://drive.google.com/drive/folders/1ZjFvWIjvAQAjE9pPthm7V_bGyaSt93lY?usp=sharing" -O traffic

cd traffic/
unzip traffic_protocol7.zip
```


![alt text](image-32.png)

![alt text](image-33.png)

Setelah file diunduh dan diekstrak, ditemukan file bernama `traffic_protocol7.sh`. Setelah itu, file dijalankan di dalam node Mika dengan cara:

```bash
bash traffic_protocol7.shh
```

File lalu akan membanjiri jaringan di node Mika dengan banyak paket. Untuk mengecek paket yang masuk menggunakan wireshark, digunakan caputring antara connecting line Mika dan switch 1.

![alt text](image-34.png)

Di dalam wireshark akan terlihat jelas semua paket yang masuk tadi. 

![alt text](image-35.png)

Gambar menunjukkan sesi capture Wireshark pada interface `Switch1 Ethernet2 to Mika eth0 `tanpa display filter aktif, sehingga seluruh jenis protokol tertampil apa adanya. Paket yang terlihat didominasi oleh traffic ICMP berupa aktivitas ping berulang dari host `192.214.1.3` ke dua tujuan yaitu `8.8.8.8` (Google DNS) dan `1.1.1.1` (Cloudflare), dengan sequence number yang terus bertambah mulai dari seq 3/768 hingga seq 5/1280 dan semua mendapat balasan *reply* yang sukses. Di penghujung capture, muncul empat paket ARP pada timestamp sekitar 5.40 detik, di mana dua perangkat dengan MAC `02:42:d7:22:4b:01` dan `02:42:29:1f:8f:00` saling bertukar informasi untuk memetakan alamat IP `192.214.1.3` dan `192.214.1.1` ke alamat MAC masing-masing, yang merupakan proses resolusi alamat yang umum terjadi di jaringan lokal.

Untuk  menyaring paket yang berprotokol DNS atau ICMP, cukup mengetikkan `dns || icmp` pada display filter, sehingga diperoleh hasil sebagai berikut:

![alt text](image-36.png)

Wireshark hanya menampilkan paket yang termasuk protokol DNS atau ICMP, menyembunyikan seluruh traffic lain seperti ARP, TCP, maupun protokol lainnya dari tampilan. Dari keseluruhan sesi capture, terdapat 18 paket yang berhasil lolos filter — terdiri dari 10 paket DNS dan 8 paket ICMP.

Paket DNS mencakup query tipe A dan AAAA ke beberapa domain seperti its.ac.id, github.com, cloudflare.com, dan google.com, dengan DNS server yang digunakan meliputi resolver lokal 192.168.122.1, Google 8.8.8.8, dan Cloudflare 1.1.1.1. Sementara itu, paket ICMP merekam aktivitas ping ke tiga tujuan berbeda yaitu 8.8.8.8, 1.1.1.1, dan 103.94.189.4 (IP hasil resolusi its.ac.id) yang semuanya berhasil mendapatkan reply, secara langsung menunjukan konektivitas jaringan dalam kondisi baik selama sesi capture berlangsung.

### 7 - Membuat Server FTP

Chisa memutuskan mendirikan FTP Server pada node miliknya dengan menggunakan /`var/wired/data sebagai shared folder`. Sebelum melakukan konfigurasi, package vsftpd perlu di-install terlebih dahulu dengan perintah berikut:

```bash
apk add vsftpd
```

![alt text](image-37.png)

Setelah package FTP terpasang,` /sbin/nologin` didaftarkan ke `/etc/shells`. Shell ini digunakan pada akun FTP agar user dapat digunakan untuk autentikasi FTP tanpa memberikan akses ke interactive shell pada sistem.

```bash
grep -qxF "/sbin/nologin" /etc/shells || echo "/sbin/nologin" >> /etc/shells
```

Selanjutnya dibuat direktori `/var/wired/data` yang akan digunakan sebagai shared folder untuk menyimpan file yang dapat diakses melalui FTP. Variabel `SHARED` digunakan agar path tersebut dapat digunakan kembali pada konfigurasi user berikutnya.

```bash
SHARED="/var/wired/data"
mkdir -p "$SHARED"
```

Setelah server dan shared folder disiapkan, selanjutnya dibuat tiga user yang akan digunakan untuk autentikasi FTP, yaitu `alice`, `mika`, dan `eiri`.

```bash
id alice >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin alice
echo "alice:alice123" | chpasswd

id mika >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin mika
echo "mika:mika123" | chpasswd

id eiri >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin eiri
echo "eiri:eiri123" | chpasswd
```
Setiap user diberikan password dengan pola nama user diikuti 123, yaitu `alice123`, `mika123`, dan `eiri123`.

Setelah user dibuat, home directory ketiga user dipastikan mengarah ke /var/wired/data. Pada Alpine Linux, perubahan ini dilakukan dengan memperbarui entry user pada /etc/passwd karena utilitas usermod tidak tersedia secara default.

```bash
sed -i 's|^alice:.*$|alice:x:1000:1000::/var/wired/data:/sbin/nologin|' /etc/passwd 
sed -i 's|^mika:.*$|mika:x:1001:1001::/var/wired/data:/sbin/nologin|' /etc/passwd 
sed -i 's|^eiri:.*$|eiri:x:1002:1002::/var/wired/data:/sbin/nologin|' /etc/passwd
```

Konfigurasi tersebut memastikan ketiga user memiliki /var/wired/data sebagai home directory dan tetap menggunakan /sbin/nologin sebagai shell.

Selanjutnya adalah membuat hak akses untuk tiap user seusai dengan ketentuan berikut:
- Alice: read & write
- Mika: read-only
- Eiri: blacklist/tidak memiliki akses FTP

Sebelum itu, kita perlu mengatur permission shared folder secara langsung di filesystem linux dengan cara:

```bash
chown alice:alice "$SHARED"
chmod 755 "$SHARED"
```

Perintah tersebut menjadikan Alice sebagai pemilik shared folder dan memberikan permission `rwx` kepada owner serta` r-x` kepada user lainnya. Dengan demikian, Alice memiliki hak untuk membaca dan menulis pada folder, sedangkan user lainnya hanya memiliki akses untuk membaca isi folder dan masuk ke dalamnya.

Selanjutnya dilakukan konfigurasi untuk vsftpd dengan cara berikut:

```bash
cat > /etc/vsftpd/vsftpd.conf <<'CFG'
listen=YES
listen_ipv6=NO
listen_address=0.0.0.0
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
user_config_dir=/etc/vsftpd_users
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.user_list
seccomp_sandbox=NO
CFG
```
Konfigurasi tersebut mengaktifkan akses FTP menggunakan akun lokal dan menonaktifkan anonymous login sehingga setiap koneksi harus menggunakan akun yang telah dibuat. `listen_address=0.0.0.0` membuat server menerima koneksi FTP melalui seluruh interface IPv4. `chroot_local_user` membatasi user agar tetap berada di dalam direktori home-nya, sedangkan `user_config_dir` digunakan untuk menerapkan konfigurasi yang berbeda pada masing-masing user. Selain itu, `userlist_enable=YES` dan `userlist_deny=NO` membuat `/etc/vsftpd.user_list `berfungsi sebagai allowlist yang menentukan user mana yang diperbolehkan melakukan login ke FTP. `seccomp_sandbox=NO` digunakan agar vsftpd dapat berjalan dengan baik di Alpine Linux.



Kemudian ditentukan user mana saja yang diperbolehkan untuk melakukan login.

```bash
cat > /etc/vsftpd.user_list <<'USERS'
alice
mika
USERS
```
File tersebut berisi daftar user yang diizinkan untuk melakukan login ke FTP karena konfigurasi menggunakan `userlist_deny=NO`. Alice dan Mika dimasukkan ke dalam daftar, sedangkan Eiri tidak dimasukkan sehingga percobaan login menggunakan akun Eiri akan ditolak.

Selanjutnya dibuat konfigurasi khusus untuk masing-masing user melalui direktori `/etc/vsftpd_users`.

```bash
mkdir -p /etc/vsftpd_users

cat > /etc/vsftpd_users/alice <<'ALICE'
local_root=/var/wired/data
write_enable=YES
ALICE

cat > /etc/vsftpd_users/mika <<'MIKA'
local_root=/var/wired/data
write_enable=NO
MIKA
```

Direktori `/etc/vsftpd_users` digunakan untuk menyimpan konfigurasi khusus masing-masing user. Alice diberikan `write_enable=YES` sehingga dapat melakukan operasi baca dan tulis, sedangkan Mika diberikan `write_enable=NO` sehingga akses tulis melalui FTP dinonaktifkan dan Mika hanya dapat membaca file.


Terakhir, server perlu dijalankan dengan cara berikut:

```bash
vsftpd /etc/vsftpd/vsftpd.conf &
ps | grep vsftpd
```
Setelah seluruh konfigurasi selesai, `vsftpd` dijalankan menggunakan file konfigurasi yang telah dibuat. Selanjutnya dilakukan pemeriksaan proses untuk memastikan `vsftpd` telah berjalan dan siap menerima koneksi FTP dari client.

Semua hal tadi dapat dijalankan secara langsung melalui satu script, di sini kami memasukkannya ke dalam script setup_ftp.sh.

- setup_ftp.sh
```bash
#!/bin/bash

# Install vsftpd jika belum ada
apk add --no-cache vsftpd >/dev/null 2>&1

# Daftarkan shell nologin untuk akun FTP
grep -qxF "/sbin/nologin" /etc/shells || echo "/sbin/nologin" >> /etc/shells

# Shared folder
SHARED="/var/wired/data"
mkdir -p "$SHARED"

# Buat user FTP jika belum ada
id alice >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin alice
echo "alice:alice123" | chpasswd

id mika >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin mika
echo "mika:mika123" | chpasswd

id eiri >/dev/null 2>&1 || adduser -D -h "$SHARED" -s /sbin/nologin eiri
echo "eiri:eiri123" | chpasswd

# Pastikan home directory setiap user adalah shared folder
sed -i 's|^alice:.*$|alice:x:1000:1000::/var/wired/data:/sbin/nologin|' /etc/passwd
sed -i 's|^mika:.*$|mika:x:1001:1001::/var/wired/data:/sbin/nologin|' /etc/passwd
sed -i 's|^eiri:.*$|eiri:x:1002:1002::/var/wired/data:/sbin/nologin|' /etc/passwd

# Permission shared folder
chown alice:alice "$SHARED"
chmod 755 "$SHARED"

# Konfigurasi utama vsftpd
cat > /etc/vsftpd/vsftpd.conf <<'CFG'
listen=YES
listen_ipv6=NO
listen_address=0.0.0.0
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
user_config_dir=/etc/vsftpd_users
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.user_list
seccomp_sandbox=NO
CFG

# User yang diizinkan login FTP
cat > /etc/vsftpd.user_list <<'USERS'
alice
mika
USERS

# Konfigurasi per-user
mkdir -p /etc/vsftpd_users

cat > /etc/vsftpd_users/alice <<'ALICE'
local_root=/var/wired/data
write_enable=YES
ALICE

cat > /etc/vsftpd_users/mika <<'MIKA'
local_root=/var/wired/data
write_enable=NO
MIKA

# Jalankan vsftpd jika belum berjalan
killall vsftpd 2>/dev/null || true
vsftpd /etc/vsftpd/vsftpd.conf &
```

Setelah semua konfigurasi selesai, langkah terakhir yaitu membuktikan bahwa semua konfigurasi yagn sudah dibuat berjalan seperti seharusnya. Pengujian yang akan dilakukan yaitu:
- Alice membuat signal_alice.txt dan meng-upload ke FTP Chisa.
- Eiri mencoba login ke FTP Chisa dan ditolak.

Pertama, dilakukan pengujian dengan mengupload file dari Alice ke FPT Chisa.
```bash
touch signal_alice.txt
echo "Signal from Alice" > signal_alice.txt

lftp -u alice,alice123 192.214.2.2

put signal_alice.txt
exit
```
![alt text](image-38.png)

Selanjutnya dilakukan verifikasi pada server FTP milik Chisa.

![alt text](image-39.png)

Hasil tersebut menunjukkan bahwa `signal_alice.txt` berhasil tersimpan pada shared folder, sehingga dapat dibuktikan bahwa user `alice` memiliki hak akses read & write.

Eiri
![alt text](image-40.png)

Pesan `530 Permission denied` menunjukkan bahwa autentikasi FTP untuk user eiri ditolak oleh server. Hal tersebut terjadi karena konfigurasi menggunakan `userlist_deny=NO`, sehingga hanya user yang tercantum pada `/etc/vsftpd.user_list`, yaitu alice dan mika, yang diizinkan melakukan login ke FTP Server.

### 8 - Kngihts

Kelompok rahasia Knights perlu mengirimkan dokumen laporan intelijen ke FTP Server Chisa. Lakukan koneksi FTP client dari node Knights ke FTP Server Chisa menggunakan akun alice. Upload file berikut (link file). Analisis sesi Wireshark dan sebutkan: perintah FTP untuk upload (STOR), kode status sukses server (226), dan port data TCP yang dinegosiasikan pada mode PASV.

Pertama, file harus didownload dan di-unzip terlebih dahulu di dalam node Knights.

```bash
gdown "https://drive.google.com/file/d/1lFepK4wFmx55PnRki3NsHW-ivudSR0vg/view?usp=drive_link" -O traffic

unzip traffic
```

![alt text](image-41.png)

Setelah file didownlaod dan di-unzip, ditemukan 1 file baru yakni `knights_report.txt`. File `knights_report` adalah dokumen laporan intelijen yang akan dikirimkan ke FTP Server Chisa,

Setelah file tersedia, node Knights melakukan koneksi ke FTP Server Chisa menggunakan akun `alice`. Alamat IP FTP Server Chisa adalah `192.214.2.2`.

```bash
lftp -u alice,alice123 192.214.2.2
```
Setelah berhasil terhubung, passive mode diaktifkan menggunakan perintah berikut:

```
set ftp:passive-mode true
```
Perintah tersebut digunakan untuk memastikan client menggunakan FTP Passive Mode (PASV) dalam membangun koneksi data. Pada mode ini, client meminta server menentukan port yang akan digunakan untuk koneksi data.

Setelah koneksi FTP berhasil dibuat, file` knights_report.txt` dikirimkan ke server menggunakan perintah `put`.

```
put knights_report.txt
```

![alt text](image-42.png)

Berdasarkan hasil pada terminal, proses transfer `knights_report.txt` berhasil dilakukan dari node Knights menuju FTP Server Chisa. Untuk memastikan bahwa file benar-benar telah tersimpan pada server, dilakukan verifikasi secara langsung pada node Chisa.

```bash
ls -lh /var/wired/data
```
![alt text](image-43.png)

Hasil verifikasi menunjukkan bahwa file `knights_report.txt` telah terdapat di dalam direktori `/var/wired/data` pada node Chisa. Hal tersebut membuktikan bahwa file yang dikirim dari Knights berhasil diterima dan disimpan oleh FTP Server.


Selama proses transfer berlangsung, trafik jaringan antara Knights dan FTP Server Chisa ditangkap menggunakan Wireshark. Capture kemudian dianalisis untuk mengidentifikasi tahapan komunikasi FTP, khususnya proses negosiasi passive mode dan transfer file.

Hasil wireshark
![alt text](image-44.png)
![alt text](image-45.png)

Analisis trafik dilakukan menggunakan Wireshark pada koneksi antara node Knights sebagai FTP Client dengan node Chisa sebagai FTP Server. Node Knights menggunakan alamat IP `192.214.3.2`, sedangkan FTP Server Chisa menggunakan alamat IP `192.214.2.2`. Koneksi dilakukan menggunakan akun `alice` untuk mengunggah file `knights_report.txt`.

Berdasarkan hasil packet capture, sesi FTP diawali ketika client Knights terhubung ke FTP Server Chisa. Server memberikan response 220 yang menunjukkan bahwa layanan FTP tersedia dan server siap menerima koneksi. Selanjutnya terjadi proses negosiasi fitur melalui perintah `FEAT` dengan response 211. Client juga mencoba menggunakan `AUTH TLS`, tetapi server memberikan response 530, sehingga koneksi dilanjutkan menggunakan FTP tanpa enkripsi TLS.

Proses autentikasi kemudian dilakukan menggunakan perintah `USER alice`, yang diikuti response 331 dari server untuk meminta password. Client mengirimkan password `alice123` melalui perintah `PASS`, kemudian server memberikan response 230, yang menunjukkan bahwa autentikasi berhasil. Setelah berhasil login, client menjalankan perintah `PWD` dan `TYPE I` untuk mengetahui direktori aktif serta menggunakan mode transfer binary.


Pada paket No. 40 terlihat perintah:

```text
Request: STOR knights_report.txt
```

Perintah tersebut dikirim dari `192.214.3.2` sebagai client menuju `192.214.2.2` sebagai server. Perintah `STOR` digunakan dalam FTP untuk meminta server menyimpan data yang dikirim oleh client sebagai sebuah file. Dalam sesi ini, file yang dikirim adalah `knights_report.txt`, sehingga paket tersebut menjadi bukti bahwa proses upload dilakukan dari node Knights ke FTP Server Chisa.


Sebelum proses upload, client menggunakan passive mode dengan mengirimkan perintah `PASV`. Pada paket No. 36, server memberikan response:

```text
227 Entering Passive Mode (192,214,2,2,63,66)
```

Response tersebut menunjukkan bahwa server FTP meminta client menggunakan koneksi data pada alamat `192.214.2.2` dengan port yang ditentukan oleh dua nilai terakhir, yaitu `p1 = 63` dan `p2 = 66`.

Port TCP data dihitung menggunakan formula:

```text
Port = (p1 × 256) + p2
      = (63 × 256) + 66
      = 16.194
```

Dengan demikian, port TCP data yang dinegosiasikan pada passive mode adalah 16.194. Port tersebut digunakan untuk koneksi data FTP yang terpisah dari koneksi control FTP.


Setelah perintah `STOR` dikirim dan data file ditransfer, server memberikan response pada paket No. 47:

```text
Response: 226 Transfer complete.
```

Kode status 226 menunjukkan bahwa koneksi data telah ditutup dan operasi transfer file telah berhasil diselesaikan. Dengan demikian, response ini menjadi bukti dari sisi server bahwa proses upload `knights_report.txt` telah selesai.

Berdasarkan hasil capture, keseluruhan sesi FTP dapat diringkas sebagai berikut:

```text
Knights (192.214.3.2)
        │
        │ Connect
        ▼
Chisa FTP Server (192.214.2.2)
        │
        ├── 220 Service ready
        ├── FEAT → 211
        ├── AUTH TLS → 530
        ├── USER alice → 331
        ├── PASS alice123 → 230
        ├── PWD → 257
        ├── TYPE I → 200
        ├── PASV → 227
        │      └── Data Port = 16.194
        │
        ├── STOR knights_report.txt
        │      └── File ditransfer melalui koneksi data
        │
        ├── 226 Transfer complete
        └── QUIT → 221
```

Dari hasil analisis tersebut dapat disimpulkan bahwa node Knights berhasil melakukan upload `knights_report.txt` ke FTP Server Chisa menggunakan akun `alice`. Tiga informasi utama yang diperoleh dari packet capture adalah perintah `STOR knights_report.txt` sebagai indikasi proses upload, response `226 Transfer complete` sebagai indikasi transfer berhasil, serta port TCP 16.194 yang dinegosiasikan server melalui response `227` pada passive mode.

### 9