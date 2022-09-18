SHELL := /bin/bash

.PHONY: all

all: Fonts.squashfs ShadedReliefBasic.squashfs NaturalEarthShadedRelief.squashfs GrayEarthShadedRelief.squashfs

NODE_FONTNIK_PKG_VERSION=v0.0.1

# Fonts

noto-fonts:
	mkdir -p $@
	curl -sL "https://github.com/notofonts/noto-fonts/archive/2725c70.tar.gz" | tar -xzf - -C ./noto-fonts --strip-components 1

noto-emoji:
	mkdir -p $@
	curl -sL "https://github.com/googlefonts/noto-emoji/archive/e8073ab.tar.gz" | tar -xzf - -C ./noto-emoji --strip-components 1

noto-cjk:
	mkdir -p $@
	(cd noto-cjk && curl -sLO https://github.com/googlefonts/noto-cjk/releases/download/Sans2.004/04_NotoSansCJK-OTF.zip && unzip *.zip)

node-fontnik-pkg:
	curl --fail -LO https://github.com/SahAssar/node-fontnik-pkg/releases/download/${NODE_FONTNIK_PKG_VERSION}/node-fontnik-pkg.gz
	gunzip node-fontnik-pkg.gz
	chmod +x node-fontnik-pkg

FontsTmp: node-fontnik-pkg noto-fonts noto-emoji noto-cjk
	./node-fontnik-pkg

Fonts.squashfs: FontsTmp
	mksquashfs ./FontsTmp ./Fonts.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports

# ShadedReliefBasic

SR_HR.zip:
	curl --fail -LO https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/SR_HR.zip

SR_HR.tif: SR_HR.zip
	unzip -oj SR_HR.zip

SR_HR-warped.tif: SR_HR.tif
	gdalwarp -r bilinear -t_srs EPSG:3857 -dstnodata None -co BIGTIFF=IF_NEEDED SR_HR.tif SR_HR-warped.tif

ShadedReliefBasicTmp: SR_HR-warped.tif
	gdal2tiles.py --zoom=0-6 --tilesize=1024 --resampling=bilinear --processes=12 --xyz -n SR_HR-warped.tif ./ShadedReliefBasicTmp
	find ./ShadedReliefBasicTmp -name '*.png' | parallel pngquant --ext .png --force {}
	find ./ShadedReliefBasicTmp -name '*.png' | parallel zopflipng -y {} {}
	find ./ShadedReliefBasicTmp \( -name '*.xml' -or -name '*.html' -or -name '*.mapml' -or -name '*.json' \) -delete

ShadedReliefBasic.squashfs: ShadedReliefBasicTmp
	mksquashfs ./ShadedReliefBasicTmp ./ShadedReliefBasic.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports

# NaturalEarthShadedRelief

NE2_HR_LC_SR_W_DR.zip:
	curl --fail -LO https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE2_HR_LC_SR_W_DR.zip

NE2_HR_LC_SR_W_DR.tif: NE2_HR_LC_SR_W_DR.zip
	unzip -oj NE2_HR_LC_SR_W_DR.zip

NE2_HR_LC_SR_W_DR-warped.tif: NE2_HR_LC_SR_W_DR.tif
	gdalwarp -r bilinear -t_srs EPSG:3857 -dstnodata None -co TILED=YES -co BIGTIFF=IF_NEEDED NE2_HR_LC_SR_W_DR.tif NE2_HR_LC_SR_W_DR-warped.tif

NaturalEarthShadedReliefTmp: NE2_HR_LC_SR_W_DR-warped.tif
	gdal2tiles.py --zoom=0-6 --tilesize=1024 --resampling=bilinear --processes=12 --xyz -n NE2_HR_LC_SR_W_DR-warped.tif ./NaturalEarthShadedReliefTmp
	find ./NaturalEarthShadedReliefTmp -name '*.png' | parallel pngquant --ext .png --force {}
	find ./NaturalEarthShadedReliefTmp -name '*.png' | parallel zopflipng -y {} {}
	find ./NaturalEarthShadedReliefTmp \( -name '*.xml' -or -name '*.html' -or -name '*.mapml' -or -name '*.json' \) -delete

NaturalEarthShadedRelief.squashfs: NaturalEarthShadedReliefTmp
	mksquashfs ./NaturalEarthShadedReliefTmp ./NaturalEarthShadedRelief.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports

# GrayEarthShadedRelief

GRAY_HR_SR_OB_DR.zip:
	curl --fail -LO https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_OB_DR.zip

GRAY_HR_SR_OB_DR.tif: GRAY_HR_SR_OB_DR.zip
	unzip -oj GRAY_HR_SR_OB_DR.zip

GRAY_HR_SR_OB_DR-warped.tif: GRAY_HR_SR_OB_DR.tif
	gdalwarp -r bilinear -t_srs EPSG:3857 -dstnodata None -co TILED=YES -co BIGTIFF=IF_NEEDED GRAY_HR_SR_OB_DR.tif GRAY_HR_SR_OB_DR-warped.tif

GrayEarthShadedReliefTmp: GRAY_HR_SR_OB_DR-warped.tif
	gdal2tiles.py --zoom=0-6 --tilesize=1024 --resampling=bilinear --processes=12 --xyz -n GRAY_HR_SR_OB_DR-warped.tif ./GrayEarthShadedReliefTmp
	find ./GrayEarthShadedReliefTmp -name '*.png' | parallel pngquant --ext .png --force {}
	find ./GrayEarthShadedReliefTmp -name '*.png' | parallel zopflipng -y {} {}
	find ./GrayEarthShadedReliefTmp \( -name '*.xml' -or -name '*.html' -or -name '*.mapml' -or -name '*.json' \) -delete

GrayEarthShadedRelief.squashfs: GrayEarthShadedReliefTmp
	mksquashfs ./GrayEarthShadedReliefTmp ./GrayEarthShadedRelief.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports
