--
-- PostgreSQL database dump
--

\restrict 4cqViAUx8yeVhn0Q3c7HPKDLbG4hJfqD9zhArklW6bpfEMGEf6kd1r74qWRMnAX

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-08-27 01:55:33

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 16392)
-- Name: audit; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA audit;


ALTER SCHEMA audit OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 16390)
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 16391)
-- Name: monitoring; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA monitoring;


ALTER SCHEMA monitoring OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 16389)
-- Name: raw; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA raw;


ALTER SCHEMA raw OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 16434)
-- Name: accounts; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.accounts (
    bank_id character varying(50) NOT NULL,
    account_number character varying(50) NOT NULL,
    entity_id character varying(50) NOT NULL
);


ALTER TABLE core.accounts OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16414)
-- Name: entities; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.entities (
    entity_id character varying(50) NOT NULL,
    entity_name character varying(150) NOT NULL
);


ALTER TABLE core.entities OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16447)
-- Name: transactions; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.transactions (
    transaction_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    from_bank character varying(50) NOT NULL,
    from_account character varying(50) NOT NULL,
    to_bank character varying(50) NOT NULL,
    to_account character varying(50) NOT NULL,
    amount_received numeric(20,2),
    receiving_currency character varying(50),
    amount_paid numeric(20,2),
    payment_currency character varying(50),
    payment_format character varying(50),
    is_laundering boolean NOT NULL
);


ALTER TABLE core.transactions OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16465)
-- Name: alerts; Type: TABLE; Schema: monitoring; Owner: postgres
--

CREATE TABLE monitoring.alerts (
    alert_id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    rule_name character varying(100) NOT NULL,
    risk_score integer NOT NULL,
    alert_reason text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE monitoring.alerts OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16464)
-- Name: alerts_alert_id_seq; Type: SEQUENCE; Schema: monitoring; Owner: postgres
--

CREATE SEQUENCE monitoring.alerts_alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE monitoring.alerts_alert_id_seq OWNER TO postgres;

--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 229
-- Name: alerts_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: monitoring; Owner: postgres
--

ALTER SEQUENCE monitoring.alerts_alert_id_seq OWNED BY monitoring.alerts.alert_id;


--
-- TOC entry 232 (class 1259 OID 16480)
-- Name: entity_alerts; Type: TABLE; Schema: monitoring; Owner: postgres
--

CREATE TABLE monitoring.entity_alerts (
    entity_alert_id bigint NOT NULL,
    entity_id character varying(50) NOT NULL,
    entity_name character varying(150),
    transaction_count bigint,
    total_amount numeric(20,2),
    rule_name character varying(100),
    risk_score integer,
    alert_reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE monitoring.entity_alerts OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16479)
-- Name: entity_alerts_entity_alert_id_seq; Type: SEQUENCE; Schema: monitoring; Owner: postgres
--

CREATE SEQUENCE monitoring.entity_alerts_entity_alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE monitoring.entity_alerts_entity_alert_id_seq OWNER TO postgres;

--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 231
-- Name: entity_alerts_entity_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: monitoring; Owner: postgres
--

ALTER SEQUENCE monitoring.entity_alerts_entity_alert_id_seq OWNED BY monitoring.entity_alerts.entity_alert_id;


--
-- TOC entry 233 (class 1259 OID 16491)
-- Name: transaction_risk; Type: TABLE; Schema: monitoring; Owner: postgres
--

CREATE TABLE monitoring.transaction_risk (
    transaction_id bigint,
    "timestamp" timestamp without time zone,
    from_bank character varying(50),
    from_account character varying(50),
    to_bank character varying(50),
    to_account character varying(50),
    amount_paid numeric(20,2),
    payment_currency character varying(50),
    payment_format character varying(50),
    high_value_flag integer,
    large_cash_flag integer,
    cross_bank_flag integer,
    high_entity_activity_flag integer,
    risk_score integer,
    risk_level character varying(20)
);


ALTER TABLE monitoring.transaction_risk OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16402)
-- Name: accounts; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.accounts (
    bank_name character varying(150),
    bank_id character varying(50) NOT NULL,
    account_number character varying(50) NOT NULL,
    entity_id character varying(50),
    entity_name character varying(150)
);


ALTER TABLE raw.accounts OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16394)
-- Name: transactions; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.transactions (
    transaction_id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    from_bank character varying(50),
    from_account character varying(50),
    to_bank character varying(50),
    to_account character varying(50),
    amount_received numeric(20,2),
    receiving_currency character varying(50),
    amount_paid numeric(20,2),
    payment_currency character varying(50),
    payment_format character varying(50),
    is_laundering boolean
);


ALTER TABLE raw.transactions OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16393)
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: raw; Owner: postgres
--

CREATE SEQUENCE raw.transactions_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE raw.transactions_transaction_id_seq OWNER TO postgres;

--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 223
-- Name: transactions_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: raw; Owner: postgres
--

ALTER SEQUENCE raw.transactions_transaction_id_seq OWNED BY raw.transactions.transaction_id;


--
-- TOC entry 4891 (class 2604 OID 16468)
-- Name: alerts alert_id; Type: DEFAULT; Schema: monitoring; Owner: postgres
--

ALTER TABLE ONLY monitoring.alerts ALTER COLUMN alert_id SET DEFAULT nextval('monitoring.alerts_alert_id_seq'::regclass);


--
-- TOC entry 4893 (class 2604 OID 16483)
-- Name: entity_alerts entity_alert_id; Type: DEFAULT; Schema: monitoring; Owner: postgres
--

ALTER TABLE ONLY monitoring.entity_alerts ALTER COLUMN entity_alert_id SET DEFAULT nextval('monitoring.entity_alerts_entity_alert_id_seq'::regclass);


--
-- TOC entry 4890 (class 2604 OID 16397)
-- Name: transactions transaction_id; Type: DEFAULT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.transactions ALTER COLUMN transaction_id SET DEFAULT nextval('raw.transactions_transaction_id_seq'::regclass);


--
-- TOC entry 4902 (class 2606 OID 16441)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (bank_id, account_number);


--
-- TOC entry 4900 (class 2606 OID 16420)
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (entity_id);


--
-- TOC entry 4909 (class 2606 OID 16458)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 4911 (class 2606 OID 16478)
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: monitoring; Owner: postgres
--

ALTER TABLE ONLY monitoring.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (alert_id);


--
-- TOC entry 4913 (class 2606 OID 16490)
-- Name: entity_alerts entity_alerts_pkey; Type: CONSTRAINT; Schema: monitoring; Owner: postgres
--

ALTER TABLE ONLY monitoring.entity_alerts
    ADD CONSTRAINT entity_alerts_pkey PRIMARY KEY (entity_alert_id);


--
-- TOC entry 4898 (class 2606 OID 16412)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (bank_id, account_number);


--
-- TOC entry 4896 (class 2606 OID 16401)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 4903 (class 1259 OID 16463)
-- Name: idx_transactions_payment_currency; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_transactions_payment_currency ON core.transactions USING btree (payment_currency);


--
-- TOC entry 4904 (class 1259 OID 16462)
-- Name: idx_transactions_payment_format; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_transactions_payment_format ON core.transactions USING btree (payment_format);


--
-- TOC entry 4905 (class 1259 OID 16460)
-- Name: idx_transactions_receiver; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_transactions_receiver ON core.transactions USING btree (to_bank, to_account);


--
-- TOC entry 4906 (class 1259 OID 16459)
-- Name: idx_transactions_sender; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_transactions_sender ON core.transactions USING btree (from_bank, from_account);


--
-- TOC entry 4907 (class 1259 OID 16461)
-- Name: idx_transactions_timestamp; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_transactions_timestamp ON core.transactions USING btree ("timestamp");


--
-- TOC entry 4914 (class 2606 OID 16442)
-- Name: accounts accounts_entity_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.accounts
    ADD CONSTRAINT accounts_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES core.entities(entity_id);


-- Completed on 2026-08-27 01:55:33

--
-- PostgreSQL database dump complete
--

\unrestrict 4cqViAUx8yeVhn0Q3c7HPKDLbG4hJfqD9zhArklW6bpfEMGEf6kd1r74qWRMnAX

