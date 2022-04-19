CREATE SCHEMA VDW;

CREATE TABLE VDW.CENSUS_DEMOG (
  CENSUS_YEAR int NOT NULL,
  GEOCODE varchar(15) NOT NULL,
  BLOCK varchar(3) NULL,
  CENSUS_DATA_SRC varchar(26) NULL,
  CHORDS_GEOLEVEL varchar(10) NULL,
  "STATE" varchar(2) NULL,
  COUNTY varchar(3) NULL,
  TRACT varchar(6) NULL,
  BLOCKGP varchar(1) NULL,
  HOUSES_N int NULL,
  RA_NHS_WH decimal(11, 10) NULL,
  RA_NHS_BL decimal(11, 10) NULL,
  RA_NHS_AM decimal(11, 10) NULL,
  RA_NHS_AS decimal(11, 10) NULL,
  RA_NHS_HA decimal(11, 10) NULL,
  RA_NHS_OT decimal(11, 10) NULL,
  RA_NHS_ML decimal(11, 10) NULL,
  RA_HIS_WH decimal(11, 10) NULL,
  RA_HIS_BL decimal(11, 10) NULL,
  RA_HIS_AM decimal(11, 10) NULL,
  RA_HIS_AS decimal(11, 10) NULL,
  RA_HIS_HA decimal(11, 10) NULL,
  RA_HIS_OT decimal(11, 10) NULL,
  RA_HIS_ML decimal(11, 10) NULL,
  HOUSES_OCCUPIED decimal(11, 10) NULL,
  HOUSES_OWN decimal(11, 10) NULL,
  HOUSES_RENT decimal(11, 10) NULL,
  HOUSES_UNOCC_FORRENT decimal(11, 10) NULL,
  HOUSES_UNOCC_FORSALE decimal(11, 10) NULL,
  HOUSES_UNOCC_RENTSOLD decimal(11, 10) NULL,
  HOUSES_UNOCC_SEASONAL decimal(11, 10) NULL,
  HOUSES_UNOCC_MIGRANT decimal(11, 10) NULL,
  HOUSES_UNOCC_OTHER decimal(11, 10) NULL,
  EDUCATION1 decimal(11, 10) NULL,
  EDUCATION2 decimal(11, 10) NULL,
  EDUCATION3 decimal(11, 10) NULL,
  EDUCATION4 decimal(11, 10) NULL,
  EDUCATION5 decimal(11, 10) NULL,
  EDUCATION6 decimal(11, 10) NULL,
  EDUCATION7 decimal(11, 10) NULL,
  EDUCATION8 decimal(11, 10) NULL,
  MEDFAMINCOME int NULL,
  FAMINCOME1 decimal(11, 10) NULL,
  FAMINCOME2 decimal(11, 10) NULL,
  FAMINCOME3 decimal(11, 10) NULL,
  FAMINCOME4 decimal(11, 10) NULL,
  FAMINCOME5 decimal(11, 10) NULL,
  FAMINCOME6 decimal(11, 10) NULL,
  FAMINCOME7 decimal(11, 10) NULL,
  FAMINCOME8 decimal(11, 10) NULL,
  FAMINCOME9 decimal(11, 10) NULL,
  FAMINCOME10 decimal(11, 10) NULL,
  FAMINCOME11 decimal(11, 10) NULL,
  FAMINCOME12 decimal(11, 10) NULL,
  FAMINCOME13 decimal(11, 10) NULL,
  FAMINCOME14 decimal(11, 10) NULL,
  FAMINCOME15 decimal(11, 10) NULL,
  FAMINCOME16 decimal(11, 10) NULL,
  MEDHOUSINCOME int NULL,
  HOUSINCOME1 decimal(11, 10) NULL,
  HOUSINCOME2 decimal(11, 10) NULL,
  HOUSINCOME3 decimal(11, 10) NULL,
  HOUSINCOME4 decimal(11, 10) NULL,
  HOUSINCOME5 decimal(11, 10) NULL,
  HOUSINCOME6 decimal(11, 10) NULL,
  HOUSINCOME7 decimal(11, 10) NULL,
  HOUSINCOME8 decimal(11, 10) NULL,
  HOUSINCOME9 decimal(11, 10) NULL,
  HOUSINCOME10 decimal(11, 10) NULL,
  HOUSINCOME11 decimal(11, 10) NULL,
  HOUSINCOME12 decimal(11, 10) NULL,
  HOUSINCOME13 decimal(11, 10) NULL,
  HOUSINCOME14 decimal(11, 10) NULL,
  HOUSINCOME15 decimal(11, 10) NULL,
  HOUSINCOME16 decimal(11, 10) NULL,
  POV_LT_50 decimal(11, 10) NULL,
  POV_50_74 decimal(11, 10) NULL,
  POV_75_99 decimal(11, 10) NULL,
  POV_100_124 decimal(11, 10) NULL,
  POV_125_149 decimal(11, 10) NULL,
  POV_150_174 decimal(11, 10) NULL,
  POV_175_184 decimal(11, 10) NULL,
  POV_185_199 decimal(11, 10) NULL,
  POV_GT_200 decimal(11, 10) NULL,
  ENGLISH_SPEAKER decimal(11, 10) NULL,
  SPANISH_SPEAKER decimal(11, 10) NULL,
  BORNINUS decimal(11, 10) NULL,
  MOVEDINLAST12MON decimal(11, 10) NULL,
  MARRIED decimal(11, 10) NULL,
  DIVORCED decimal(11, 10) NULL,
  DISABILITY decimal(11, 10) NULL,
  UNEMPLOYMENT decimal(11, 10) NULL,
  UNEMPLOYMENT_MALE decimal(11, 10) NULL,
  INS_MEDICARE decimal(11, 10) NULL,
  INS_MEDICAID decimal(11, 10) NULL,
  HH_NOCAR decimal(11, 10) NULL,
  HH_PUBLIC_ASSISTANCE decimal(11, 10) NULL,
  HMOWNER_COSTS_MORT decimal(11, 10) NULL,
  HMOWNER_COSTS_NO_MORT decimal(11, 10) NULL,
  HOMES_MEDVALUE int NULL,
  PCT_CROWDING decimal(11, 10) NULL,
  FEMALE_HEAD_OF_HH decimal(11, 10) NULL,
  MGR_FEMALE decimal(11, 10) NULL,
  MGR_MALE decimal(11, 10) NULL,
  RESIDENTS_65 decimal(11, 10) NULL,
  SAME_RESIDENCE decimal(11, 10) NULL,
  FAMPOVERTY decimal(11, 10) NULL,
  HOUSPOVERTY decimal(11, 10) NULL,
  ZIP varchar(5) NULL,
  PRIMARY KEY (CENSUS_YEAR, GEOCODE)
);

CREATE TABLE VDW.CENSUS_LOCATION (
  PERSON_ID varchar(255) NOT NULL,
  LOC_START timestamp NOT NULL,
  LOC_END timestamp NULL,
  GEOCODE varchar(15) NULL,
  GEOCODE_BOUNDARY_YEAR numeric(8, 0) NULL,
  GEOLEVEL char(1) NULL,
  LATITUDE decimal(8, 6) NULL,
  LONGITUDE decimal(9, 6) NULL,
  PRIMARY KEY (PERSON_ID, LOC_START),
  FOREIGN KEY (PERSON_ID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);