--liquibase formatted sql

--changeset lazydba:BPS-1-1
DROP TABLE IF EXISTS employees;

--changeset lazydba:BPS-1-2
CREATE TABLE employees (
    employee_id                   character varying(100),
    employee_name                 character varying(100)
)
