--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;
CREATE SEQUENCE seq_test
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE test_table (
    col1 integer DEFAULT nextval('seq_test'::regclass) NOT NULL,
    col2 integer,
    col3 character varying(50),
    col4 character varying(50)
);

