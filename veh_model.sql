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