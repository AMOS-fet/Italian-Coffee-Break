#!/bin/bash

# -----------------------------------------------------
# File: newspaper.sh
# Description: Launch bulletty without leaving data on disk
# Author: AMOS-fet
# -----------------------------------------------------

# =====================================================
# 1. Folders setup
# =====================================================

RAM_DIR="/tmp/bulletty"

mkdir -p "$RAM_DIR"

# =====================================================
# 2. Sources
# Syntax: bulletty add <URL> <Categoria_Opzionale>
# =====================================================

bulletty add https://cyclingpro.net/spaziociclismo/feed/ Ciclismo
bulletty add https://www.ilpost.it/politica/feed/ Politica
bulletty add https://www.ilpost.it/mondo/feed/ Politica
bulletty add https://www.ispionline.it/it/feed/ Politica
bulletty add https://spectrum.ieee.org/feeds/feed.rss Tech
bulletty add https://hackaday.com/blog/feed/ Tech
bulletty add https://www.phoronix.com/rss.php Tech

# =====================================================
# 3. Application
# =====================================================
bulletty

rm -rf "$RAM_DIR"/*

clear
