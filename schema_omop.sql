CREATE SCHEMA OMOP;

CREATE TABLE omop.cost
(
    cost_id character varying(255) PRIMARY KEY,
    person_id character varying(255) NOT NULL,
    cost_event_id character varying(255),
    cost_event_field_concept_id character varying(255),
    cost_concept_id character varying(255) ,
    cost numeric NOT NULL,
    incurred_date date NOT NULL,
    billed_date date,
    paid_date date
);