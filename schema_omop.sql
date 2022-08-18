CREATE SCHEMA OMOP;

CREATE TABLE omop.cost
(
    cost_id varchar PRIMARY KEY,
    person_id varchar NOT NULL,
    cost_event_id varchar NOT NULL,
    cost_event_field_concept_id varchar NOT NULL,
    cost_concept_id varchar NOT NULL,
    cost float NOT NULL,
    incurred_date date NOT NULL,
    billed_date date,
    paid_date date
);
