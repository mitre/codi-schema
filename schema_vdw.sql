--@(#) script.ddl

/*
  For CODI at North Carolina	
	Updated October 20, 2022 to conform with CODI DM 4.2
	1. Based on a decision to not maintain population statistics in data owner CODI datamarts, 
		the statistics fields are being removed from this table. However the VDW CENSUS_DEMOG 
		table continues to have population statistics. Also, note that in October, 2022 VDW is 
		still in the process of updating their CENSUS_DEMOG table and content.
		This shortened version of CENSUS_DEMOG is required in CODI datamart because it is the 
		target of several other CODI table foreign keys.
	2. Changing field name CHORDS_GEOLEVEL to GEOLEVEL to match latest VDW CENSUS_DEMOG table. 
	
	Udated October 24, 2022 to remove CENSUS_DEMOG because there is no need to have FK relationships 
	to it and based on a decision to not maintain population statistics in each data owner CODI datamart,
	it is no longer needed. CENSUS_LOCATION is meant to have any kind of geocode, 
	even county or state level, if that is all that is known of an individual, and is permissable to be NULL.
	
*/


CREATE SCHEMA VDW;

-- No longer needed.  Population statistics will be handled by the DCC or individual data owners as needed.
/*
CREATE TABLE VDW.CENSUS_DEMOG (
  CENSUS_YEAR int NOT NULL,
  GEOCODE varchar(15) NOT NULL,
  CENSUS_DATA_SRC varchar(26) NULL,
  GEOLEVEL varchar(10) NULL,
  "STATE" varchar(2) NULL,
  COUNTY varchar(3) NULL,
  TRACT varchar(6) NULL,
  PRIMARY KEY (CENSUS_YEAR, GEOCODE)
);
*/

-- All individuals in the demographic table ought to have a record in 
-- census location even if the geocode or any other location 
-- information is unknown. Note that the PK is person_id (a.k.a patid)
-- and loc_start.

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