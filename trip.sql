SELECT 
  "OEM_TRIP_END"."TOTAL_VEH_DIST" - "OEM_TRIP_START"."TOTAL_VEH_DIST" as "DIS_DIFF",
  "OEM_TRIP_START"."VIN" AS "VIN (OEM_TRIP_START)",
  "OEM_TRIP_END"."TRIP_DIST" AS "Trip_Dist",
  "OEM_TRIP_START"."LATITUDE" as "Start_Latitude",
  "OEM_TRIP_START"."LONGITUDE" as "Start_Longitude",
  "OEM_TRIP_START"."ZIP_CODE" AS "ZIP_CODE (OEM_TRIP_START)",
  DATEDIFF(day, "OEM_TRIP_START"."SAMPLE_TM", "OEM_TRIP_END"."SAMPLE_TM") AS "Date_Diff",
  "OEM_TRIP_END"."TRIP_IDL_TM" AS "Trip_IDL_Time",
  "OEM_TRIP_END"."TRIP_RUN_TM" AS "Trip_RUN_Time",
  "DIS_DIFF" / "Date_Diff" AS "Daily_Miles",
  RIGHT("OEM_TRIP_END"."VIN", 6) AS "CHASSIS"

FROM "FLAT_SCHEMA"."OEM_TRIP_END" "OEM_TRIP_END"
  sample(0.002) seed(1)
  INNER JOIN "FLAT_SCHEMA"."OEM_TRIP_START" "OEM_TRIP_START" 
sample(0.002) seed(1)
ON ("OEM_TRIP_END"."VIN" = "OEM_TRIP_START"."VIN")
WHERE ("OEM_TRIP_END"."TOTAL_VEH_DIST" - "OEM_TRIP_START"."TOTAL_VEH_DIST" >= 0
  AND "Date_Diff" > 0)