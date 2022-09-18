# map-assets

Some map-assets packaged in squashfs format for easy moving/mounting and serving by any webserver. All raster tiles are optimized with pngquant & zopflipng.

## Smaller asset bundles

- Fonts.squashfs: SDF fonts for use in maplibre/mapbox, includes NotoSans for good coverage of international scripts
- ShadedReliefBasic.squashfs: Shaded Relief background layer - <https://www.naturalearthdata.com/downloads/10m-raster-data/10m-shaded-relief/>
- NaturalEarthShadedRelief.squashfs: Natural Earth II background layers - <https://www.naturalearthdata.com/downloads/10m-raster-data/10m-natural-earth-2/>
- GrayEarthShadedRelief.squashfs: Gray Earth background layer - <https://www.naturalearthdata.com/downloads/10m-raster-data/10m-gray-earth/>

Download from the latest github release. Building these via github actions is possible but takes a long time. See the workflow in .github/workflows/release.yml for how.

## Larger asset bundles

These are too big to be uploaded to github (over 2GB), but can be built with the makefile. Will upload somewhere else and add links later.

- Terrarium.squashfs: Mapzens elevation tiles, just downloaded from AWS open data and packaged into squashfs.
  - Requires AWS CLI
- OMTVector.squashfs: Vector tiles, made with planettiler from the daylight OSM distro with FB & MS'es added roads and buildings. Uncompressed to allow for brotli compression or uncompressed output.
  - Requires jdk, mbutil
- OpenAndroMapsWorldPNG.squashfs: The higher quality tiles from openandromaps. Still pretty untested
  - Requires mbutil
- OpenAndroMapsWorld.squashfs: Standard quality from openandromaps
  - Requires mbutil
- OpenSeaMap.squashfs: All available openseamap reigons combined. Seems to be missing every second zoom layer
  - Requires mbutil
