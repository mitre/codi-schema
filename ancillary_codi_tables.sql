--@(#) script.ddl

/*
  For CODI at North Carolina
  Updated September, 14, 2021 from CODI at Colorado.
	1. Commented out IDENTIFIER tables, to be removed.
	2. Added SDOH_INDICATOR, HOUSEHOLD_LINK to the CODI schema
	3. Added PRIVATE_ADDRESS_HISTORY, PRIVATE_DEMOGRAPHIC to the CDM schema
		Assuming CDM schema is already created.
		
	Updated October 20, 2022 to conform with CODI DM 4.2
	1. Correcting field name underscores to match PCORnet CDM convention (REFERRAL.SOURCE_PROVIDERID, AFFILIATED_PROGRAMID, CURRICULUM_COMPONENT_ID, PROGRAM_ENROLLMENT_ID)
	2. Adding fields to the PRIVATE_ADDRESS_HISTORY, and constraining ADDRESS_USE to required NOT NULL to conform to PCORnet CDM
	3. Adding missing field MODE_TYPE to SESSION
	4. Updating tablename and primary key from ENROLLMENT to PROGRAM_ENROLLMENT
	5. Correcting fieldname LOCATION_GEOCODE which intentionally does not follow FK naming convention.
	6. Correcting fieldname PAT_MIDDLENAME in PRIVATE_DEMOGRAPHIC by removing extra underscore.
	
	Udated October 24, 2022
	1. Removed foreign key LOCATION_GEOCODE to CENSUS_DEMOG from PROGRAM and gave it varchar (15) datatype. CENSUS_DEMOG table has been removed from CODI's VDW. 
	   CENSUS_LOCATION is meant to have any kind of geocode, even county or state level, if that is all that is known of an individual, or no geocode at all.
	2. Changed SDOH_CATEGORY field in SDOH_EVIDENCE_INDICATOR to varchar(29) from char(29)
*/

CREATE SCHEMA CODI;

--The ALERT table contains one record for each distinct kind of alert. Alerts are components of a clinical decision support system (CDS). Given the gamut of possible alerts and the idiosyncrasies of CDS implementations, CODI only captures a prose description of the intended function of the alert. Only obesity- or weight-related alerts should be captured for CODI.
CREATE TABLE CODI.ALERT
(
	--A description of the purpose of the alert.
	ALERT_PURPOSE varchar NOT NULL,
	--A description of the conditions under which the alert triggers.
	ALERT_TRIGGER varchar NOT NULL,
	--A description of how the alert is presented to the user.
	ALERT_FORM varchar NOT NULL,
	ALERTID varchar,
	PRIMARY KEY(ALERTID)
);

--The FAMILY_HISTORY table stores information regarding an individual's family history of disease. A separate record is created for each report of a condition that a family member has. Absence of a record in this table is not indicative the absence of a condition.
--This information is intended to be pulled from the patient's record, not by linking to a family member's medical record.
CREATE TABLE CODI.FAMILY_HISTORY
(
	--A condition that the patient has a family history of.
	CONDITION varchar (18) NOT NULL,
	--A date the family history of the condition was reported.
	REPORT_DATE date NULL,
	--A condition coding system from which the condition code is drawn.
	CONDITION_TYPE char (2) NOT NULL, 
	--An indication of which relative has the condition
	RELATIONSHIP varchar (9) NULL,
	FAMILY_HISTORY_ID varchar,
	PATID varchar NOT NULL,
	CHECK(CONDITION_TYPE in ('09', '10', '11', 'SM', 'NI', 'UN', 'OT')),
	PRIMARY KEY(FAMILY_HISTORY_ID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The PREGNANCY table contains one record for each pregnancy.
CREATE TABLE CODI.PREGNANCY
(
	--A date of the parent's last menstrual period.
	LAST_MENSES_DATE date NULL,
	--An estimated date of delivery.
	ESTIMATED_DELIVERY_DATE date NULL,
	--An actual date of delivery.
	DELIVERY_DATE date NULL,
	--A number of fetuses involved in this pregnancy.
	FETUS_COUNT integer NULL,
	--A date of the parent's first prenatal healthcare visit.
	FIRST_PRENATAL_DATE date NULL,
	--True if the parent took dietary supplements during pregnancy.
	DIETARY_SUPPLEMENT boolean NULL,
	--A number of cigarettes the parent smoked (per day) before becoming pregnant.
	CIGARETTE_PRE float NULL,
	--A number of cigarettes the parent smoked (per day) during the first trimester.
	CIGARETTE_FIRST float NULL,
	--A number of cigarettes the parent smoked (per day) during the second trimester.
	CIGARETTE_SECOND float NULL,
	--A number of cigarettes the parent smoked (per day) during the last trimester.
	CIGARETTE_LAST float NULL,
	--A number of cigarettes the parent smoked (per day) postpartum.
	CIGARETTE_POST float NULL,
	--A number of alcoholic drinks the parent consumed (per day) before becoming pregnant.
	DRINKS_PRE float NULL,
	--A number of alcoholic drinks the parent consumed (per day) during the last trimester.
	DRINKS_LAST float NULL,
	--A number of times the parent has been pregnant, including this pregnancy.
	GRAVIDA integer NULL,
	--A number of viable pregnancies that had multiple fetuses.
	PARA integer NULL,
	--A measure of the parent's weight (in pounds) before becoming pregnant.
	PRE_PREGNANCY_WT float NULL,
	--A measure of the parent's body mass index before becoming pregnant.
	PRE_PREGNANCY_BMI float NULL,
	--A measure of the parent's weight (in pounds) at delivery.
	DELIVERY_WT float NULL,
	PREGNANCYID varchar,
	DELIVERY_PROCEDUREID varchar,
	PATID varchar NOT NULL,
	PRIMARY KEY(PREGNANCYID),
	UNIQUE(DELIVERY_PROCEDUREID),
	FOREIGN KEY(DELIVERY_PROCEDUREID) REFERENCES CDM.PROCEDURES (PROCEDURESID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The PROGRAM table contains one record for each distinct program. A program comprises a collection of interventions intended to produce a particular outcome.
CREATE TABLE CODI.PROGRAM
(
	--A name of the program (e.g., Girls on the Run).
	PROGRAM_NAME varchar NOT NULL,
	--A description of the program.
	PROGRAM_DESCRIPTION varchar NULL,
	--True if the aim of the program includes improving nutrition.
	AIM_NUTRITION boolean NULL,
	--True if the aim of the program includes improving physical activity.
	AIM_ACTIVITY boolean NULL,
	--True if the aim of the program includes improving weight status.
	AIM_WEIGHT boolean NULL,
	--A total amount of time (in hours) an individual should spend in the program. This field should equal DURATION x FREQUENCY x LENGTH (weeks x sessions/week x hours/session).
	PRESCRIBED_TOTAL_DOSE float NULL,
	--A measure of the time (in weeks) from start to finish.
	PRESCRIBED_PROGRAM_DURATION float NULL,
	--A number of sessions delivered each week.
	PRESCRIBED_SESSION_FREQUENCY float NULL,
	--A number of hours delivered each session.
	PRESCRIBED_SESSION_LENGTH float NULL,
	--A primary location at which this program's sessions are administered, expressed as an address.
	LOCATION_ADDRESS varchar NULL,
	--A latitude of the corresponding address location.
	LOCATION_LATITUDE numeric (8) NULL,
	--A latitude of the corresponding address location.
	LOCATION_LONGITUDE numeric (8) NULL,
	--A primary location at which this program's sessions are administered, expressed as a geocode.
	LOCATION_GEOCODE varchar (15) NULL,
	--A census year for which the corresponding geocode location applies.
	LOCATION_BOUNDARY_YEAR numeric (8) NULL,
	--A numeric estimate of the percentage of all sessions missing from the SESSION table (based on intended dose) for this program; 0% indicates a belief that the session information is fully populated.
	SESSION_OMISSION_PERCENT float NULL,
	--A description of the circumstances under which session information for this program is missing; this field is required when the omission percent is greater than 0%.
	SESSION_OMISSION_DESCRIPTION varchar NULL,
	--True if session information for this program is systematically missing (e.g., because only half of the sessions are documented in an EHR).
	SESSION_OMISSION_SYSTEMATIC boolean NULL,
	--A setting in which the program is offered (clinical or community).
	PROGRAM_SETTING char (2) NULL,
	--A specificity of the geocode location.
	--This can be assessed using logic that considers the length of the GEOCODE value (2 characters for state; 5 characters for county; 11 characters for census tract).
	LOCATION_GEOLEVEL char (1) NULL,
	PROGRAMID varchar,
	AFFILIATED_PROGRAMID varchar NULL,
	CHECK(PROGRAM_SETTING in ('CL', 'CO')),
	CHECK(LOCATION_GEOLEVEL in ('B', 'G', 'T', 'C', 'Z', 'P', 'U')),
	PRIMARY KEY(PROGRAMID),
	UNIQUE(AFFILIATED_PROGRAMID),
	--The PROGRAM table contains one record for each distinct program. A program comprises a collection of interventions intended to produce a particular outcome.
	FOREIGN KEY(AFFILIATED_PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAMID)
);

--The REFERRAL table contains one record for each outgoing or incoming referral.
CREATE TABLE CODI.REFERRAL
(
	--A date the referral was made.
	REFERRAL_DATE date NOT NULL,
	--An indication of whether the referral was incoming or outgoing.
	DIRECTION char (1) NOT NULL,
	--A final disposition of the referral.
	REFERRAL_STATUS char (2) NULL,
	--An indication of whether prior authorization was required for the referral.
	REFERRAL_PRIOR_AUTH char (2) NULL,
	--An organization that initiated the referral.
	SOURCE_ORGANIZATION varchar (6) NOT NULL,
	--An organization to which the referral was sent.
	DESTINATION_ORGANIZATION varchar (6) NOT NULL,
	--A clinical specialty for which the patient is being referred.
	DESTINATION_SPECIALTY varchar (10) NULL,
	REFERRALID varchar,
	SOURCE_PROVIDER_ID varchar,
	ENCOUNTERID varchar,
	PATID varchar NOT NULL,
	CHECK(DIRECTION in ('I', 'O')),
	CHECK(REFERRAL_STATUS in ('A', 'D', 'NI', 'UN', 'OT')),
	CHECK(REFERRAL_PRIOR_AUTH in ('Y', 'N', 'R', 'NI', 'UN', 'OT')),
	PRIMARY KEY(REFERRALID),
	FOREIGN KEY(SOURCE_PROVIDERID) REFERENCES CDM.PROVIDER (PROVIDERID),
	FOREIGN KEY(ENCOUNTERID) REFERENCES CDM.ENCOUNTER (ENCOUNTERID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The LINK table contains one record for each person in the demographics table for each iteration of record linkage. Each iteration establishes a new LINKID for each person.
CREATE TABLE CODI.LINK
(
	--An iteration of the record linkage process.
	LINK_ITERATION int NOT NULL,
	LINKID varchar,
	PATID varchar NOT NULL,
	PRIMARY KEY(LINKID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);
-- A household link represents a connection between people (identified anonymously) who are determined to be members  
-- of the same household because they have the same physical address at the time the household link is established. 
CREATE TABLE CODI.HOUSEHOLD_LINK
(
	--A unique identifier for a household
	HOUSEHOLDID varchar NOT NULL,
	-- An iteration of the household record linkage process.
	LINK_ITERATION int NOT NULL,
	PATID varchar NOT NULL,
	PRIMARY KEY(HOUSEHOLDID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--A signal conveying the existence of information about social circumstance(s) considered to be a determinant of health for an individual patient or program participant. The information may come from an administered SDOH screening or diagnosis or problem associated with the individual and is relevant to one of the SDOH categories (e.g., FOOD_DOMAIN, FINANCIAL_DOMAIN). The purpose of the evidence indicator is to provide a short-cut for knowing if relevant information exists and does not indicate whether a social risk exists. 
CREATE TABLE CODI.SDOH_EVIDENCE_INDICATOR
(
	--A date on which a data owner, partner, or researcher has made an assertion indicating the presence of SDOH evidence. This date corresponds to the data partner's most recent determination of available evidence and does not necessarily match submission dates of any of the SDOH evidence. CODI is not expected to maintain a history of assertions, only one assertion based on the data partner's supplied evidence. 
	EVIDENCE_DATE date NOT NULL,
	--A name of a table in the CODI schema in which there is some evidence pertaining to the CODI SDOH indicator category. The evidence may be a screening response (in PRO_CM), or a reported problem (in CONDITION or DIAGNOSIS), or some other information stored in a CODI table. 
	EVIDENCE_TABLE_NAME varchar NULL,
	--For indicator assertions without CODI data evidence; an explanation for the assertion. 
	EVIDENCE_EXPLANATION varchar NULL,
	--An identifier for a specific row in the table referenced in the EVIDENCE_TABLE_NAME that contains evidence of a potential social determinant.
	EVIDENCE_ROWID varchar NULL,
	--A social topic area pertaining to circumstances which can determine health outcomes for an individual.
	SDOH_CATEGORY varchar (29) NOT NULL, -- changed from char to varchar
	SDOH_EVIDENCE_INDICATOR_ID varchar,
	PATID varchar NOT NULL,
	CHECK(SDOH_CATEGORY in ('FOOD_DOMAIN', 'HOUSING_STABILITY_DOMAIN', 'HOUSING_ADEQUACY_DOMAIN', 'TRANSPORTATION_DOMAIN', 'INTERPERSONAL_VIOLENCE_DOMAIN', 'FINANCIAL_DOMAIN', 'MATERIAL_NECESSESITIES_DOMAIN', 'EMPLOYMENT_DOMAIN', 'HEALTH_INSURANCE_DOMAIN', 'ELDER_CARE_DOMAIN', 'EDUCATION_DOMAIN', 'STRESS_DOMAIN', 'VETERAN_DOMAIN')),
	PRIMARY KEY(SDOH_EVIDENCE_INDICATOR_ID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The ASSET_DELIVERY table contains one record for each contiguous period of time during which a person consistently receives assets. An asset is a resource transferred by a program to an individual.
CREATE TABLE CODI.ASSET_DELIVERY
(
	--A date the asset delivery began.
	DELIVERY_START_DATE date NULL,
	--A date the asset delivery ended.
	DELIVERY_END_DATE date NULL,
	--A number of times an asset is delivered each unit of time.
	DELIVERY_FREQ float NULL,
	--An intended purpose for the use of a monetary asset (e.g., health insurance or food).
	ASSET_PURPOSE char (2) NULL,
	--A unit of time used to describe how often an asset is delivered. For example, an asset delivered twice a week has a frequency of 2 and a unit of Weekly. An asset delivered every other week has a frequency of 0.5 and a unit of Weekly.
	DELIVERY_FREQ_UNIT char (1) NULL,
	ASSET_DELIVERY_ID varchar,
	PATID varchar NOT NULL,
	PROGRAMID varchar NOT NULL,
	CHECK(ASSET_PURPOSE in ('CC', 'FO', 'HI', 'TR', 'NI', 'UN', 'OT')),
	CHECK(DELIVERY_FREQ_UNIT in ('O', 'D', 'W', 'M', 'Y')),
	PRIMARY KEY(ASSET_DELIVERY_ID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	FOREIGN KEY(PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAMID)
);

--A curriculum component is a standard element of a program. A program can comprise a fixed curriculum with a predefined endpoint and an enumerated set of standard sessions. Alternatively, a program can comprise a recurring curriculum with no endpoint and a set of standard sessions that recur with some frequency.
CREATE TABLE CODI.CURRICULUM_COMPONENT
(
	--An ordinal used to establish a total ordering on the sessions within a fixed curriculum.
	SESSION_INDEX int NULL,
	--A number of times a session is administered each unit of time.
	SESSION_FREQ float NULL,
	--A measure of the amount of time sessions associated with this curriculum are expected to last.
	DOSE float NULL,
	--A unit of time used to describe how often a session is administered. For example, a session administered twice a week has a frequency of 2 and a unit of Weekly. A session administered every other week has a frequency of 0.5 and a unit of Weekly.
	SESSION_FREQ_UNIT char (1) NULL,
	--True if the sessions associated with this curriculum include any assessment of lifestyle behaviors related to obesity, such as physical activity, nutrition, screen time, or sleep.
	SCREENING char (2) NULL,
	--True if the sessions associated with this curriculum include any advice or direction regarding lifestyle related to obesity, such as physical activity, nutrition, screen time, or sleep.
	COUNSELING char (2) NULL,
	--True if the sessions associated with this curriculum include performing at least moderate physical activity; moderate activity requires a moderate amount of effort (5-6 on a scale of 0 to 10) and noticeably accelerates the heart rate and breathing.
	INTERVENTION_ACTIVITY char (2) NULL,
	--True if the sessions associated with this curriculum include an activity designed to improve nutrition.
	INTERVENTION_NUTRITION char (2) NULL,
	--True if the sessions associated with this curriculum include a navigational service to access benefits or to overcome barriers to care.
	INTERVENTION_NAVIGATION char (2) NULL,
	CURRICULUM_COMPONENT_ID varchar,
	PROGRAMID varchar NOT NULL,
	CHECK(SESSION_FREQ_UNIT in ('O', 'D', 'W', 'M', 'Y')),
	CHECK(SCREENING in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_NAVIGATION in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_NUTRITION in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_ACTIVITY in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(COUNSELING in ('Y', 'N', 'NI', 'UN', 'OT')),
	PRIMARY KEY(CURRICULUM_COMPONENT_ID),
	FOREIGN KEY(PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAMID)
);

--The ENROLLMENT table contains one record for each person who enrolls in a program.
CREATE TABLE CODI.PROGRAM_ENROLLMENT
(
	--A date on which the enrollment was performed.
	ENROLLMENT_DATE date NULL,
	--A date on which the individual who enrolled completed the program.
	COMPLETION_DATE date NULL,
	--A description of the circumstances under which an individual ended their participation in the program. For example, an individual might complete a program successfully, they might drop out, or they might move to a different state.
	DISPOSITION_DESCRIPTION varchar NULL,
	PROGRAM_ENROLLMENT_ID varchar,
	PATID varchar NOT NULL,
	PROGRAMID varchar NOT NULL,
	PRIMARY KEY(PROGRAM_ENROLLMENT_ID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	FOREIGN KEY(PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAMID)
);
--The PREGNANCY_OUTCOME table contains one record for each fetus resulting from the pregnancy.
CREATE TABLE CODI.PREGNANCY_OUTCOME
(
	--A number of weeks of gestation.
	GESTATION_WEEKS float NULL,
	--A measure of the child's weight (in pounds) at birth.
	BIRTH_WT float NULL,
	--A measure of the child's length (in inches) at birth.
	BIRTH_HT float NULL,
	--A measure of the child's weight (in pounds) when discharged.
	DISCHARGE_WT float NULL,
	--A date on which the child was discharged.
	DISCHARGE_DATE date NULL,
	--True if the child lives with an individual who smokes.
	HAS_SMOKER_IN_HOUSE boolean NULL,
	--True if the child has ever been breastfed.
	EVER_BREASTFED boolean NULL,
	--A number of times (per day) the child was breastfed, on average.
	BREAST_FEEDING_FREQ float NULL,
	--An age of the child (in weeks) when breastfeeding stopped.
	BREAST_FEEDING_STOPPED_AGE float NULL,
	--A reason the child stopped breastfeeding. [TODO: Get the codes from WIC and decide if we're going to use those codes.]
	BREAST_FEEDING_STOPPED_REASON varchar NULL,
	PREGNANCY_OUTCOME_ID varchar,
	CHILDID varchar,
	PARENTID varchar NOT NULL,
	PRIMARY KEY(PREGNANCY_OUTCOME_ID),
	UNIQUE(CHILDID),
	FOREIGN KEY(CHILDID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	FOREIGN KEY(PARENTID) REFERENCES CODI.PREGNANCY (PREGNANCYID)
);

--The SESSION table contains one record for each session. A session is a specific point in time where an individual or family is involved in programming that focuses on the prevention or intervention of chronic disease, or chronic-related comorbidities.
--In a clinical setting, a session corresponds to a visit. There may be multiple visits in a single encounter. The ENCOUNTERID field is required for clinical sessions.
--In a community setting, a session corresponds to one component of a program. The PROGRAMID field is required for sessions that are components of a program.
--At least one of those fields should be present in every case.
CREATE TABLE CODI.SESSION
(
	--A date on which the session was conducted.
	SESSION_DATE date NULL,
	-- An indication of the way the session was delivered (e.g., individual, group, phone).
	SESSION_MODE char(1) NULL,
	--A measure of the amount of time spent on this encounter. Researchers can compare the total dose to the prescribed total dose to assess the extent to which an individual completed a program.
	DOSE float NULL,
	--True if the session included any assessment of lifestyle behaviors related to obesity, such as physical activity, nutrition, screen time, or sleep.
	SCREENING char (2) NULL,
	--True if the session included any advice or direction regarding lifestyle related to obesity, such as physical activity, nutrition, screen time, or sleep.
	COUNSELING char (2) NULL,
	--True if the session included performing at least moderate physical activity; moderate activity requires a moderate amount of effort (5-6 on a scale of 0 to 10) and noticeably accelerates the heart rate and breathing.
	INTERVENTION_ACTIVITY char (2) NULL,
	--True if the session included an activity designed to improve nutrition.
	INTERVENTION_NUTRITION char (2) NULL,
	--True if the session included a navigational service to access benefits or to overcome barriers to care.
	INTERVENTION_NAVIGATION char (2) NULL,
	SESSIONID varchar,
	CURRICULUM_COMPONENT_ID varchar,
	PROVIDERID varchar,
	PROGRAMID varchar,
	PATID varchar NOT NULL,
	ENCOUNTERID varchar,
	CHECK(SCREENING in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(COUNSELING in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_ACTIVITY in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_NUTRITION in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_NAVIGATION in ('Y', 'N', 'NI', 'UN', 'OT')),
	CHECK(SESSION_MODE in ('I', 'G', 'W', 'T', 'M')),
	PRIMARY KEY(SESSIONID),
	FOREIGN KEY(CURRICULUM_COMPONENT_ID) REFERENCES CODI.CURRICULUM_COMPONENT (CURRICULUM_COMPONENT_ID),
	FOREIGN KEY(PROVIDERID) REFERENCES CDM.PROVIDER (PROVIDERID),
	FOREIGN KEY(PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAMID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	FOREIGN KEY(ENCOUNTERID) REFERENCES CDM.ENCOUNTER (ENCOUNTERID)
);

--The SESSION_ALERT table contains one record for each alert that triggered during a session.
CREATE TABLE CODI.SESSION_ALERT
(
	--A date that an alert triggered.
	ALERT_DATE date NULL,
	--A time that an alert triggered.
	ALERT_TIME time NULL,
	SESSION_ALERT_ID varchar,
	SESSIONID varchar NOT NULL,
	ALERTID varchar NOT NULL,
	PRIMARY KEY(SESSION_ALERT_ID),
	FOREIGN KEY(SESSIONID) REFERENCES CODI.SESSION (SESSIONID),
	FOREIGN KEY(ALERTID) REFERENCES CODI.ALERT (ALERTID)
);

--Protected table that is intended to provide a standardized representation of the personally-identifiable 
-- information (PII) that is needed to support local activities related to record linkage. Contains one record per PATID.
CREATE TABLE CDM.PRIVATE_DEMOGRAPHIC
(
	PATID varchar NOT NULL,
	PAT_FIRSTNAME VARCHAR (255) NOT NULL,
	PAT_MIDDLENAME VARCHAR (255) NULL,
	PAT_LASTNAME VARCHAR (255) NOT NULL,
	PAT_MAIDENNAME VARCHAR (255) NULL,
	BIRTH_DATE date NULL,
	--Sex assigned at birth.
	SEX char (2) NULL,
	RACE char (2) NULL,
	HISPANIC char (2) NULL,
	--Primary e-mail address for the patient.
	PRIMARY_EMAIL VARCHAR (255) NULL,
	--Primary phone number for the patient (if known). 10-digit US phone number.
	PRIMARY_PHONE CHAR(10) NULL,
	CHECK (SEX in ('A', 'F', 'M', 'NI', 'UN', 'OT')),
	CHECK (RACE in ('01', '02', '03','04', '05', '06', '07', 'NI', 'UN', 'OT')),
	CHECK (HISPANIC in ('Y', 'N', 'R', 'NI', 'UN', 'OT')),
	PRIMARY KEY(PATID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

-- Protected table that can be used to store elements of a patient’s address that are considered personal health information (PHI).
CREATE TABLE CDM.PRIVATE_ADDRESS_HISTORY
(
	ADDRESSID varchar NOT NULL,
	PATID varchar NOT NULL,
	-- Primary address line (e.g., street name and number)
	ADDRESS_STREET varchar (255) NULL,
	-- Remaining address details (e.g., suite, post office box, other details)
	ADDRESS_DETAIL varchar (255) NULL,
	ADDRESS_CITY varchar (255) NULL,
	ADDRESS_ZIP5 char(5) NULL,
	ADDRESS_STATE char(2) NULL,
	ADDRESS_TYPE char(2) NOT NULL,
	ADDRESS_PREFERRED char(2) NOT NULL,
	ADDRESS_PERIOD_END date NULL,
	ADDRESS_PERIOD_START date NULL,
	ADDRESS_USE char(2) NOT NULL,
	ADDRESS_ZIP9 char(9) NULL,
	RAW_ADDRESS_TEXT varchar NULL,
	CHECK (ADDRESS_STATE in ('AL','AK','AS','AZ','AR','CA',
	'CO','CT','DE','DC','FM','FL','GA','GU','HI','ID',
	'IL','IN','IA','KS','KY','LA','ME','MH','MD','MA','MI','MN','MS',
	'MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','MP','OH','OK',
	'OR','PW','PA','PR','RI','SC','SD','TN','TX','UT','VT','VI','VA',
	'WA','WV','WI','WY','AE','AP','AA','NI','UN','OT')),
	CHECK(ADDRESS_TYPE in('PO','PH','NI','UN','OT')),
	CHECK(ADDRESS_PREFERRED in('Y', 'N', 'R', 'NI', 'UN', 'OT')),
	CHECK(ADDRESS_USE in ('HO', 'WO', 'TP', 'OL', 'NI', 'UN', 'OT')),
	PRIMARY KEY(ADDRESSID),
	FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);