#!/bin/bash
# Node: Mika

gdown --folder "https://drive.google.com/drive/folders/1ZjFvWIjvAQAjE9pPthm7V_bGyaSt93lY?usp=sharing" -O traffic
cd traffic/
unzip traffic_protocol7.zip
bash traffic_protocol7.sh