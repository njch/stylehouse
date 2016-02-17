--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cheese; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE cheese (
    s text,
    ts timestamp with time zone,
    jid integer,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE cheese OWNER TO s;

--
-- Name: g; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE g (
    s text,
    ts timestamp with time zone,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE g OWNER TO s;

--
-- Name: gho; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE gho (
    file text,
    s text,
    dig text,
    ts timestamp with time zone,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE gho OWNER TO s;

--
-- Name: goat; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE goat (
    s text,
    ts timestamp with time zone,
    jid integer NOT NULL,
    jup integer,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE goat OWNER TO s;

--
-- Name: goat_jid_seq; Type: SEQUENCE; Schema: public; Owner: s
--

CREATE SEQUENCE goat_jid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE goat_jid_seq OWNER TO s;

--
-- Name: goat_jid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: s
--

ALTER SEQUENCE goat_jid_seq OWNED BY goat.jid;


--
-- Name: gw; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE gw (
    w text NOT NULL,
    pid text,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE gw OWNER TO s;

--
-- Name: gw_pin; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE gw_pin (
    w text,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE gw_pin OWNER TO s;

--
-- Name: mez; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE mez (
    f text,
    s text,
    ts timestamp with time zone DEFAULT now(),
    mid integer NOT NULL,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE mez OWNER TO s;

--
-- Name: mez_mid_seq; Type: SEQUENCE; Schema: public; Owner: s
--

CREATE SEQUENCE mez_mid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mez_mid_seq OWNER TO s;

--
-- Name: mez_mid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: s
--

ALTER SEQUENCE mez_mid_seq OWNED BY mez.mid;


--
-- Name: names; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE names (
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE names OWNER TO s;

--
-- Name: random; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE random (
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE random OWNER TO s;

--
-- Name: t; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE t (
    isle text,
    l text,
    ts timestamp with time zone,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE t OWNER TO s;

--
-- Name: w; Type: TABLE; Schema: public; Owner: s; Tablespace: 
--

CREATE TABLE w (
    isle text,
    ts timestamp with time zone,
    t text,
    y real,
    c json,
    sc json
);


ALTER TABLE w OWNER TO s;

--
-- Name: jid; Type: DEFAULT; Schema: public; Owner: s
--

ALTER TABLE ONLY goat ALTER COLUMN jid SET DEFAULT nextval('goat_jid_seq'::regclass);


--
-- Name: mid; Type: DEFAULT; Schema: public; Owner: s
--

ALTER TABLE ONLY mez ALTER COLUMN mid SET DEFAULT nextval('mez_mid_seq'::regclass);


--
-- Name: goat_pkey; Type: CONSTRAINT; Schema: public; Owner: s; Tablespace: 
--

ALTER TABLE ONLY goat
    ADD CONSTRAINT goat_pkey PRIMARY KEY (jid);


--
-- Name: gw_pkey; Type: CONSTRAINT; Schema: public; Owner: s; Tablespace: 
--

ALTER TABLE ONLY gw
    ADD CONSTRAINT gw_pkey PRIMARY KEY (w);


--
-- Name: mez_pkey; Type: CONSTRAINT; Schema: public; Owner: s; Tablespace: 
--

ALTER TABLE ONLY mez
    ADD CONSTRAINT mez_pkey PRIMARY KEY (mid);


--
-- Name: cheese_jid_idx; Type: INDEX; Schema: public; Owner: s; Tablespace: 
--

CREATE INDEX cheese_jid_idx ON cheese USING btree (jid);


--
-- Name: gho_t_idx; Type: INDEX; Schema: public; Owner: s; Tablespace: 
--

CREATE INDEX gho_t_idx ON gho USING btree (t);


--
-- Name: gw_pin_t_idx; Type: INDEX; Schema: public; Owner: s; Tablespace: 
--

CREATE INDEX gw_pin_t_idx ON gw_pin USING btree (t);


--
-- Name: cheese_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: s
--

ALTER TABLE ONLY cheese
    ADD CONSTRAINT cheese_jid_fkey FOREIGN KEY (jid) REFERENCES goat(jid) ON DELETE CASCADE;


--
-- Name: gw_pin_w_fkey; Type: FK CONSTRAINT; Schema: public; Owner: s
--

ALTER TABLE ONLY gw_pin
    ADD CONSTRAINT gw_pin_w_fkey FOREIGN KEY (w) REFERENCES gw(w) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

