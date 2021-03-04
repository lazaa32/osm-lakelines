# OpenStreetMap Lake Labels
<img align="right" alt="Lake center lines for labels" width="250" src="lakelines.png" />

Calculate nice centered linestrings for labelling lake polygons.
This repository provides downloadable Shapefiles containing center lines for lake polygons
that you can use to label OSM lake polygons. You can match the OSM ID of the linestrings to your
data source to merge the data.

It is using [ungarj/label_centerlines](https://github.com/ungarj/label_centerlines) from Joachim Ungar to calculate the center lines. This doesn't always result the optimal result and has issues with more complicated lake structures but is sufficient enough for most use cases. Linestrings are not calculated for all lake polygons. Very small polygons, multi polygons and lakes without names are excluded.

[**:open_file_folder: Download lake center lines as GeoJSON, Shapefile, GeoPackage from the releases page**](https://github.com/lukasmartinelli/osm-lakelines/releases/latest).

## Info
This is a dedockerized version of https://github.com/lukasmartinelli/osm-lakelines . It's meant to be used with a pre set up environment like https://github.com/acalcutt/wdb-map-gen

Needs:
openmaptiles-tools ( https://github.com/openmaptiles/openmaptiles-tools)
label_centerline ( https://github.com/acalcutt/label_centerlines )
pgsql2shp ( https://postgis.net/install/ )

## Run Workflow
OSM Planet PBF -> imposm -> PostgreSQL -> Shapefile -> osm_lake_centerline.geojson