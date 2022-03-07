#!/bin/bash
. config/env.config
CONFIG_DIR=$(pwd)/config
EXPORT_DIR=$(pwd)/data
FULL_PBF=$EXPORT_DIR/planet-latest.osm.pbf
LAKE_SHP=$EXPORT_DIR/osm_lake_polygon.shp
CENTERLINES_SHP=$EXPORT_DIR/lake_centerline.shp
CENTERLINES_GEOJSON=$EXPORT_DIR/lake_centerline.geojson
CENTERLINES_GPKG=$EXPORT_DIR/lake_centerline.gpkg
MAPPING_YAML=$CONFIG_DIR/lake_centerlines.yaml
IMPOSM3_CACHE_DIR=$EXPORT_DIR/lake_centerlines_cache

if [ ! -d "$EXPORT_DIR" ]; then mkdir -p $EXPORT_DIR; fi
if [ ! -d "$IMPOSM3_CACHE_DIR" ]; then mkdir -p $IMPOSM3_CACHE_DIR; fi

if [ ! -f $CENTERLINES_GEOJSON ]; then
	#Download the planet pdb if it does not exist
	if [ ! -f $FULL_PBF ]; then
		echo "====> : Downloading PBF $FULL_PBF"
		download-osm planet -o $FULL_PBF
	fi
	
	if [ -f $FULL_PBF ]; then
		echo "====> : Importing plantet PBF into postgresql using imposm"
		PG_CONNECT="postgis://$POSTGRES_USER:$POSTGRES_PASS@$POSTGRES_HOST/$POSTGRES_DB"
		DB_SCHEMA="public"

		tools/imposm3/bin/imposm import -connection "$PG_CONNECT" -mapping "$MAPPING_YAML" -overwritecache -cachedir "$IMPOSM3_CACHE_DIR" -read "$FULL_PBF" -dbschema-import="$DB_SCHEMA" -write
		echo "====> : Exporting lake shapes into a shapefile"
		query="SELECT osm_id, ST_SimplifyPreserveTopology(geometry, 100) AS geometry FROM osm_lake_polygon WHERE area > 2 * 1000 * 1000 AND ST_GeometryType(geometry)='ST_Polygon' AND name <> '' ORDER BY area DESC"
		pgsql2shp -f "$LAKE_SHP" -h "$POSTGRES_HOST" -u "$POSTGRES_USER" -P "$POSTGRES_PASS" "$POSTGRES_DB" "$query"
		echo "====> : Creating a lake_centerline.geojson file from the exported shapefile"
		label_centerlines --verbose --max_points=6000 --simplification=0.05 --smooth=1 --max_paths=1 --output_driver GeoJSON "$LAKE_SHP" "$CENTERLINES_GEOJSON"
		#label_centerlines --verbose --max_points=6000 --simplification=0.05 --smooth=1 --max_paths=1 --output_driver GPKG "$LAKE_SHP" "$CENTERLINES_GPKG"
		echo "====> : Creating a lake_centerline.shp file from the exported shapefile"
		ogr2ogr -f "ESRI Shapefile" "$CENTERLINES_SHP" "$CENTERLINES_GEOJSON"
	fi
else
	echo "====> : $CENTERLINES_GEOJSON Already Exists. Please delete it or move it and try again."
fi
