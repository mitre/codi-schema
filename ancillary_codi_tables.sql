--@(#) script.ddl

CREATE SCHEMA CODI;

--The ALERT table contains one record for each distinct kind of alert. Alerts are components of a clinical decision support system (CDS). Given the gamut of possible alerts and the idiosyncrasies of CDS implementations, CODI only captures a prose description of the intended function of the alert. Only obesity- or weight-related alerts should be captured for CODI.
CREATE TABLE CODI.ALERT
(
	--A description of the purpose of the alert.
	ALERT_PURPOSE varchar (255) NOT NULL,
	--A description of the conditions under which the alert triggers.
	ALERT_TRIGGER varchar (255) NOT NULL,
	--A description of how the alert is presented to the user.
	ALERT_FORM varchar (255) NOT NULL,
	ALERT_ID varchar,
	PRIMARY KEY(ALERT_ID)
);

--The FAMILY_HISTORY table stores information regarding a child's family history of disease. A separate record is created for each report of a condition that a family member has. Absence of a record in this table is not indicative the absence of a condition.
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
	CONSTRAINT fk_PAT FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The IDENTIFIER table contains one row for each unique combination of identifying information. The intention is that this table can be stored separately from research data because it has PII. The exact configuration will be determined experimentally. These experiments will determine which attributes to include and how those attributes will be normalized by each site (prior to hashing).
CREATE TABLE CODI.IDENTIFIER
(
	--A given name for the child.
	GIVEN_NAME varchar (255) NULL,
	--A family name for the child.
	FAMILY_NAME varchar (255) NULL,
	--A middle initial for the child.
	MIDDLE_INITIAL varchar (255) NULL,
	--An insurance number for the child.
	INSURANCE_NUMBER varchar (255) NULL,
	--A given name for a parent of the child.
	PARENT_GIVEN_NAME varchar (255) NULL,
	--A family name for a parent of the child.
	PARENT_FAMILY_NAME varchar (255) NULL,
	--An address for the child, including number/name/unit (i.e., the information sometimes referred to as street line 1 and street line 2).
	HOUSEHOLD_STREET_ADDRESS varchar (255) NULL,
	--A ZIP code for the child.
	HOUSEHOLD_ZIP varchar (255) NULL,
	--A phone number for the child.
	HOUSEHOLD_PHONE varchar (255) NULL,
	--An email address for the child.
	HOUSEHOLD_EMAIL varchar (255) NULL,
	IDENTIFIER_ID varchar,
	PATID varchar NOT NULL,
	PRIMARY KEY(IDENTIFIER_ID),
	CONSTRAINT fk_PAT FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The PROGRAM table contains one record for each distinct program. A program comprises a collection of interventions intended to produce a particular outcome.
CREATE TABLE CODI.PROGRAM
(
	--A name of the program (e.g., Girls on the Run).
	PROGRAM_NAME varchar (255) NOT NULL,
	--A description of the program.
	PROGRAM_DESCRIPTION varchar (255) NULL,
	--True if the aim of the program includes improving nutrition.
	AIM_NUTRITION boolean NULL,
	--True if the aim of the program includes improving physical activity.
	AIM_ACTIVITY boolean NULL,
	--True if the aim of the program includes improving weight status.
	AIM_WEIGHT boolean NULL,
	--A total amount of time (in hours) a child should spend in the program. This field should equal DURATION x FREQUENCY x LENGTH (weeks x sessions/week x hours/session).
	PRESCRIBED_TOTAL_DOSE float NULL,
	--A measure of the time (in weeks) from start to finish.
	PRESCRIBED_PROGRAM_DURATION float NULL,
	--A number of sessions delivered each week.
	PRESCRIBED_SESSION_FREQUENCY float NULL,
	--A number of hours delivered each session.
	PRESCRIBED_SESSION_LENGTH float NULL,
	--A setting in which the program is offered (clinical or community).
	PROGRAM_SETTING char (2) NULL,
	--An indication of the way program was delivered (e.g., individual, group, phone).
	PROGRAM_MODE char (1) NULL,
	PROGRAM_ID varchar,
	CHECK(PROGRAM_SETTING in ('CL', 'CO')),
	CHECK(PROGRAM_MODE in ('I', 'G', 'W', 'T', 'M')),
	PRIMARY KEY(PROGRAM_ID)
);

--The REFERRAL table contains one record for each outgoing or incoming referral.
CREATE TABLE CODI.REFERRAL
(
	--A date the referral was made.
	REFERRAL_DATE date NOT NULL,
	--An indication of whether the referral was incoming or outgoing.
	DIRECTION char (1) NOT NULL,
	--An organization that initiated the referral.
	SOURCE_ORGANIZATION varchar (6) NOT NULL,
	--An organization to which the referral was sent.
	DESTINATION_ORGANIZATION varchar (6) NOT NULL,
	--A clinical specialty for which the patient is being referred.
	DESTINATION_SPECIALTY varchar (10) NULL,
	REFERRAL_ID varchar,
	PATID varchar NOT NULL,
	ENCOUNTERID varchar,
	SOURCE_PROVIDERID varchar,
	CHECK(DIRECTION in ('I', 'O')),
	PRIMARY KEY(REFERRAL_ID),
	CONSTRAINT fk_PAT FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	CONSTRAINT fk_ENCOUNTER FOREIGN KEY(ENCOUNTERID) REFERENCES CDM.ENCOUNTER (ENCOUNTERID),
	CONSTRAINT fk_SOURCE_PROVIDER FOREIGN KEY(SOURCE_PROVIDERID) REFERENCES CDM.PROVIDER (PROVIDERID)
);

--The ASSET_DELIVERY contains one record for each period of time during which a person receives assets. An asset is a resource transferred by a program to an individual.
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
	PROGRAMID varchar NOT NULL,
	PATID varchar NOT NULL,
	CHECK(ASSET_PURPOSE in ('CC', 'FO', 'HI', 'TR', 'NI', 'UN', 'OT')),
	CHECK(DELIVERY_FREQ_UNIT in ('O', 'D', 'W', 'M', 'Y')),
	PRIMARY KEY(ASSET_DELIVERY_ID),
	CONSTRAINT fk_PROGRAM FOREIGN KEY(PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAM_ID),
	CONSTRAINT fk_PAT FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID)
);

--The IDENTITY_HASH_BUNDLE table contains one record for each record in the IDENTIFIER table. By storing the hash values into their own table, this table can appear in a data warehouse instance that eschews PII. 
CREATE TABLE CODI.IDENTITY_HASH_BUNDLE
(
	--A hash value for configuration 1 of identifier values.
	HASH_1 varchar (255) NOT NULL,
	--A hash value for configuration k of identifier values.
	HASH_k varchar (255) NOT NULL,
	IDENTITY_HASH_BUNDLE_ID varchar,
	PATID varchar NOT NULL,
	IDENTIFIERID varchar NOT NULL,
	PRIMARY KEY(IDENTITY_HASH_BUNDLE_ID),
	UNIQUE(IDENTIFIERID),
	CONSTRAINT fk_PAT FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	CONSTRAINT fk_IDENTIFIER FOREIGN KEY(IDENTIFIERID) REFERENCES CODI.IDENTIFIER (IDENTIFIER_ID)
);

--The SESSION table contains one record for each session. A session is a specific point in time where a child/family is involved in programming that focuses on obesity, obesity prevention, healthy eating, or active living.
--In a clinical setting, a session corresponds to a visit. There may be multiple visits in a single encounter. The ENCOUNTERID field is required for clinical sessions.
--In a community setting, a session corresponds to one component of a program. The PROGRAMID field is required for sessions that are components of a program.
--At least one of those fields should be present in every case.
CREATE TABLE CODI.SESSION
(
	--A date on which the session was conducted.
	SESSION_DATE date NULL,
	--A measure of the amount of time spent on this encounter. Researchers can compare the total dose to the prescribed total dose to assess the extent to which a child completed a program.
	DOSE float NULL,
	--A level of care associated with a clinical session (e.g., primary or secondary).
	SESSION_CARE_LEVEL char (2) NULL,
	--True if the session included any assessment of a person's physical activity, i.e., any body movement produced by skeletal muscles that results in increased energy expenditure above rest.
	SCREENING_ACTIVITY char (4) NULL,
	--True if the session included any assessment of a person's nutrition, i.e., intake of food.
	SCREENING_NUTRITION char (4) NULL,
	--True if the session included physical activity counseling, i.e., any discussion about how a person might improve or increase their physical activity.
	COUNSELING_ACTIVITY char (4) NULL,
	--True if the session included nutrition counseling, i.e., any discussion of how a person might improve their nutrition.
	COUNSELING_NUTRITION char (4) NULL,
	--True if the session included weight-related counseling, i.e., any discussion of the impact that obesity can have on a person's long-term quality of life.
	COUNSELING_WEIGHT char (4) NULL,
	--True if the session included at least moderate physical activity; moderate activity requires a moderate amount of effort and noticeably accelerates the heart rate.
	INTERVENTION_BEHAVIORAL_ACTIVITY char (4) NULL,
	--True if the session included an activity designed to improve nutrition.
	INTERVENTION_BEHAVIORAL_NUTRITION char (4) NULL,
	--True if the session included a medical intervention for obesity or a comorbidity related to obesity.
	INTERVENTION_MEDICAL char (4) NULL,
	--True if the session included a navigational service to access benefits or to overcome barriers to care.
	INTERVENTION_NAVIGATION char (4) NULL,
	SESSION_ID varchar,
	PATID varchar NOT NULL,
	PROGRAMID varchar,
	PROVIDERID varchar,
	ENCOUNTERID varchar,
	CHECK(SCREENING_ACTIVITY in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(SCREENING_NUTRITION in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(COUNSELING_ACTIVITY in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(COUNSELING_NUTRITION in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(COUNSELING_WEIGHT in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_BEHAVIORAL_ACTIVITY in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_BEHAVIORAL_NUTRITION in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_MEDICAL in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(INTERVENTION_NAVIGATION in ('Y', '5210', 'N', 'NI', 'UN', 'OT')),
	CHECK(SESSION_CARE_LEVEL in ('P', 'S', 'NI', 'UN', 'OT')),
	PRIMARY KEY(SESSION_ID),
	CONSTRAINT fk_PAT FOREIGN KEY(PATID) REFERENCES CDM.DEMOGRAPHIC (PATID),
	CONSTRAINT fk_PROGRAM FOREIGN KEY(PROGRAMID) REFERENCES CODI.PROGRAM (PROGRAM_ID),
	CONSTRAINT fk_PROVIDER FOREIGN KEY(PROVIDERID) REFERENCES CDM.PROVIDER (PROVIDERID),
	CONSTRAINT fk_ENCOUNTER FOREIGN KEY(ENCOUNTERID) REFERENCES CDM.ENCOUNTER (ENCOUNTERID)
);

--The SESSION_ALERT table contains one record for each alert that triggered during a session.
CREATE TABLE CODI.SESSION_ALERT
(
	--A date that an alert triggered.
	ALERT_DATE date NULL,
	--A time that an alert triggered.
	ALERT_TIME time NULL,
	SESSION_ALERT_ID varchar,
	ALERTID varchar NOT NULL,
	SESSIONID varchar NOT NULL,
	PRIMARY KEY(SESSION_ALERT_ID),
	CONSTRAINT fk_ALERT FOREIGN KEY(ALERTID) REFERENCES CODI.ALERT (ALERT_ID),
	CONSTRAINT fk_SESSION FOREIGN KEY(SESSIONID) REFERENCES CODI.SESSION (SESSION_ID)
);
