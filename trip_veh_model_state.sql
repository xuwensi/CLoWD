SELECT "tb_trip"."CHASSIS" AS "CHASSIS",
  "tb_veh_model"."Chassis_No" AS "Chassis_No",
  "tb_trip"."DIS_DIFF" AS "DIS_DIFF",
  "tb_trip"."Daily_Miles" AS "Daily_Miles",
  "tb_trip"."Date_Diff" AS "Date_Diff",
  "tb_veh_model"."OptionCode" AS "OptionCode",
  "tb_trip"."Start_Latitude" AS "Start_Latitude",
  "tb_trip"."Start_Longitude" AS "Start_Longitude",
  "tb_trip"."Trip_Dist" AS "Trip_Dist",
  "tb_trip"."Trip_IDL_Time" AS "Trip_IDL_Time",
  "tb_trip"."Trip_RUN_Time" AS "Trip_RUN_Time",
  "tb_trip"."VIN (OEM_TRIP_START)" AS "VIN (OEM_TRIP_START)",
  "tb_veh_model"."Veh_Model" AS "Veh_Model",
  "tb_veh_model"."VehicleIDNo" AS "VehicleIDNo",
  "tb_trip"."COUNTRY (OEM_TRIP_START)" AS "COUNTRY (OEM_TRIP_START)",
  "tb_trip"."STATE_PROVINCE (OEM_TRIP_START)" AS "STATE_PROVINCE (OEM_TRIP_START)"

FROM (
  SELECT 
    "OEM_TRIP_END"."TOTAL_VEH_DIST" - "OEM_TRIP_START"."TOTAL_VEH_DIST" as "DIS_DIFF",
    "OEM_TRIP_START"."VIN" AS "VIN (OEM_TRIP_START)",
    "OEM_TRIP_END"."TRIP_DIST" AS "Trip_Dist",
    "OEM_TRIP_START"."LATITUDE" as "Start_Latitude",
    "OEM_TRIP_START"."LONGITUDE" as "Start_Longitude",
    "OEM_TRIP_START"."ZIP_CODE" AS "ZIP_CODE (OEM_TRIP_START)",
    "OEM_TRIP_START"."COUNTRY" AS "COUNTRY (OEM_TRIP_START)",
    DATEDIFF(day, "OEM_TRIP_START"."SAMPLE_TM", "OEM_TRIP_END"."SAMPLE_TM") AS "Date_Diff",
    "OEM_TRIP_END"."TRIP_IDL_TM" AS "Trip_IDL_Time",
    "OEM_TRIP_END"."TRIP_RUN_TM" AS "Trip_RUN_Time",
    "DIS_DIFF" / "Date_Diff" AS "Daily_Miles",
    RIGHT("OEM_TRIP_END"."VIN", 6) AS "CHASSIS",
    "OEM_TRIP_START"."STATE_PROVINCE" AS "STATE_PROVINCE (OEM_TRIP_START)"
  
  FROM "FLAT_SCHEMA"."OEM_TRIP_END" "OEM_TRIP_END"
    sample(0.01) seed(1) -- get the sample around 2000 lines
    INNER JOIN "FLAT_SCHEMA"."OEM_TRIP_START" "OEM_TRIP_START" 
  sample(0.01) seed(1)
  ON ("OEM_TRIP_END"."VIN" = "OEM_TRIP_START"."VIN")
  WHERE ("OEM_TRIP_END"."TOTAL_VEH_DIST" - "OEM_TRIP_START"."TOTAL_VEH_DIST" >= 0
      AND "Date_Diff" > 0)
) "tb_trip"
  INNER JOIN (
  SELECT
      "CHASSIS"."ChassisNo" AS "Chassis_No",
      "CHASSIS"."VehicleIDNo" AS "VehicleIDNo",
      "Chassis_Option"."OptionCd" AS "OptionCode",
      "Model_Option"."ModelShortNm" AS "Veh_Model"
  
  FROM "RAW_PROD_DB"."KWC_MSSQL_OPS_KWC"."vw_Chassis_2021Invoiced" "CHASSIS"
      INNER JOIN "RAW_PROD_DB"."KWC_MSSQL_OPS_KWC"."vw_ChassisOption_2021Invoiced" "Chassis_Option" 
      ON ("CHASSIS"."ChassisNo" = "Chassis_Option"."ChassisNo")
      INNER JOIN "RAW_PROD_DB"."KWC_MSSQL_OPS_KWC"."vw_ModelOption" "Model_Option"
      ON ("Chassis_Option"."OptionCd" = "Model_Option"."OptionCd")
) "tb_veh_model" ON ("tb_trip"."CHASSIS" = "tb_veh_model"."Chassis_No")
WHERE "Daily_Miles" > 0
AND "DIS_DIFF" < 500000
AND ("COUNTRY (OEM_TRIP_START)" IS NOT NULL OR "COUNTRY (OEM_TRIP_START)" IN ('United States', 
'Canada', 'Mexico'))
AND "Veh_Model" IN ('T680', 'K270', 'K370') -- only look at truck model T680, K270/370