#!/bin/bash

for((;;))
do
    ffmpeg -re -i ~/Downloads/h265.mp4 -c:v libx264 -vcodec copy -acodec copy -y rtmp://10.10.0.10/live/tbh265;
    sleep 1;
done
