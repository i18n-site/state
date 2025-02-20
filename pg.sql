-- DROP SCHEMA state CASCADE;
-- DROP SCHEMA fn CASCADE;

CREATE SCHEMA IF NOT EXISTS state;

CREATE TABLE IF NOT EXISTS state.heartbeat (
id bigserial NOT NULL,
kind character varying(255) NOT NULL,
name character varying(255) NOT NULL,
ts bigint NOT NULL,
ts_next bigint NOT NULL,
state text,
warn integer NOT NULL DEFAULT 0,
err BOOLEAN NOT NULL DEFAULT FALSE,
PRIMARY KEY (id),
UNIQUE (kind,name)
);

CREATE SCHEMA IF NOT EXISTS fn;

CREATE OR REPLACE FUNCTION fn.heartbeat(_kind VARCHAR(255),_name VARCHAR(255),_duration BIGINT,_state TEXT DEFAULT NULL) RETURNS BIGINT AS $$
DECLARE 
  _ts BIGINT:=EXTRACT(EPOCH FROM NOW())::BIGINT;
  _pre_ts BIGINT;
  _pre_ts_next BIGINT;
  _id BIGINT;
  _err BOOLEAN;
BEGIN
  SELECT id,err,ts,ts_next INTO _id,_err,_pre_ts,_pre_ts_next FROM state.heartbeat WHERE name=_name AND kind=_kind;
  IF _id IS NULL THEN
    INSERT INTO state.heartbeat(kind,name,ts,ts_next,state)VALUES(_kind,_name,_ts,_ts+_duration,_state);
  ELSE
    IF _err THEN
      UPDATE state.heartbeat SET ts=_ts,ts_next=_ts+_duration,state=_state,err=false,warn=0 WHERE id=_id;
      RETURN _ts-_pre_ts;
    ELSE
      UPDATE state.heartbeat SET ts=_ts,ts_next=_ts+_duration,state=_state WHERE id=_id;
      -- 超时
      IF _ts > _pre_ts_next THEN
        RETURN _ts-_pre_ts;
      END IF;
    END IF;
  END IF;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn.heartbeatErr(_kind VARCHAR(255),_name VARCHAR(255),_duration BIGINT,_state TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  _ts BIGINT:=EXTRACT(EPOCH FROM NOW())::BIGINT;
  _ts_next BIGINT:=_ts+_duration;
  _id BIGINT;
  _err BOOLEAN;
BEGIN
  SELECT id,err INTO _id,_err FROM state.heartbeat WHERE name=_name AND kind=_kind;
  IF _id IS NOT NULL THEN
    IF _err THEN
      UPDATE state.heartbeat SET ts_next=_ts_next,state=_state WHERE id=_id;
      RETURN FALSE;
    ELSE
      UPDATE state.heartbeat SET ts_next=_ts_next,state=_state,err=TRUE,warn=1 WHERE id=_id;
      RETURN TRUE;
    END IF;
  ELSE
    INSERT INTO state.heartbeat(kind,name,ts,ts_next,state,warn,err)VALUES(_kind,_name,_ts,_ts_next,_state,1,TRUE);
    RETURN TRUE;
  END IF;
END;
$$ LANGUAGE plpgsql;
