#!/bin/bash
# Node: Knights

gdown "https://drive.google.com/file/d/1lFepK4wFmx55PnRki3NsHW-ivudSR0vg/view?usp=drive_link" -O laporan
unzip laporan

lftp -u alice,alice123 192.214.2.2 << 'EOF'
set ftp:passive-mode true
put knights_report.txt
exit
EOF