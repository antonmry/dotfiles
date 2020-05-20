#! /bin/bash

rclone sync GoogleDrive:todo ~/Documents/todo/
todo.sh "$@"
rclone sync ~/Documents/todo/ GoogleDrive:todo 
