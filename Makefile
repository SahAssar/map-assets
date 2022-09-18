SHELL := /bin/bash

.PHONY: all clean

all: Fonts.squashfs ShadedReliefBasic.squashfs NaturalEarthShadedRelief.squashfs GrayEarthShadedRelief.squashfs
# Bigger sets: Terrarium.squashfs OMTVector.squashfs OpenAndroMapsWorldPNG.squashfs OpenAndroMapsWorld.squashfs OpenSeaMap.squashfs

clean:
	rm -rf \
		noto-fonts \
		noto-emoji \
		noto-cjk \
		node-fontnik-pkg \
		FontsTmp \
		SR_HR.* \
		SR_HR-warped.tif \
		ShadedReliefBasicTmp \
		NE2_HR_LC_SR_W_DR.* \
		NE2_HR_LC_SR_W_DR-warped.tif \
		NaturalEarthShadedReliefTmp \
		GRAY_HR_SR_OB_DR.* \
		GRAY_HR_SR_OB_DR-warped.tif \
		GrayEarthShadedReliefTmp \
		OpenSeaMapTmp \
		OpenSeaMapTmpRegion \
		OAM-World-1-11-J80.mbtiles \
		OpenAndroMapsWorldTmp \
		OAM-World-1-11-png.sqlitedb \
		OpenAndroMapsWorldPNGTmp \
		planetiler.jar \
		planet.osm.pbf \
		ms-ml-buildings.osc.bz2 \
		fb-ml-roads.osc.bz2 \
		admin.osc.bz2 \
		everything.osm.pbf \
		planet-buildings-roads-admin.osm.pbf \
		output.mbtiles \
		OMTVectorLoopback \
		OMTVectorLoopback/tiles \
		TerrariumTmp


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

# OpenSeaMap

OpenSeaMapTmp:
	mkdir -p OpenSeaMapTmp

OpenSeaMapTmpRegion/%.mbtiles:
	curl --fail -Lo $@ https://ftp.gwdg.de/pub/misc/openstreetmap/openseamap/charts/mbtiles/OSM-OpenCPN2-$*.mbtiles

OpenSeaMapTmpRegion/%: OpenSeaMapTmpRegion/%.mbtiles OpenSeaMapTmp
	mb-util OSM-OpenCPN2-$*.mbtiles $@ --image_format=png
	rsync --progress -avhH $@ ./OpenSeaMapTmp/

OpenSeaMap.squashfs: OpenSeaMapTmp OpenSeaMapTmpRegion/Adria OpenSeaMapTmpRegion/ArabianSea OpenSeaMapTmpRegion/Baltic OpenSeaMapTmpRegion/Bodensee OpenSeaMapTmpRegion/Caribbean OpenSeaMapTmpRegion/Channel OpenSeaMapTmpRegion/EastChineseSea OpenSeaMapTmpRegion/Europa1 OpenSeaMapTmpRegion/Germany-NorthEast OpenSeaMapTmpRegion/GreatLakes OpenSeaMapTmpRegion/GulfOfBengal OpenSeaMapTmpRegion/GulfOfBiscay OpenSeaMapTmpRegion/LakeConstance OpenSeaMapTmpRegion/Lake_Balaton OpenSeaMapTmpRegion/MagellanStrait OpenSeaMapTmpRegion/MediEast OpenSeaMapTmpRegion/MediWest OpenSeaMapTmpRegion/Niederlande-Binnen OpenSeaMapTmpRegion/NorthSea OpenSeaMapTmpRegion/NorthWestPassage OpenSeaMapTmpRegion/NorthernAtlantic OpenSeaMapTmpRegion/Saimaa OpenSeaMapTmpRegion/SouthChineseSea OpenSeaMapTmpRegion/SouthPacificIslands OpenSeaMapTmpRegion/USWestCoast
	rm -rf OpenSeaMapTmp/metadata.json
	mksquashfs ./OpenSeaMapTmp OpenSeaMap.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports

# OpenAndroMapsWorld
OAM-World-1-11-J80.mbtiles:
	curl --fail -LO https://ftp.gwdg.de/pub/misc/openstreetmap/openandromaps/world/OAM-World-1-11-J80.mbtiles

OpenAndroMapsWorldTmp: OAM-World-1-11-J80.mbtiles
	mb-util OAM-World-1-11-J80.mbtiles OpenAndroMapsWorldTmp --image_format=jpg
	rm -rf OpenAndroMapsWorldTmp/metadata.json

OpenAndroMapsWorld.squashfs: OpenAndroMapsWorldTmp
	mksquashfs ./OpenAndroMapsWorldTmp OpenAndroMapsWorld.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports

# OpenAndroMapsWorldPNG

OAM-World-1-11-png.sqlitedb:
	curl --fail -LO https://ftp.gwdg.de/pub/misc/openstreetmap/openandromaps/world/OAM-World-1-11-png.sqlitedb
# TODO: Maybe y needs fixing too, see https://github.com/tarwirdur/mbtiles2osmand/blob/master/mbtiles2osmand.py
# TODO: Maybe the mbutil flipping needs configuration in maplibre (or preventing in mbutil), see https://github.com/mapbox/mbutil/blob/master/mbutil/util.py#L319
# Make the db more like a mbtiles file for compat with mbtiles
	sqlite3 OAM-World-1-11-png.sqlitedb \
		'ALTER TABLE tiles RENAME TO old_tiles;' \
		'CREATE TABLE tiles (zoom_level, tile_column, tile_row, tile_data);' \
		'INSERT INTO tiles (zoom_level, tile_column, tile_row, tile_data) SELECT z as zoom_level, x as tile_column, y as tile_row, image as tile_data FROM old_tiles;' \
		'DROP TABLE old_tiles;' \
		'UPDATE tiles set zoom_level = 17 - zoom_level;' \
		'CREATE TABLE metadata (name, value);'

OpenAndroMapsWorldPNGTmp: OAM-World-1-11-png.sqlitedb
	mb-util OAM-World-1-11-png.sqlitedb OpenAndroMapsWorldPNGTmp --image_format=png
	rm -rf OpenAndroMapsWorldPNGTmp/metadata.json

OpenAndroMapsWorldPNG.squashfs: OpenAndroMapsWorldPNGTmp
	mksquashfs ./OpenAndroMapsWorldPNGTmp OpenAndroMapsWorldPNG.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports

# OMTVector

DAYLIGHT_VERSION="v1.16"
PLANETILER_VERSION="v0.5.0"

planetiler.jar:
	curl --fail -LO "https://github.com/onthegomap/planetiler/releases/download/${PLANETILER_VERSION}/planetiler.jar"
planet.osm.pbf:
	curl --fail -L "https://daylight-map-distribution.s3.us-west-1.amazonaws.com/release/${DAYLIGHT_VERSION}/planet-${DAYLIGHT_VERSION}.osm.pbf" -o planet.osm.pbf
ms-ml-buildings.osc.bz2:
	curl --fail -L "https://daylight-map-distribution.s3.us-west-1.amazonaws.com/release/${DAYLIGHT_VERSION}/ms-ml-buildings-${DAYLIGHT_VERSION}.osc.bz2" -o ms-ml-buildings.osc.bz2
fb-ml-roads.osc.bz2:
	curl --fail -L "https://daylight-map-distribution.s3.us-west-1.amazonaws.com/release/${DAYLIGHT_VERSION}/fb-ml-roads-${DAYLIGHT_VERSION}.osc.bz2" -o fb-ml-roads.osc.bz2
admin.osc.bz2:
	curl --fail -L "https://daylight-map-distribution.s3.us-west-1.amazonaws.com/release/${DAYLIGHT_VERSION}/admin-${DAYLIGHT_VERSION}.osc.bz2" -o admin.osc.bz2
everything.osm.pbf: planet.osm.pbf ms-ml-buildings.osc.bz2 fb-ml-roads.osc.bz2 admin.osc.bz2
	osmium apply-changes "planet.osm.pbf" "ms-ml-buildings.osc.bz2" "fb-ml-roads.osc.bz2" "admin.osc.bz2" -o "everything.osm.pbf"
planet-buildings-roads-admin.osm.pbf: everything.osm.pbf
	osmium renumber "everything.osm.pbf" -o "planet-buildings-roads-admin.osm.pbf"
output.mbtiles: planetiler.jar planet-buildings-roads-admin.osm.pbf
# TODO: make planetiler output uncompressed tiles to disc to avoid the mb-util/rename/gunzip below
	java -Xmx20g \
		-jar planetiler.jar \
		--area=planet \
		--osm_path="planet-buildings-roads-admin.osm.pbf" \
		--bounds=planet \
		--download \
		--download-threads=10 \
		--download-chunk-size-mb=1000 \
		--fetch-wikidata \
		--mbtiles=output.mbtiles \
		--nodemap-type=array \
		--storage=mmap

OMTVectorLoopback:
	dd if=/dev/zero of=OMTVectorLoopback.img bs=100M count=7000
	$(eval LOOPFILE=$(shell losetup --show -fP OMTVectorLoopback.img))
	mkfs.ext4 -b 1024 -i 1024 ${LOOPFILE}
	mkdir -p OMTVectorLoopback
	mount -o loop ${LOOPFILE} ./OMTVectorLoopback

OMTVectorLoopback/tiles: OMTVectorLoopback output.mbtiles
	mb-util output.mbtiles OMTVectorLoopback/tiles --image_format=pbf
	rm OMTVectorLoopback/tiles/metadata.json
	find OMTVectorLoopback/tiles -mindepth 2 -type d -exec rename .pbf .pbf.gz {}/*
	find ./OMTVectorLoopback/tiles -type f -name '*.gz' -exec gunzip {} +

OMTVector.squashfs: OMTVectorLoopback/tiles
	mksquashfs ./OMTVectorLoopback/tiles ./OMTVector.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports
	umount ./OMTVectorLoopback
	losetup -d ${LOOPFILE}

# Terrarium

TerrariumTmp/%:
	mkdir -p $@
	aws s3 sync --no-sign-request s3://elevation-tiles-prod/terrarium/$* TerrariumTmp/$*

Terrarium.squashfs: TerrariumTmp/1 TerrariumTmp/2 TerrariumTmp/3 TerrariumTmp/4 TerrariumTmp/5 TerrariumTmp/6 TerrariumTmp/7 TerrariumTmp/8 TerrariumTmp/9 TerrariumTmp/10 TerrariumTmp/11 TerrariumTmp/12 TerrariumTmp/13
	mksquashfs ./TerrariumTmp Terrarium.squashfs -comp zstd -fstime 0 -all-time 0 -no-xattrs -all-root -info -progress -no-exports
