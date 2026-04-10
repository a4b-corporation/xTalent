-- DROP SCHEMA payroll;

CREATE SCHEMA payroll AUTHORIZATION apipayroll;

-- DROP SEQUENCE payroll.pgwsq_iface_def;

CREATE SEQUENCE payroll.pgwsq_iface_def
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.pgwsq_iface_def OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.pgwsq_iface_def TO apipayroll;

-- DROP SEQUENCE payroll.pgwsq_iface_file;

CREATE SEQUENCE payroll.pgwsq_iface_file
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.pgwsq_iface_file OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.pgwsq_iface_file TO apipayroll;

-- DROP SEQUENCE payroll.pgwsq_iface_job;

CREATE SEQUENCE payroll.pgwsq_iface_job
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.pgwsq_iface_job OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.pgwsq_iface_job TO apipayroll;

-- DROP SEQUENCE payroll.pgwsq_iface_line;

CREATE SEQUENCE payroll.pgwsq_iface_line
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.pgwsq_iface_line OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.pgwsq_iface_line TO apipayroll;

-- DROP SEQUENCE payroll.ppasq_audit_log;

CREATE SEQUENCE payroll.ppasq_audit_log
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppasq_audit_log OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppasq_audit_log TO apipayroll;

-- DROP SEQUENCE payroll.ppasq_bank_template;

CREATE SEQUENCE payroll.ppasq_bank_template
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppasq_bank_template OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppasq_bank_template TO apipayroll;

-- DROP SEQUENCE payroll.ppasq_generated_file;

CREATE SEQUENCE payroll.ppasq_generated_file
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppasq_generated_file OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppasq_generated_file TO apipayroll;

-- DROP SEQUENCE payroll.ppasq_import_job;

CREATE SEQUENCE payroll.ppasq_import_job
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppasq_import_job OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppasq_import_job TO apipayroll;

-- DROP SEQUENCE payroll.ppasq_tax_report_template;

CREATE SEQUENCE payroll.ppasq_tax_report_template
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppasq_tax_report_template OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppasq_tax_report_template TO apipayroll;

-- DROP SEQUENCE payroll.ppbsq_bank_account;

CREATE SEQUENCE payroll.ppbsq_bank_account
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppbsq_bank_account OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppbsq_bank_account TO apipayroll;

-- DROP SEQUENCE payroll.ppbsq_payment_batch;

CREATE SEQUENCE payroll.ppbsq_payment_batch
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppbsq_payment_batch OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppbsq_payment_batch TO apipayroll;

-- DROP SEQUENCE payroll.ppbsq_payment_line;

CREATE SEQUENCE payroll.ppbsq_payment_line
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppbsq_payment_line OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppbsq_payment_line TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_balance;

CREATE SEQUENCE payroll.ppesq_balance
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_balance OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_balance TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_calc_log;

CREATE SEQUENCE payroll.ppesq_calc_log
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_calc_log OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_calc_log TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_calculation_step;

CREATE SEQUENCE payroll.ppesq_calculation_step
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_calculation_step OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_calculation_step TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_costing;

CREATE SEQUENCE payroll.ppesq_costing
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_costing OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_costing TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_cumulative_balance;

CREATE SEQUENCE payroll.ppesq_cumulative_balance
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_cumulative_balance OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_cumulative_balance TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_element_dependency;

CREATE SEQUENCE payroll.ppesq_element_dependency
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_element_dependency OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_element_dependency TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_input_source_config;

CREATE SEQUENCE payroll.ppesq_input_source_config
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_input_source_config OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_input_source_config TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_input_value;

CREATE SEQUENCE payroll.ppesq_input_value
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_input_value OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_input_value TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_result;

CREATE SEQUENCE payroll.ppesq_result
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_result OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_result TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_retro_delta;

CREATE SEQUENCE payroll.ppesq_retro_delta
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_retro_delta OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_retro_delta TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_run_employee;

CREATE SEQUENCE payroll.ppesq_run_employee
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_run_employee OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_run_employee TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_run_request;

CREATE SEQUENCE payroll.ppesq_run_request
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_run_request OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_run_request TO apipayroll;

-- DROP SEQUENCE payroll.ppesq_run_step;

CREATE SEQUENCE payroll.ppesq_run_step
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppesq_run_step OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppesq_run_step TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_balance_def;

CREATE SEQUENCE payroll.ppmsq_balance_def
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_balance_def OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_balance_def TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_costing_rule;

CREATE SEQUENCE payroll.ppmsq_costing_rule
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_costing_rule OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_costing_rule TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_gl_mapping;

CREATE SEQUENCE payroll.ppmsq_gl_mapping
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_gl_mapping OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_gl_mapping TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_adjust_reason;

CREATE SEQUENCE payroll.ppmsq_pay_adjust_reason
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_adjust_reason OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_adjust_reason TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_benefit_link;

CREATE SEQUENCE payroll.ppmsq_pay_benefit_link
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_benefit_link OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_benefit_link TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_calendar;

CREATE SEQUENCE payroll.ppmsq_pay_calendar
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_calendar OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_calendar TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_deduction_policy;

CREATE SEQUENCE payroll.ppmsq_pay_deduction_policy
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_deduction_policy OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_deduction_policy TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_element;

CREATE SEQUENCE payroll.ppmsq_pay_element
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_element OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_element TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_formula;

CREATE SEQUENCE payroll.ppmsq_pay_formula
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_formula OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_formula TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_frequency;

CREATE SEQUENCE payroll.ppmsq_pay_frequency
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_frequency OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_frequency TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_group;

CREATE SEQUENCE payroll.ppmsq_pay_group
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_group OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_group TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_profile;

CREATE SEQUENCE payroll.ppmsq_pay_profile
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_profile OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_profile TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_profile_element;

CREATE SEQUENCE payroll.ppmsq_pay_profile_element
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_profile_element OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_profile_element TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_profile_map;

CREATE SEQUENCE payroll.ppmsq_pay_profile_map
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_profile_map OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_profile_map TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_profile_rate_config;

CREATE SEQUENCE payroll.ppmsq_pay_profile_rate_config
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_profile_rate_config OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_profile_rate_config TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_pay_profile_rule;

CREATE SEQUENCE payroll.ppmsq_pay_profile_rule
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_pay_profile_rule OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_pay_profile_rule TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_payslip_template;

CREATE SEQUENCE payroll.ppmsq_payslip_template
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_payslip_template OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_payslip_template TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_piece_rate_config;

CREATE SEQUENCE payroll.ppmsq_piece_rate_config
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_piece_rate_config OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_piece_rate_config TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_statutory_rule;

CREATE SEQUENCE payroll.ppmsq_statutory_rule
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_statutory_rule OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_statutory_rule TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_termination_pay_config;

CREATE SEQUENCE payroll.ppmsq_termination_pay_config
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_termination_pay_config OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_termination_pay_config TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_validation_rule;

CREATE SEQUENCE payroll.ppmsq_validation_rule
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_validation_rule OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_validation_rule TO apipayroll;

-- DROP SEQUENCE payroll.ppmsq_worker_rate_override;

CREATE SEQUENCE payroll.ppmsq_worker_rate_override
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmsq_worker_rate_override OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmsq_worker_rate_override TO apipayroll;

-- DROP SEQUENCE payroll.ppmtsq_batch;

CREATE SEQUENCE payroll.ppmtsq_batch
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmtsq_batch OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmtsq_batch TO apipayroll;

-- DROP SEQUENCE payroll.ppmtsq_manual_adjust;

CREATE SEQUENCE payroll.ppmtsq_manual_adjust
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmtsq_manual_adjust OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmtsq_manual_adjust TO apipayroll;

-- DROP SEQUENCE payroll.ppmtsq_pay_period;

CREATE SEQUENCE payroll.ppmtsq_pay_period
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;

-- Permissions

ALTER SEQUENCE payroll.ppmtsq_pay_period OWNER TO apipayroll;
GRANT ALL ON SEQUENCE payroll.ppmtsq_pay_period TO apipayroll;
-- payroll.pgwtb_iface_def definition

-- Drop table

-- DROP TABLE payroll.pgwtb_iface_def;

CREATE TABLE payroll.pgwtb_iface_def (
	id numeric DEFAULT nextval('payroll.pgwsq_iface_def'::regclass) NOT NULL,
	code varchar(50) NOT NULL,
	"name" varchar(100) NOT NULL,
	direction varchar(10) NOT NULL,
	file_type varchar(10) NOT NULL,
	mapping_json jsonb NOT NULL,
	schedule_json jsonb NULL,
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT pgwtb_iface_def_pk PRIMARY KEY (id),
	CONSTRAINT pgwtb_iface_def_uk UNIQUE (tenant_code, code)
);
COMMENT ON TABLE payroll.pgwtb_iface_def IS 'Interface definition — configures data exchange channels for payroll gateway (IN/OUT)';

-- Permissions

ALTER TABLE payroll.pgwtb_iface_def OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.pgwtb_iface_def TO apipayroll;


-- payroll.ppatb_audit_log definition

-- Drop table

-- DROP TABLE payroll.ppatb_audit_log;

CREATE TABLE payroll.ppatb_audit_log (
	id numeric DEFAULT nextval('payroll.ppasq_audit_log'::regclass) NOT NULL,
	log_time timestamptz DEFAULT now() NULL,
	user_name varchar(100) NOT NULL,
	category varchar(20) NOT NULL,
	log_action varchar(30) NOT NULL,
	log_detail text NULL,
	reference_id numeric NULL,
	employee_id numeric NULL,
	payroll_run_id numeric NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppatb_audit_log_pk PRIMARY KEY (id)
);
CREATE INDEX ppatb_audit_log_idx_category_time ON payroll.ppatb_audit_log USING btree (category, log_time);
CREATE INDEX ppatb_audit_log_idx_employee ON payroll.ppatb_audit_log USING btree (employee_id);
CREATE INDEX ppatb_audit_log_idx_payroll_run ON payroll.ppatb_audit_log USING btree (payroll_run_id);
COMMENT ON TABLE payroll.ppatb_audit_log IS 'Immutable audit log for all payroll actions (CONFIG|PROFILE|INPUT|RUN). Insert-only; 7-year retention.';

-- Permissions

ALTER TABLE payroll.ppatb_audit_log OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppatb_audit_log TO apipayroll;


-- payroll.ppatb_bank_template definition

-- Drop table

-- DROP TABLE payroll.ppatb_bank_template;

CREATE TABLE payroll.ppatb_bank_template (
	id numeric DEFAULT nextval('payroll.ppasq_bank_template'::regclass) NOT NULL,
	code varchar(20) NOT NULL,
	"name" varchar(100) NOT NULL,
	format varchar(10) NOT NULL,
	"delimiter" varchar(5) NULL,
	columns_json jsonb NOT NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppatb_bank_template_pk PRIMARY KEY (id),
	CONSTRAINT ppatb_bank_template_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppatb_bank_template IS 'Bank file format templates defining column structure for salary transfer files (VCB, VIETIN, CITI…). SCD2 versioned.';

-- Permissions

ALTER TABLE payroll.ppatb_bank_template OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppatb_bank_template TO apipayroll;


-- payroll.ppatb_import_job definition

-- Drop table

-- DROP TABLE payroll.ppatb_import_job;

CREATE TABLE payroll.ppatb_import_job (
	id numeric DEFAULT nextval('payroll.ppasq_import_job'::regclass) NOT NULL,
	file_name varchar(255) NOT NULL,
	pay_group_code varchar(50) NULL,
	period_start date NULL,
	period_end date NULL,
	total_records int4 NOT NULL,
	success_count int4 NOT NULL,
	fail_count int4 NOT NULL,
	status varchar(20) NOT NULL,
	submitted_by varchar(100) NOT NULL,
	submitted_at timestamptz NOT NULL,
	completed_at timestamptz NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppatb_import_job_pk PRIMARY KEY (id)
);
COMMENT ON TABLE payroll.ppatb_import_job IS 'Tracks bulk file import jobs for payroll data uploads';

-- Permissions

ALTER TABLE payroll.ppatb_import_job OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppatb_import_job TO apipayroll;


-- payroll.ppatb_tax_report_template definition

-- Drop table

-- DROP TABLE payroll.ppatb_tax_report_template;

CREATE TABLE payroll.ppatb_tax_report_template (
	id numeric DEFAULT nextval('payroll.ppasq_tax_report_template'::regclass) NOT NULL,
	code varchar(20) NOT NULL,
	country_code varchar(3) NOT NULL,
	format varchar(10) NOT NULL,
	template_blob bytea NOT NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppatb_tax_report_template_pk PRIMARY KEY (id),
	CONSTRAINT ppatb_tax_report_template_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppatb_tax_report_template IS 'Tax report templates in PDF/XML format, versioned by country and effective date (SCD2). E.g. 05QTT_TNCN, 02KK.';

-- Permissions

ALTER TABLE payroll.ppatb_tax_report_template OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppatb_tax_report_template TO apipayroll;


-- payroll.ppbtb_bank_account definition

-- Drop table

-- DROP TABLE payroll.ppbtb_bank_account;

CREATE TABLE payroll.ppbtb_bank_account (
	id numeric DEFAULT nextval('payroll.ppbsq_bank_account'::regclass) NOT NULL,
	legal_entity_id numeric NOT NULL,
	legal_entity_code varchar(50) NOT NULL,
	bank_name varchar(100) NOT NULL,
	account_no varchar(50) NOT NULL,
	currency_code bpchar(3) NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppbtb_bank_account_pk PRIMARY KEY (id),
	CONSTRAINT ppbtb_bank_account_uk UNIQUE (legal_entity_id, bank_name, account_no)
);
COMMENT ON TABLE payroll.ppbtb_bank_account IS 'Bank account master for legal entities used in salary disbursement';

-- Permissions

ALTER TABLE payroll.ppbtb_bank_account OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppbtb_bank_account TO apipayroll;


-- payroll.ppetb_calculation_step definition

-- Drop table

-- DROP TABLE payroll.ppetb_calculation_step;

CREATE TABLE payroll.ppetb_calculation_step (
	id numeric DEFAULT nextval('payroll.ppesq_calculation_step'::regclass) NOT NULL,
	code varchar(30) NOT NULL, -- Mã bước: INPUT_COLLECTION | PRE_CALC | EARNINGS | STATUTORY_DEDUCTIONS | VOLUNTARY_DEDUCTIONS | TAX | NET_PAY | POST_CALC | BALANCING | COSTING
	"name" varchar(100) NOT NULL,
	"sequence" int2 NOT NULL, -- Thứ tự thực thi: 1(INPUT_COLLECTION)→2(PRE_CALC)→...→10(COSTING)
	is_active bool DEFAULT true NULL,
	is_mandatory bool DEFAULT true NULL, -- true = bước không thể bỏ qua; false = có thể skip (vd: COSTING nếu không tích hợp GL)
	description text NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_calculation_step_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_calculation_step_uk_code UNIQUE (code)
);
CREATE INDEX ppetb_calculation_step_idx_active ON payroll.ppetb_calculation_step USING btree (is_active);
CREATE INDEX ppetb_calculation_step_idx_sequence ON payroll.ppetb_calculation_step USING btree (sequence);
COMMENT ON TABLE payroll.ppetb_calculation_step IS 'NEW V4: Reference table defining calculation pipeline steps. Standard pipeline: INPUT_COLLECTION→PRE_CALC→EARNINGS→STATUTORY_DEDUCTIONS→VOLUNTARY_DEDUCTIONS→TAX→NET_PAY→POST_CALC→BALANCING→COSTING.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_calculation_step.code IS 'Mã bước: INPUT_COLLECTION | PRE_CALC | EARNINGS | STATUTORY_DEDUCTIONS | VOLUNTARY_DEDUCTIONS | TAX | NET_PAY | POST_CALC | BALANCING | COSTING';
COMMENT ON COLUMN payroll.ppetb_calculation_step."sequence" IS 'Thứ tự thực thi: 1(INPUT_COLLECTION)→2(PRE_CALC)→...→10(COSTING)';
COMMENT ON COLUMN payroll.ppetb_calculation_step.is_mandatory IS 'true = bước không thể bỏ qua; false = có thể skip (vd: COSTING nếu không tích hợp GL)';
COMMENT ON COLUMN payroll.ppetb_calculation_step.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_calculation_step.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_calculation_step OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_calculation_step TO apipayroll;


-- payroll.ppmtb_costing_rule definition

-- Drop table

-- DROP TABLE payroll.ppmtb_costing_rule;

CREATE TABLE payroll.ppmtb_costing_rule (
	id numeric DEFAULT nextval('payroll.ppmsq_costing_rule'::regclass) NOT NULL, -- Khóa chính
	code varchar(50) NOT NULL, -- Mã quy tắc
	"name" varchar(100) NOT NULL, -- Tên quy tắc
	level_scope varchar(20) NULL, -- Phạm vi áp dụng: LE | BU | EMP | ELEMENT
	mapping_json jsonb NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực (SCD2)
	effective_end timestamptz NULL, -- Ngày kết thúc hiệu lực (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện hành (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_costing_rule_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_costing_rule_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_costing_rule IS 'CHANGED JUL 2025. Quy tắc hạch toán chi phí (Costing Rule) dùng trong tính lương';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_costing_rule.id IS 'Khóa chính';
COMMENT ON COLUMN payroll.ppmtb_costing_rule.code IS 'Mã quy tắc';
COMMENT ON COLUMN payroll.ppmtb_costing_rule."name" IS 'Tên quy tắc';
COMMENT ON COLUMN payroll.ppmtb_costing_rule.level_scope IS 'Phạm vi áp dụng: LE | BU | EMP | ELEMENT';
COMMENT ON COLUMN payroll.ppmtb_costing_rule.effective_start IS 'Ngày hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_costing_rule.effective_end IS 'Ngày kết thúc hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_costing_rule.current_flg IS 'Cờ đánh dấu bản ghi hiện hành (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_costing_rule OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_costing_rule TO apipayroll;


-- payroll.ppmtb_pay_adjust_reason definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_adjust_reason;

CREATE TABLE payroll.ppmtb_pay_adjust_reason (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_adjust_reason'::regclass) NOT NULL,
	code varchar(50) NOT NULL, -- Mã lý do điều chỉnh (duy nhất)
	"name" varchar(100) NOT NULL, -- Tên lý do
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_adjust_reason_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_adjust_reason_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_pay_adjust_reason IS 'CHANGED JUL 2025. Master lý do điều chỉnh lương (adjustment reason).';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_adjust_reason.code IS 'Mã lý do điều chỉnh (duy nhất)';
COMMENT ON COLUMN payroll.ppmtb_pay_adjust_reason."name" IS 'Tên lý do';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_adjust_reason OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_adjust_reason TO apipayroll;


-- payroll.ppmtb_pay_calendar definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_calendar;

CREATE TABLE payroll.ppmtb_pay_calendar (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_calendar'::regclass) NOT NULL, -- Khóa chính nội bộ (ID tự sinh)
	legal_entity_id numeric NOT NULL, -- ID đơn vị pháp lý (tham chiếu core.orgtb_entity)
	legal_entity_code varchar(50) NOT NULL, -- Mã đơn vị pháp lý (tham chiếu core.orgtb_entity)
	market_id numeric NOT NULL, -- ID thị trường áp dụng
	market_code varchar(50) NOT NULL, -- Mã thị trường áp dụng
	frequency_id numeric NOT NULL, -- ID chu kỳ trả lương (tham chiếu ppmtb_pay_frequency)
	frequency_code varchar(20) NULL, -- Mã chu kỳ trả lương
	code varchar(50) NOT NULL, -- Mã định danh lịch trả lương
	"name" jsonb NOT NULL, -- Tên lịch trả lương (hỗ trợ đa ngôn ngữ)
	calendar_json jsonb NULL, -- Dữ liệu lịch trả lương theo tháng, dạng JSON: {"2025-01":{"start":"01","end":"31","seq":1}}
	metadata jsonb NULL, -- Thông tin mở rộng dạng JSON
	default_currency varchar(3) NOT NULL, -- CHANGED JUL 2025: Tiền tệ gốc của lịch lương (ISO 4217: VND, USD, SGD)
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Thời điểm bắt đầu hiệu lực
	effective_end timestamptz NULL, -- Thời điểm kết thúc hiệu lực
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện hành (true nếu là bản ghi đang dùng)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo bản ghi
	maker_date timestamptz NULL, -- Ngày giờ tạo bản ghi
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL, -- Số lần chỉnh sửa
	create_date timestamptz DEFAULT now() NULL, -- Thời điểm khởi tạo bản ghi
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_calendar_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_calendar_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_pay_calendar IS 'Bảng cấu hình lịch trả lương theo đơn vị pháp lý và chu kỳ trả lương';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_calendar.id IS 'Khóa chính nội bộ (ID tự sinh)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.legal_entity_id IS 'ID đơn vị pháp lý (tham chiếu core.orgtb_entity)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.legal_entity_code IS 'Mã đơn vị pháp lý (tham chiếu core.orgtb_entity)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.market_id IS 'ID thị trường áp dụng';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.market_code IS 'Mã thị trường áp dụng';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.frequency_id IS 'ID chu kỳ trả lương (tham chiếu ppmtb_pay_frequency)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.frequency_code IS 'Mã chu kỳ trả lương';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.code IS 'Mã định danh lịch trả lương';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar."name" IS 'Tên lịch trả lương (hỗ trợ đa ngôn ngữ)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.calendar_json IS 'Dữ liệu lịch trả lương theo tháng, dạng JSON: {"2025-01":{"start":"01","end":"31","seq":1}}';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.metadata IS 'Thông tin mở rộng dạng JSON';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.default_currency IS 'CHANGED JUL 2025: Tiền tệ gốc của lịch lương (ISO 4217: VND, USD, SGD)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.effective_start IS 'Thời điểm bắt đầu hiệu lực';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.effective_end IS 'Thời điểm kết thúc hiệu lực';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.current_flg IS 'Cờ đánh dấu bản ghi hiện hành (true nếu là bản ghi đang dùng)';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.maker_id IS 'Người tạo bản ghi';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.maker_date IS 'Ngày giờ tạo bản ghi';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.mod_no IS 'Số lần chỉnh sửa';
COMMENT ON COLUMN payroll.ppmtb_pay_calendar.create_date IS 'Thời điểm khởi tạo bản ghi';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_calendar OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_calendar TO apipayroll;


-- payroll.ppmtb_pay_deduction_policy definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_deduction_policy;

CREATE TABLE payroll.ppmtb_pay_deduction_policy (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_deduction_policy'::regclass) NOT NULL,
	code varchar(50) NOT NULL, -- Mã chính sách deduction (duy nhất)
	"name" varchar(100) NOT NULL,
	deduction_json jsonb NULL, -- Quy tắc deduction (theo country/market/policy)
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_deduction_policy_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_deduction_policy_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_pay_deduction_policy IS 'CHANGED JUL 2025. Chính sách deduction, quản lý deduction logic cho payroll.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_deduction_policy.code IS 'Mã chính sách deduction (duy nhất)';
COMMENT ON COLUMN payroll.ppmtb_pay_deduction_policy.deduction_json IS 'Quy tắc deduction (theo country/market/policy)';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_deduction_policy OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_deduction_policy TO apipayroll;


-- payroll.ppmtb_pay_element definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_element;

CREATE TABLE payroll.ppmtb_pay_element (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_element'::regclass) NOT NULL, -- Khóa chính
	code varchar(50) NOT NULL, -- Mã phần tử lương (duy nhất)
	"name" varchar(100) NOT NULL, -- Tên phần tử lương
	classification varchar(35) NOT NULL, -- Phân loại: EARNING | DEDUCTION | TAX
	unit varchar(10) NOT NULL, -- Đơn vị: AMOUNT | HOURS
	input_required bool DEFAULT false NULL,
	formula_json jsonb NULL,
	priority_order int2 NULL,
	taxable_flag bool DEFAULT true NULL,
	pre_tax_flag bool DEFAULT true NULL,
	statutory_rule_id numeric NULL, -- CHANGED JUL 2025: ID quy tắc pháp lý liên kết
	statutory_rule_code varchar(50) NULL, -- Mã quy tắc pháp lý liên kết
	eligibility_profile_id uuid NULL, -- changed 26Mar2026: ID eligibility profile (cross-module ref đến eligibility.eligibility_profile)
	country_code bpchar(2) NULL, -- changed 26Mar2026: Mã quốc gia ISO (VN, SG, US). NULL = element áp dụng toàn cầu
	config_scope_id uuid NULL, -- changed 26Mar2026: FK tham chiếu đến comp_core.config_scope (cross-module ref)
	gl_account_code varchar(50) NULL, -- CHANGED JUL 2025: Mã tài khoản kế toán GL
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu (SCD2)
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL, -- Số lần cập nhật
	create_date timestamptz DEFAULT now() NULL, -- Thời điểm khởi tạo
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_element_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_element_uk UNIQUE (id, code)
);
CREATE INDEX ppmtb_pay_element_idx_code ON payroll.ppmtb_pay_element USING btree (code);
CREATE INDEX ppmtb_pay_element_idx_code_country ON payroll.ppmtb_pay_element USING btree (code, country_code);
CREATE INDEX ppmtb_pay_element_idx_config_scope ON payroll.ppmtb_pay_element USING btree (config_scope_id);
CREATE INDEX ppmtb_pay_element_idx_country ON payroll.ppmtb_pay_element USING btree (country_code);
COMMENT ON TABLE payroll.ppmtb_pay_element IS 'CHANGED JUL 2025. CHANGED 26Mar2026: Phần tử lương (EARNING|DEDUCTION|TAX). Hỗ trợ multi-country scoping và eligibility profile.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_element.id IS 'Khóa chính';
COMMENT ON COLUMN payroll.ppmtb_pay_element.code IS 'Mã phần tử lương (duy nhất)';
COMMENT ON COLUMN payroll.ppmtb_pay_element."name" IS 'Tên phần tử lương';
COMMENT ON COLUMN payroll.ppmtb_pay_element.classification IS 'Phân loại: EARNING | DEDUCTION | TAX';
COMMENT ON COLUMN payroll.ppmtb_pay_element.unit IS 'Đơn vị: AMOUNT | HOURS';
COMMENT ON COLUMN payroll.ppmtb_pay_element.statutory_rule_id IS 'CHANGED JUL 2025: ID quy tắc pháp lý liên kết';
COMMENT ON COLUMN payroll.ppmtb_pay_element.statutory_rule_code IS 'Mã quy tắc pháp lý liên kết';
COMMENT ON COLUMN payroll.ppmtb_pay_element.eligibility_profile_id IS 'changed 26Mar2026: ID eligibility profile (cross-module ref đến eligibility.eligibility_profile)';
COMMENT ON COLUMN payroll.ppmtb_pay_element.country_code IS 'changed 26Mar2026: Mã quốc gia ISO (VN, SG, US). NULL = element áp dụng toàn cầu';
COMMENT ON COLUMN payroll.ppmtb_pay_element.config_scope_id IS 'changed 26Mar2026: FK tham chiếu đến comp_core.config_scope (cross-module ref)';
COMMENT ON COLUMN payroll.ppmtb_pay_element.gl_account_code IS 'CHANGED JUL 2025: Mã tài khoản kế toán GL';
COMMENT ON COLUMN payroll.ppmtb_pay_element.effective_start IS 'Ngày hiệu lực bắt đầu (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_element.effective_end IS 'Ngày hiệu lực kết thúc (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_element.current_flg IS 'Cờ bản ghi hiện hành (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_element.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_pay_element.maker_date IS 'Thời điểm tạo';
COMMENT ON COLUMN payroll.ppmtb_pay_element.mod_no IS 'Số lần cập nhật';
COMMENT ON COLUMN payroll.ppmtb_pay_element.create_date IS 'Thời điểm khởi tạo';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_element OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_element TO apipayroll;


-- payroll.ppmtb_pay_formula definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_formula;

CREATE TABLE payroll.ppmtb_pay_formula (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_formula'::regclass) NOT NULL,
	code varchar(50) NOT NULL, -- Mã công thức (duy nhất)
	"name" varchar(255) NOT NULL,
	script text NOT NULL, -- Nội dung script công thức
	version_no int4 DEFAULT 1 NULL, -- Số phiên bản
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_formula_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_formula_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_pay_formula IS 'CHANGED JUL 2025. Kho công thức tính toán payroll dùng chung.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_formula.code IS 'Mã công thức (duy nhất)';
COMMENT ON COLUMN payroll.ppmtb_pay_formula.script IS 'Nội dung script công thức';
COMMENT ON COLUMN payroll.ppmtb_pay_formula.version_no IS 'Số phiên bản';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_formula OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_formula TO apipayroll;


-- payroll.ppmtb_pay_frequency definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_frequency;

CREATE TABLE payroll.ppmtb_pay_frequency (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_frequency'::regclass) NOT NULL, -- ID chu kỳ trả lương
	code varchar(20) NOT NULL, -- Mã chu kỳ: MONTHLY | BIWEEKLY | WEEKLY
	"name" jsonb NOT NULL, -- Tên chu kỳ (đa ngôn ngữ)
	period_days int2 NULL, -- Số ngày trong kỳ
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_frequency_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_frequency_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_pay_frequency IS 'Danh mục chu kỳ trả lương: MONTHLY, BIWEEKLY, WEEKLY...';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_frequency.id IS 'ID chu kỳ trả lương';
COMMENT ON COLUMN payroll.ppmtb_pay_frequency.code IS 'Mã chu kỳ: MONTHLY | BIWEEKLY | WEEKLY';
COMMENT ON COLUMN payroll.ppmtb_pay_frequency."name" IS 'Tên chu kỳ (đa ngôn ngữ)';
COMMENT ON COLUMN payroll.ppmtb_pay_frequency.period_days IS 'Số ngày trong kỳ';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_frequency OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_frequency TO apipayroll;


-- payroll.ppmtb_pay_group definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_group;

CREATE TABLE payroll.ppmtb_pay_group (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_group'::regclass) NOT NULL, -- ID nhóm lương
	code varchar(50) NOT NULL, -- Mã nhóm lương
	"name" jsonb NOT NULL, -- Tên nhóm lương (đa ngôn ngữ)
	legal_entity_id numeric NOT NULL, -- ID pháp nhân
	legal_entity_code varchar(50) NOT NULL, -- Mã pháp nhân
	market_id numeric NOT NULL, -- ID thị trường áp dụng
	market_code varchar(50) NOT NULL, -- Mã thị trường áp dụng
	calendar_id numeric NOT NULL, -- ID lịch lương
	calendar_code varchar(50) NOT NULL, -- Mã lịch lương
	bank_account_id numeric NULL, -- ID tài khoản ngân hàng
	currency_code bpchar(3) NULL, -- Mã tiền tệ
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu (SCD2)
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ xác định bản ghi hiện hành (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Ngày tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL, -- Số lần chỉnh sửa
	create_date timestamptz DEFAULT now() NULL, -- Ngày tạo ban đầu
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_group_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_group_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_pay_group IS 'Thông tin nhóm lương - xác định kỳ lương, đơn vị, tài khoản ngân hàng, tiền tệ';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_group.id IS 'ID nhóm lương';
COMMENT ON COLUMN payroll.ppmtb_pay_group.code IS 'Mã nhóm lương';
COMMENT ON COLUMN payroll.ppmtb_pay_group."name" IS 'Tên nhóm lương (đa ngôn ngữ)';
COMMENT ON COLUMN payroll.ppmtb_pay_group.legal_entity_id IS 'ID pháp nhân';
COMMENT ON COLUMN payroll.ppmtb_pay_group.legal_entity_code IS 'Mã pháp nhân';
COMMENT ON COLUMN payroll.ppmtb_pay_group.market_id IS 'ID thị trường áp dụng';
COMMENT ON COLUMN payroll.ppmtb_pay_group.market_code IS 'Mã thị trường áp dụng';
COMMENT ON COLUMN payroll.ppmtb_pay_group.calendar_id IS 'ID lịch lương';
COMMENT ON COLUMN payroll.ppmtb_pay_group.calendar_code IS 'Mã lịch lương';
COMMENT ON COLUMN payroll.ppmtb_pay_group.bank_account_id IS 'ID tài khoản ngân hàng';
COMMENT ON COLUMN payroll.ppmtb_pay_group.currency_code IS 'Mã tiền tệ';
COMMENT ON COLUMN payroll.ppmtb_pay_group.effective_start IS 'Ngày hiệu lực bắt đầu (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_group.effective_end IS 'Ngày hiệu lực kết thúc (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_group.current_flg IS 'Cờ xác định bản ghi hiện hành (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_group.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_pay_group.maker_date IS 'Ngày tạo';
COMMENT ON COLUMN payroll.ppmtb_pay_group.mod_no IS 'Số lần chỉnh sửa';
COMMENT ON COLUMN payroll.ppmtb_pay_group.create_date IS 'Ngày tạo ban đầu';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_group OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_group TO apipayroll;


-- payroll.ppmtb_payslip_template definition

-- Drop table

-- DROP TABLE payroll.ppmtb_payslip_template;

CREATE TABLE payroll.ppmtb_payslip_template (
	id numeric DEFAULT nextval('payroll.ppmsq_payslip_template'::regclass) NOT NULL,
	code varchar(50) NOT NULL, -- Mã mẫu (duy nhất)
	"name" varchar(255) NOT NULL, -- Tên mẫu phiếu lương
	locale_code varchar(10) NULL, -- Mã ngôn ngữ/locale (vd: vi-VN, en-US)
	template_json jsonb NULL, -- Cấu trúc mẫu phiếu lương dạng JSON
	is_default bool DEFAULT false NULL, -- Mẫu mặc định?
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày bắt đầu hiệu lực (SCD2)
	effective_end timestamptz NULL, -- Ngày kết thúc hiệu lực (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_payslip_template_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_payslip_template_uk UNIQUE (id, code)
);
COMMENT ON TABLE payroll.ppmtb_payslip_template IS 'CHANGED JUL 2025. Mẫu phiếu lương tuỳ chỉnh.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_payslip_template.code IS 'Mã mẫu (duy nhất)';
COMMENT ON COLUMN payroll.ppmtb_payslip_template."name" IS 'Tên mẫu phiếu lương';
COMMENT ON COLUMN payroll.ppmtb_payslip_template.locale_code IS 'Mã ngôn ngữ/locale (vd: vi-VN, en-US)';
COMMENT ON COLUMN payroll.ppmtb_payslip_template.template_json IS 'Cấu trúc mẫu phiếu lương dạng JSON';
COMMENT ON COLUMN payroll.ppmtb_payslip_template.is_default IS 'Mẫu mặc định?';
COMMENT ON COLUMN payroll.ppmtb_payslip_template.effective_start IS 'Ngày bắt đầu hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_payslip_template.effective_end IS 'Ngày kết thúc hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_payslip_template.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_payslip_template OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_payslip_template TO apipayroll;


-- payroll.ppmtb_statutory_rule definition

-- Drop table

-- DROP TABLE payroll.ppmtb_statutory_rule;

CREATE TABLE payroll.ppmtb_statutory_rule (
	id numeric DEFAULT nextval('payroll.ppmsq_statutory_rule'::regclass) NOT NULL, -- ID định danh duy nhất
	code varchar(50) NOT NULL, -- Mã quy tắc pháp lý
	"name" varchar(255) NOT NULL, -- Tên quy tắc pháp lý
	market_id numeric NOT NULL, -- Thị trường áp dụng (ID)
	market_code varchar(50) NULL, -- Mã thị trường áp dụng
	rule_category varchar(30) NOT NULL, -- NEW 27Mar2026: Phân loại rule: TAX | SOCIAL_INSURANCE | OVERTIME | GROSS_TO_NET
	rule_type varchar(30) DEFAULT 'FORMULA'::character varying NOT NULL, -- NEW 27Mar2026: Loại rule: FORMULA | LOOKUP_TABLE | CONDITIONAL | RATE_TABLE | PROGRESSIVE
	country_code bpchar(2) NULL, -- NEW 27Mar2026: Mã quốc gia ISO (VN, SG, US). NULL = áp dụng toàn cầu
	jurisdiction varchar(50) NULL, -- NEW 27Mar2026: Tỉnh/thành/khu vực áp dụng (nếu có)
	legal_reference text NULL, -- NEW 27Mar2026: Trích dẫn pháp lý (vd: Điều 107, Bộ luật lao động 2019)
	formula_json jsonb NULL, -- Logic tính toán pháp lý (định nghĩa dưới dạng JSON)
	valid_from date NOT NULL, -- Ngày bắt đầu hiệu lực thực tế
	valid_to date NULL, -- Ngày kết thúc hiệu lực thực tế (nếu có)
	active_flg bool DEFAULT true NULL, -- Cờ hiệu lực logic của quy tắc
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu (SCD2)
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo bản ghi
	maker_date timestamptz NULL, -- Ngày tạo bản ghi
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL, -- Số lần sửa đổi
	create_date timestamptz DEFAULT now() NULL, -- Ngày tạo bản ghi lần đầu
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_statutory_rule_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_statutory_rule_uk UNIQUE (id, code)
);
CREATE INDEX ppmtb_statutory_rule_idx_category ON payroll.ppmtb_statutory_rule USING btree (rule_category);
CREATE INDEX ppmtb_statutory_rule_idx_category_country ON payroll.ppmtb_statutory_rule USING btree (rule_category, country_code);
CREATE INDEX ppmtb_statutory_rule_idx_code_current ON payroll.ppmtb_statutory_rule USING btree (code, current_flg);
CREATE INDEX ppmtb_statutory_rule_idx_country ON payroll.ppmtb_statutory_rule USING btree (country_code);
COMMENT ON TABLE payroll.ppmtb_statutory_rule IS 'CHANGED JUL 2025. ENRICHED 27Mar2026 — ADR Option D. Single Authority cho statutory/legal calculation rules: TAX | SOCIAL_INSURANCE | OVERTIME | GROSS_TO_NET';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_statutory_rule.id IS 'ID định danh duy nhất';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.code IS 'Mã quy tắc pháp lý';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule."name" IS 'Tên quy tắc pháp lý';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.market_id IS 'Thị trường áp dụng (ID)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.market_code IS 'Mã thị trường áp dụng';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.rule_category IS 'NEW 27Mar2026: Phân loại rule: TAX | SOCIAL_INSURANCE | OVERTIME | GROSS_TO_NET';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.rule_type IS 'NEW 27Mar2026: Loại rule: FORMULA | LOOKUP_TABLE | CONDITIONAL | RATE_TABLE | PROGRESSIVE';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.country_code IS 'NEW 27Mar2026: Mã quốc gia ISO (VN, SG, US). NULL = áp dụng toàn cầu';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.jurisdiction IS 'NEW 27Mar2026: Tỉnh/thành/khu vực áp dụng (nếu có)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.legal_reference IS 'NEW 27Mar2026: Trích dẫn pháp lý (vd: Điều 107, Bộ luật lao động 2019)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.formula_json IS 'Logic tính toán pháp lý (định nghĩa dưới dạng JSON)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.valid_from IS 'Ngày bắt đầu hiệu lực thực tế';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.valid_to IS 'Ngày kết thúc hiệu lực thực tế (nếu có)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.active_flg IS 'Cờ hiệu lực logic của quy tắc';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.effective_start IS 'Ngày hiệu lực bắt đầu (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.effective_end IS 'Ngày hiệu lực kết thúc (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.maker_id IS 'Người tạo bản ghi';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.maker_date IS 'Ngày tạo bản ghi';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.mod_no IS 'Số lần sửa đổi';
COMMENT ON COLUMN payroll.ppmtb_statutory_rule.create_date IS 'Ngày tạo bản ghi lần đầu';

-- Permissions

ALTER TABLE payroll.ppmtb_statutory_rule OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_statutory_rule TO apipayroll;


-- payroll.ppmtb_validation_rule definition

-- Drop table

-- DROP TABLE payroll.ppmtb_validation_rule;

CREATE TABLE payroll.ppmtb_validation_rule (
	id numeric DEFAULT nextval('payroll.ppmsq_validation_rule'::regclass) NOT NULL, -- ID định danh duy nhất
	rule_code varchar(50) NOT NULL, -- Mã rule kiểm tra
	rule_name varchar(255) NOT NULL, -- Tên rule kiểm tra
	target_table varchar(50) NULL, -- Tên bảng áp dụng rule
	field_name varchar(50) NULL, -- Tên cột áp dụng rule
	rule_expression text NULL, -- Biểu thức kiểm tra logic
	error_message varchar(255) NULL, -- Thông báo lỗi nếu không đạt
	active_flg bool DEFAULT true NULL, -- Cờ hiệu lực logic
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày bắt đầu hiệu lực (SCD2)
	effective_end timestamptz NULL, -- Ngày kết thúc hiệu lực (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_validation_rule_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_validation_rule_uk UNIQUE (id, rule_code)
);
COMMENT ON TABLE payroll.ppmtb_validation_rule IS 'CHANGED JUL 2025. Rule kiểm tra validate dữ liệu payroll.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_validation_rule.id IS 'ID định danh duy nhất';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.rule_code IS 'Mã rule kiểm tra';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.rule_name IS 'Tên rule kiểm tra';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.target_table IS 'Tên bảng áp dụng rule';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.field_name IS 'Tên cột áp dụng rule';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.rule_expression IS 'Biểu thức kiểm tra logic';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.error_message IS 'Thông báo lỗi nếu không đạt';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.active_flg IS 'Cờ hiệu lực logic';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.effective_start IS 'Ngày bắt đầu hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.effective_end IS 'Ngày kết thúc hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_validation_rule.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_validation_rule OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_validation_rule TO apipayroll;


-- payroll.pgwtb_iface_job definition

-- Drop table

-- DROP TABLE payroll.pgwtb_iface_job;

CREATE TABLE payroll.pgwtb_iface_job (
	id numeric DEFAULT nextval('payroll.pgwsq_iface_job'::regclass) NOT NULL,
	iface_id numeric NOT NULL,
	run_time timestamptz DEFAULT now() NULL,
	status_code varchar(20) NOT NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT pgwtb_iface_job_pk PRIMARY KEY (id),
	CONSTRAINT pgwtb_iface_job_fk_iface_def FOREIGN KEY (iface_id) REFERENCES payroll.pgwtb_iface_def(id)
);
COMMENT ON TABLE payroll.pgwtb_iface_job IS 'Interface job execution log — one row per triggered run of an interface';

-- Permissions

ALTER TABLE payroll.pgwtb_iface_job OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.pgwtb_iface_job TO apipayroll;


-- payroll.ppetb_element_dependency definition

-- Drop table

-- DROP TABLE payroll.ppetb_element_dependency;

CREATE TABLE payroll.ppetb_element_dependency (
	id numeric DEFAULT nextval('payroll.ppesq_element_dependency'::regclass) NOT NULL,
	element_id numeric NOT NULL, -- Element phụ thuộc: element này cần được tính SAU depends_on_element_id
	element_code varchar(50) NULL,
	depends_on_element_id numeric NOT NULL, -- Element phải tính TRƯỚC. Vd: PIT depends_on GROSS_SALARY, BHXH_EMPLOYEE, BHYT_EMPLOYEE, BHTN_EMPLOYEE
	depends_on_element_code varchar(50) NULL,
	dependency_type varchar(20) NOT NULL, -- REQUIRES_OUTPUT: cần kết quả tính. USES_BALANCE: cần giá trị balance. SEQUENCED_AFTER: đơn giản về thứ tự tính
	is_active bool DEFAULT true NULL, -- false = tạm vô hiệu hóa ràng buộc (không xóa để lưu lịch sử)
	description text NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_element_dependency_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_element_dependency_uk UNIQUE (element_id, depends_on_element_id),
	CONSTRAINT ppetb_element_dependency_fk_depends_on FOREIGN KEY (depends_on_element_id) REFERENCES payroll.ppmtb_pay_element(id),
	CONSTRAINT ppetb_element_dependency_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id)
);
CREATE INDEX ppetb_element_dependency_idx_dep_type ON payroll.ppetb_element_dependency USING btree (dependency_type);
CREATE INDEX ppetb_element_dependency_idx_depends_on ON payroll.ppetb_element_dependency USING btree (depends_on_element_id);
COMMENT ON TABLE payroll.ppetb_element_dependency IS 'NEW V4: Defines calculation order DAG for pay_elements. Engine uses this to topologically sort calculation order. Prevents circular dependency by design.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_element_dependency.element_id IS 'Element phụ thuộc: element này cần được tính SAU depends_on_element_id';
COMMENT ON COLUMN payroll.ppetb_element_dependency.depends_on_element_id IS 'Element phải tính TRƯỚC. Vd: PIT depends_on GROSS_SALARY, BHXH_EMPLOYEE, BHYT_EMPLOYEE, BHTN_EMPLOYEE';
COMMENT ON COLUMN payroll.ppetb_element_dependency.dependency_type IS 'REQUIRES_OUTPUT: cần kết quả tính. USES_BALANCE: cần giá trị balance. SEQUENCED_AFTER: đơn giản về thứ tự tính';
COMMENT ON COLUMN payroll.ppetb_element_dependency.is_active IS 'false = tạm vô hiệu hóa ràng buộc (không xóa để lưu lịch sử)';
COMMENT ON COLUMN payroll.ppetb_element_dependency.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_element_dependency.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_element_dependency OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_element_dependency TO apipayroll;


-- payroll.ppetb_input_source_config definition

-- Drop table

-- DROP TABLE payroll.ppetb_input_source_config;

CREATE TABLE payroll.ppetb_input_source_config (
	id numeric DEFAULT nextval('payroll.ppesq_input_source_config'::regclass) NOT NULL,
	source_module varchar(30) NOT NULL, -- Module nguồn dữ liệu: TIME_ATTENDANCE | ABSENCE | COMPENSATION | BENEFITS | MANUAL
	source_type varchar(50) NOT NULL, -- Loại dữ liệu cụ thể: TIMESHEET | LEAVE_DEDUCTION | COMP_BASIS_CHANGE | BENEFIT_PREMIUM
	target_element_id numeric NOT NULL, -- FK tới ppmtb_pay_element: element nhận input từ source này
	target_element_code varchar(50) NULL,
	mapping_json jsonb NULL, -- Cấu hình ánh xạ: {"source_field":"ot_weekday_hours","input_code":"HOURS","transform":"identity"}
	is_active bool DEFAULT true NULL,
	priority int2 DEFAULT 0 NULL, -- 0 = cao nhất. Dùng khi nhiều source config cùng target element (override order)
	description text NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_input_source_config_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_input_source_config_uk UNIQUE (source_module, source_type, target_element_id),
	CONSTRAINT ppetb_input_source_config_fk_element FOREIGN KEY (target_element_id) REFERENCES payroll.ppmtb_pay_element(id)
);
CREATE INDEX ppetb_input_source_config_idx_element ON payroll.ppetb_input_source_config USING btree (target_element_id);
COMMENT ON TABLE payroll.ppetb_input_source_config IS 'NEW V4: Reference config for automated input collection. Maps (source_module × source_type) → target pay_element. Reduces manual data entry in input_collection step.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_input_source_config.source_module IS 'Module nguồn dữ liệu: TIME_ATTENDANCE | ABSENCE | COMPENSATION | BENEFITS | MANUAL';
COMMENT ON COLUMN payroll.ppetb_input_source_config.source_type IS 'Loại dữ liệu cụ thể: TIMESHEET | LEAVE_DEDUCTION | COMP_BASIS_CHANGE | BENEFIT_PREMIUM';
COMMENT ON COLUMN payroll.ppetb_input_source_config.target_element_id IS 'FK tới ppmtb_pay_element: element nhận input từ source này';
COMMENT ON COLUMN payroll.ppetb_input_source_config.mapping_json IS 'Cấu hình ánh xạ: {"source_field":"ot_weekday_hours","input_code":"HOURS","transform":"identity"}';
COMMENT ON COLUMN payroll.ppetb_input_source_config.priority IS '0 = cao nhất. Dùng khi nhiều source config cùng target element (override order)';
COMMENT ON COLUMN payroll.ppetb_input_source_config.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_input_source_config.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_input_source_config OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_input_source_config TO apipayroll;


-- payroll.ppmtb_balance_def definition

-- Drop table

-- DROP TABLE payroll.ppmtb_balance_def;

CREATE TABLE payroll.ppmtb_balance_def (
	id numeric DEFAULT nextval('payroll.ppmsq_balance_def'::regclass) NOT NULL, -- ID hệ thống
	code varchar(50) NOT NULL, -- Mã balance (GROSS, NET, YTD_INC)
	"name" varchar(100) NOT NULL, -- Tên balance
	balance_type varchar(20) NOT NULL, -- Loại balance (RUN, QTD, YTD, LTD)
	formula_json jsonb NULL,
	reset_freq_id numeric NULL, -- Tần suất reset balance - liên kết đến chu kỳ trả lương
	reset_freq_code varchar(20) NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực (SCD2)
	effective_end timestamptz NULL, -- Ngày hết hiệu lực (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ xác định bản ghi hiện hành (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_balance_def_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_balance_def_uk UNIQUE (id, code),
	CONSTRAINT ppmtb_balance_def_fk_reset_freq FOREIGN KEY (reset_freq_id) REFERENCES payroll.ppmtb_pay_frequency(id)
);
COMMENT ON TABLE payroll.ppmtb_balance_def IS 'CHANGED JUL 2025. Bảng định nghĩa balance trong hệ thống payroll (GROSS, NET, YTD_INC...)';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_balance_def.id IS 'ID hệ thống';
COMMENT ON COLUMN payroll.ppmtb_balance_def.code IS 'Mã balance (GROSS, NET, YTD_INC)';
COMMENT ON COLUMN payroll.ppmtb_balance_def."name" IS 'Tên balance';
COMMENT ON COLUMN payroll.ppmtb_balance_def.balance_type IS 'Loại balance (RUN, QTD, YTD, LTD)';
COMMENT ON COLUMN payroll.ppmtb_balance_def.reset_freq_id IS 'Tần suất reset balance - liên kết đến chu kỳ trả lương';
COMMENT ON COLUMN payroll.ppmtb_balance_def.effective_start IS 'Ngày hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_balance_def.effective_end IS 'Ngày hết hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_balance_def.current_flg IS 'Cờ xác định bản ghi hiện hành (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_balance_def OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_balance_def TO apipayroll;


-- payroll.ppmtb_gl_mapping definition

-- Drop table

-- DROP TABLE payroll.ppmtb_gl_mapping;

CREATE TABLE payroll.ppmtb_gl_mapping (
	id numeric DEFAULT nextval('payroll.ppmsq_gl_mapping'::regclass) NOT NULL,
	element_id numeric NOT NULL, -- Tham chiếu đến pay_element.id
	element_code varchar(50) NOT NULL, -- Mã phần tử lương (pay_element.code)
	gl_account_code varchar(105) NOT NULL, -- Mã tài khoản kế toán GL
	active_flg bool DEFAULT true NULL, -- Cờ hiệu lực logic
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày bắt đầu hiệu lực (SCD2)
	effective_end timestamptz NULL, -- Ngày kết thúc hiệu lực (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_gl_mapping_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_gl_mapping_uk UNIQUE (id, element_code),
	CONSTRAINT ppmtb_gl_mapping_element_fk FOREIGN KEY (element_id,element_code) REFERENCES payroll.ppmtb_pay_element(id,code)
);
COMMENT ON TABLE payroll.ppmtb_gl_mapping IS 'CHANGED JUL 2025. Mapping element với tài khoản kế toán (GL).';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_gl_mapping.element_id IS 'Tham chiếu đến pay_element.id';
COMMENT ON COLUMN payroll.ppmtb_gl_mapping.element_code IS 'Mã phần tử lương (pay_element.code)';
COMMENT ON COLUMN payroll.ppmtb_gl_mapping.gl_account_code IS 'Mã tài khoản kế toán GL';
COMMENT ON COLUMN payroll.ppmtb_gl_mapping.active_flg IS 'Cờ hiệu lực logic';
COMMENT ON COLUMN payroll.ppmtb_gl_mapping.effective_start IS 'Ngày bắt đầu hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_gl_mapping.effective_end IS 'Ngày kết thúc hiệu lực (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_gl_mapping.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_gl_mapping OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_gl_mapping TO apipayroll;


-- payroll.ppmtb_pay_benefit_link definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_benefit_link;

CREATE TABLE payroll.ppmtb_pay_benefit_link (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_benefit_link'::regclass) NOT NULL,
	pay_element_id numeric NOT NULL, -- Tham chiếu đến phần tử lương (ID)
	pay_element_code varchar(50) NULL, -- Mã phần tử lương (code)
	benefit_policy_code varchar(50) NOT NULL, -- Mã chính sách benefit liên kết
	benefit_type varchar(50) NOT NULL, -- Loại benefit: ALLOWANCE | BENEFIT | BONUS
	valid_from date NOT NULL, -- Ngày bắt đầu hiệu lực logic
	valid_to date NULL, -- Ngày kết thúc hiệu lực logic
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu (SCD2)
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_benefit_link_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_benefit_link_element_fk FOREIGN KEY (pay_element_id,pay_element_code) REFERENCES payroll.ppmtb_pay_element(id,code)
);
COMMENT ON TABLE payroll.ppmtb_pay_benefit_link IS 'CHANGED JUL 2025. Mapping element với policy benefit/allowance, cho phép linked policy.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.pay_element_id IS 'Tham chiếu đến phần tử lương (ID)';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.pay_element_code IS 'Mã phần tử lương (code)';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.benefit_policy_code IS 'Mã chính sách benefit liên kết';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.benefit_type IS 'Loại benefit: ALLOWANCE | BENEFIT | BONUS';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.valid_from IS 'Ngày bắt đầu hiệu lực logic';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.valid_to IS 'Ngày kết thúc hiệu lực logic';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.effective_start IS 'Ngày hiệu lực bắt đầu (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.effective_end IS 'Ngày hiệu lực kết thúc (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_benefit_link.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_benefit_link OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_benefit_link TO apipayroll;


-- payroll.ppmtb_pay_profile definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_profile;

CREATE TABLE payroll.ppmtb_pay_profile (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_profile'::regclass) NOT NULL, -- ID định danh duy nhất
	code varchar(50) NOT NULL, -- Mã hồ sơ lương (profile)
	"name" varchar(100) NOT NULL, -- Tên hồ sơ lương
	legal_entity_id numeric NULL, -- Tham chiếu đơn vị pháp lý (ID)
	legal_entity_code varchar(50) NULL,
	market_id numeric NULL, -- Tham chiếu thị trường áp dụng (ID)
	market_code varchar(50) NULL,
	status_code varchar(20) DEFAULT 'ACTIVE'::character varying NULL, -- Trạng thái hồ sơ: ACTIVE | INACTIVE | DRAFT
	parent_profile_id numeric NULL, -- NEW 27Mar2026: Profile cha để kế thừa cấu hình. NULL = root profile
	pay_method varchar(30) DEFAULT 'MONTHLY_SALARY'::character varying NOT NULL, -- NEW 27Mar2026: Phương pháp tính lương: MONTHLY_SALARY | HOURLY | PIECE_RATE | GRADE_STEP | TASK_BASED
	grade_step_mode varchar(25) NULL, -- NEW 27Mar2026: AQ-14: TABLE_LOOKUP | COEFFICIENT_FORMULA (chỉ khi pay_method = GRADE_STEP)
	pay_scale_table_code varchar(50) NULL, -- NEW 27Mar2026: AQ-14: Mã bảng lương tham chiếu đến TR.grade_ladder.code
	proration_method varchar(20) DEFAULT 'WORK_DAYS'::character varying NOT NULL, -- NEW 27Mar2026: Phương pháp phân bổ: CALENDAR_DAYS | WORK_DAYS | NONE
	rounding_method varchar(20) DEFAULT 'ROUND_HALF_UP'::character varying NOT NULL, -- NEW 27Mar2026: Phương pháp làm tròn: ROUND_HALF_UP | ROUND_DOWN | ROUND_UP | ROUND_NEAREST
	payment_method varchar(20) DEFAULT 'BANK_TRANSFER'::character varying NOT NULL, -- NEW 27Mar2026: Phương thức chi trả: BANK_TRANSFER | CASH | CHECK | WALLET
	default_currency bpchar(3) NULL, -- NEW 27Mar2026: Tiền tệ mặc định (NULL = kế thừa từ pay_group)
	min_wage_rule_id numeric NULL, -- NEW 27Mar2026: FK tới ppmtb_statutory_rule cho lương tối thiểu vùng
	min_wage_rule_code varchar(50) NULL,
	default_calendar_id numeric NULL, -- NEW 27Mar2026: Lịch lương mặc định nếu không được override bởi pay_group
	default_calendar_code varchar(50) NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu (SCD2)
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_profile_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_profile_uk UNIQUE (id, code),
	CONSTRAINT ppmtb_pay_profile_fk_calendar FOREIGN KEY (default_calendar_id) REFERENCES payroll.ppmtb_pay_calendar(id),
	CONSTRAINT ppmtb_pay_profile_fk_min_wage FOREIGN KEY (min_wage_rule_id) REFERENCES payroll.ppmtb_statutory_rule(id),
	CONSTRAINT ppmtb_pay_profile_fk_parent FOREIGN KEY (parent_profile_id) REFERENCES payroll.ppmtb_pay_profile(id)
);
CREATE INDEX ppmtb_pay_profile_idx_le_market ON payroll.ppmtb_pay_profile USING btree (legal_entity_id, market_id);
CREATE INDEX ppmtb_pay_profile_idx_min_wage ON payroll.ppmtb_pay_profile USING btree (min_wage_rule_id);
CREATE INDEX ppmtb_pay_profile_idx_parent ON payroll.ppmtb_pay_profile USING btree (parent_profile_id);
CREATE INDEX ppmtb_pay_profile_idx_pay_method ON payroll.ppmtb_pay_profile USING btree (pay_method);
COMMENT ON TABLE payroll.ppmtb_pay_profile IS 'CHANGED JUL 2025. ENRICHED 27Mar2026 — AQ-02 Option C. Central configuration bundle for worker groups. Explicit columns enable DB-level validation.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_profile.id IS 'ID định danh duy nhất';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.code IS 'Mã hồ sơ lương (profile)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile."name" IS 'Tên hồ sơ lương';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.legal_entity_id IS 'Tham chiếu đơn vị pháp lý (ID)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.market_id IS 'Tham chiếu thị trường áp dụng (ID)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.status_code IS 'Trạng thái hồ sơ: ACTIVE | INACTIVE | DRAFT';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.parent_profile_id IS 'NEW 27Mar2026: Profile cha để kế thừa cấu hình. NULL = root profile';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.pay_method IS 'NEW 27Mar2026: Phương pháp tính lương: MONTHLY_SALARY | HOURLY | PIECE_RATE | GRADE_STEP | TASK_BASED';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.grade_step_mode IS 'NEW 27Mar2026: AQ-14: TABLE_LOOKUP | COEFFICIENT_FORMULA (chỉ khi pay_method = GRADE_STEP)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.pay_scale_table_code IS 'NEW 27Mar2026: AQ-14: Mã bảng lương tham chiếu đến TR.grade_ladder.code';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.proration_method IS 'NEW 27Mar2026: Phương pháp phân bổ: CALENDAR_DAYS | WORK_DAYS | NONE';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.rounding_method IS 'NEW 27Mar2026: Phương pháp làm tròn: ROUND_HALF_UP | ROUND_DOWN | ROUND_UP | ROUND_NEAREST';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.payment_method IS 'NEW 27Mar2026: Phương thức chi trả: BANK_TRANSFER | CASH | CHECK | WALLET';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.default_currency IS 'NEW 27Mar2026: Tiền tệ mặc định (NULL = kế thừa từ pay_group)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.min_wage_rule_id IS 'NEW 27Mar2026: FK tới ppmtb_statutory_rule cho lương tối thiểu vùng';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.default_calendar_id IS 'NEW 27Mar2026: Lịch lương mặc định nếu không được override bởi pay_group';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.effective_start IS 'Ngày hiệu lực bắt đầu (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.effective_end IS 'Ngày hiệu lực kết thúc (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_profile OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_profile TO apipayroll;


-- payroll.ppmtb_pay_profile_element definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_profile_element;

CREATE TABLE payroll.ppmtb_pay_profile_element (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_profile_element'::regclass) NOT NULL, -- ID định danh duy nhất
	profile_id numeric NOT NULL, -- FK tới ppmtb_pay_profile
	profile_code varchar(50) NULL,
	element_id numeric NOT NULL, -- FK tới ppmtb_pay_element
	element_code varchar(50) NULL,
	is_mandatory bool DEFAULT false NULL, -- Element bắt buộc trong profile? true = luôn tính element này cho profile
	priority_order int2 NULL, -- Override priority_order của pay_element trong context profile này
	default_amount numeric(18, 2) NULL, -- Giá trị mặc định cho element trong profile
	override_formula_json jsonb NULL, -- Override công thức riêng cho profile (NULL = dùng element default)
	active_flg bool DEFAULT true NULL, -- Cờ hiệu lực
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_profile_element_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_profile_element_uk UNIQUE (profile_id, element_id),
	CONSTRAINT ppmtb_pay_profile_element_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id),
	CONSTRAINT ppmtb_pay_profile_element_fk_profile FOREIGN KEY (profile_id) REFERENCES payroll.ppmtb_pay_profile(id)
);
CREATE INDEX ppmtb_pay_profile_element_idx_element ON payroll.ppmtb_pay_profile_element USING btree (element_id);
CREATE INDEX ppmtb_pay_profile_element_idx_profile_active ON payroll.ppmtb_pay_profile_element USING btree (profile_id, active_flg);
COMMENT ON TABLE payroll.ppmtb_pay_profile_element IS 'NEW 27Mar2026: AQ-02 Option C — Element binding join table. Defines which pay_elements are included in a pay_profile.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.id IS 'ID định danh duy nhất';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.profile_id IS 'FK tới ppmtb_pay_profile';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.element_id IS 'FK tới ppmtb_pay_element';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.is_mandatory IS 'Element bắt buộc trong profile? true = luôn tính element này cho profile';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.priority_order IS 'Override priority_order của pay_element trong context profile này';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.default_amount IS 'Giá trị mặc định cho element trong profile';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.override_formula_json IS 'Override công thức riêng cho profile (NULL = dùng element default)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.active_flg IS 'Cờ hiệu lực';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.effective_start IS 'Ngày hiệu lực bắt đầu';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.effective_end IS 'Ngày hiệu lực kết thúc';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.current_flg IS 'Cờ bản ghi hiện hành';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_element.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_profile_element OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_profile_element TO apipayroll;


-- payroll.ppmtb_pay_profile_map definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_profile_map;

CREATE TABLE payroll.ppmtb_pay_profile_map (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_profile_map'::regclass) NOT NULL,
	code varchar(50) NULL,
	pay_profile_id numeric NOT NULL, -- Tham chiếu đến profile lương
	pay_profile_code varchar(50) NULL,
	pay_group_id numeric NULL, -- Tham chiếu đến nhóm trả lương
	pay_group_code varchar(50) NULL,
	employee_id numeric NULL, -- Tham chiếu đến nhân viên (nếu áp dụng)
	period_start date NOT NULL, -- Ngày bắt đầu áp dụng theo kỳ
	period_end date NULL, -- Ngày kết thúc áp dụng theo kỳ
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu (SCD2)
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc (SCD2)
	current_flg bool DEFAULT true NULL, -- Cờ đánh dấu bản ghi hiện tại (SCD2)
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_profile_map_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_profile_map_uk UNIQUE (id, code),
	CONSTRAINT ppmtb_pay_profile_map_fk_group FOREIGN KEY (pay_group_id) REFERENCES payroll.ppmtb_pay_group(id),
	CONSTRAINT ppmtb_pay_profile_map_fk_profile FOREIGN KEY (pay_profile_id) REFERENCES payroll.ppmtb_pay_profile(id)
);
COMMENT ON TABLE payroll.ppmtb_pay_profile_map IS 'Mapping profile với pay group/employee nếu cần. Optional – mở rộng future.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.pay_profile_id IS 'Tham chiếu đến profile lương';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.pay_group_id IS 'Tham chiếu đến nhóm trả lương';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.employee_id IS 'Tham chiếu đến nhân viên (nếu áp dụng)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.period_start IS 'Ngày bắt đầu áp dụng theo kỳ';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.period_end IS 'Ngày kết thúc áp dụng theo kỳ';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.effective_start IS 'Ngày hiệu lực bắt đầu (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.effective_end IS 'Ngày hiệu lực kết thúc (SCD2)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_map.current_flg IS 'Cờ đánh dấu bản ghi hiện tại (SCD2)';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_profile_map OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_profile_map TO apipayroll;


-- payroll.ppmtb_pay_profile_rate_config definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_profile_rate_config;

CREATE TABLE payroll.ppmtb_pay_profile_rate_config (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_profile_rate_config'::regclass) NOT NULL,
	pay_profile_id numeric NOT NULL, -- FK tới ppmtb_pay_profile
	pay_profile_code varchar(50) NULL,
	rate_dimension varchar(30) NOT NULL, -- Loại giờ làm việc: REGULAR | NIGHT | OT_WEEKDAY | OT_WEEKEND | OT_HOLIDAY | HAZARDOUS | SPECIALIZED
	rate_type varchar(20) DEFAULT 'FIXED'::character varying NOT NULL, -- FIXED: base_rate_amount là giá tuyệt đối (VND/h). MULTIPLIER: hệ số × regular rate. FORMULA: tính qua formula_id
	base_rate_amount numeric(15, 4) NULL, -- VND/h (nếu FIXED) hoặc hệ số nhân (nếu MULTIPLIER). NULL nếu FORMULA
	currency_code bpchar(3) DEFAULT 'VND'::bpchar NULL, -- Đơn vị tiền tệ (mặc định VND)
	formula_id numeric NULL, -- FK tới ppmtb_pay_formula (nếu rate_type = FORMULA)
	formula_code varchar(50) NULL,
	statutory_rule_id numeric NULL, -- FK tới ppmtb_statutory_rule. Dùng cho OT dimensions (vd: VN_OT_WEEKDAY = 1.5)
	statutory_rule_code varchar(50) NULL,
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_profile_rate_config_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_profile_rate_config_uk UNIQUE (pay_profile_id, rate_dimension),
	CONSTRAINT ppmtb_pay_profile_rate_config_fk_formula FOREIGN KEY (formula_id) REFERENCES payroll.ppmtb_pay_formula(id),
	CONSTRAINT ppmtb_pay_profile_rate_config_fk_profile FOREIGN KEY (pay_profile_id) REFERENCES payroll.ppmtb_pay_profile(id),
	CONSTRAINT ppmtb_pay_profile_rate_config_fk_rule FOREIGN KEY (statutory_rule_id) REFERENCES payroll.ppmtb_statutory_rule(id)
);
CREATE INDEX ppmtb_pay_profile_rate_config_idx_dim_date ON payroll.ppmtb_pay_profile_rate_config USING btree (pay_profile_id, rate_dimension, effective_start);
CREATE INDEX ppmtb_pay_profile_rate_config_idx_dimension ON payroll.ppmtb_pay_profile_rate_config USING btree (rate_dimension);
CREATE INDEX ppmtb_pay_profile_rate_config_idx_rule ON payroll.ppmtb_pay_profile_rate_config USING btree (statutory_rule_id);
COMMENT ON TABLE payroll.ppmtb_pay_profile_rate_config IS 'NEW 27Mar2026: AQ-12 Hybrid C+D — Profile-level default rates (Layer 2). Defines base rate per hour-type dimension for all workers in this PayProfile.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.pay_profile_id IS 'FK tới ppmtb_pay_profile';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.rate_dimension IS 'Loại giờ làm việc: REGULAR | NIGHT | OT_WEEKDAY | OT_WEEKEND | OT_HOLIDAY | HAZARDOUS | SPECIALIZED';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.rate_type IS 'FIXED: base_rate_amount là giá tuyệt đối (VND/h). MULTIPLIER: hệ số × regular rate. FORMULA: tính qua formula_id';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.base_rate_amount IS 'VND/h (nếu FIXED) hoặc hệ số nhân (nếu MULTIPLIER). NULL nếu FORMULA';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.currency_code IS 'Đơn vị tiền tệ (mặc định VND)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.formula_id IS 'FK tới ppmtb_pay_formula (nếu rate_type = FORMULA)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.statutory_rule_id IS 'FK tới ppmtb_statutory_rule. Dùng cho OT dimensions (vd: VN_OT_WEEKDAY = 1.5)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.effective_start IS 'Ngày hiệu lực bắt đầu';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.effective_end IS 'Ngày hiệu lực kết thúc';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.current_flg IS 'Cờ bản ghi hiện hành';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rate_config.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_profile_rate_config OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_profile_rate_config TO apipayroll;


-- payroll.ppmtb_pay_profile_rule definition

-- Drop table

-- DROP TABLE payroll.ppmtb_pay_profile_rule;

CREATE TABLE payroll.ppmtb_pay_profile_rule (
	id numeric DEFAULT nextval('payroll.ppmsq_pay_profile_rule'::regclass) NOT NULL,
	profile_id numeric NOT NULL, -- FK tới ppmtb_pay_profile
	profile_code varchar(50) NULL,
	rule_id numeric NOT NULL, -- FK tới ppmtb_statutory_rule
	rule_code varchar(50) NULL,
	rule_scope varchar(30) NOT NULL, -- Phạm vi rule: TAX | SOCIAL_INSURANCE | OVERTIME | GROSS_TO_NET
	execution_order int2 DEFAULT 0 NULL, -- Thứ tự thực thi trong pipeline tính lương (1=SI, 2=PIT, 3=G2N)
	override_params jsonb NULL, -- Override tham số riêng cho profile (vd: special tax bracket JSON)
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_pay_profile_rule_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_pay_profile_rule_uk UNIQUE (profile_id, rule_id),
	CONSTRAINT ppmtb_pay_profile_rule_fk_profile FOREIGN KEY (profile_id) REFERENCES payroll.ppmtb_pay_profile(id),
	CONSTRAINT ppmtb_pay_profile_rule_fk_rule FOREIGN KEY (rule_id) REFERENCES payroll.ppmtb_statutory_rule(id)
);
CREATE INDEX ppmtb_pay_profile_rule_idx_rule ON payroll.ppmtb_pay_profile_rule USING btree (rule_id);
CREATE INDEX ppmtb_pay_profile_rule_idx_scope_order ON payroll.ppmtb_pay_profile_rule USING btree (profile_id, rule_scope, execution_order);
COMMENT ON TABLE payroll.ppmtb_pay_profile_rule IS 'NEW 27Mar2026: AQ-02 Option C — Statutory rule binding join table. Defines which statutory_rules apply to a pay_profile.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.profile_id IS 'FK tới ppmtb_pay_profile';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.rule_id IS 'FK tới ppmtb_statutory_rule';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.rule_scope IS 'Phạm vi rule: TAX | SOCIAL_INSURANCE | OVERTIME | GROSS_TO_NET';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.execution_order IS 'Thứ tự thực thi trong pipeline tính lương (1=SI, 2=PIT, 3=G2N)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.override_params IS 'Override tham số riêng cho profile (vd: special tax bracket JSON)';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.effective_start IS 'Ngày hiệu lực bắt đầu';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.effective_end IS 'Ngày hiệu lực kết thúc';
COMMENT ON COLUMN payroll.ppmtb_pay_profile_rule.current_flg IS 'Cờ bản ghi hiện hành';

-- Permissions

ALTER TABLE payroll.ppmtb_pay_profile_rule OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_pay_profile_rule TO apipayroll;


-- payroll.ppmtb_piece_rate_config definition

-- Drop table

-- DROP TABLE payroll.ppmtb_piece_rate_config;

CREATE TABLE payroll.ppmtb_piece_rate_config (
	id numeric DEFAULT nextval('payroll.ppmsq_piece_rate_config'::regclass) NOT NULL,
	pay_profile_id numeric NULL, -- FK tới ppmtb_pay_profile. NULL = global rate; non-null = profile-specific override
	pay_profile_code varchar(50) NULL,
	product_code varchar(50) NOT NULL, -- Mã sản phẩm: SHIRT | SHOE | PCB_BOARD | ASSEMBLY_UNIT_A
	product_name varchar(150) NULL, -- Tên sản phẩm hiển thị
	quality_grade varchar(30) DEFAULT 'STANDARD'::character varying NOT NULL, -- Cấp chất lượng: STANDARD | GRADE_A | GRADE_B | GRADE_C | REJECT
	rate_per_unit numeric(15, 4) NOT NULL, -- VND/sản phẩm — giá trực tiếp
	currency_code bpchar(3) DEFAULT 'VND'::bpchar NULL,
	quality_multiplier numeric(5, 3) NULL, -- Hệ số chất lượng (NULL = dùng rate_per_unit trực tiếp). Vd GRADE_A = 1.2 × base rate
	unit_code varchar(20) DEFAULT 'PIECE'::character varying NULL, -- Đơn vị đo lường: PIECE | KG | METER | PAIR | SET
	min_wage_rule_id numeric NULL, -- FK tới ppmtb_statutory_rule cho lương tối thiểu vùng
	min_wage_rule_code varchar(50) NULL,
	ot_multiplier_rule_id numeric NULL, -- FK tới ppmtb_statutory_rule cho hệ số OT (vd: VN_OT_MULTIPLIER)
	ot_multiplier_rule_code varchar(50) NULL,
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_piece_rate_config_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_piece_rate_config_uk UNIQUE (pay_profile_id, product_code, quality_grade),
	CONSTRAINT ppmtb_piece_rate_config_fk_min_wage FOREIGN KEY (min_wage_rule_id) REFERENCES payroll.ppmtb_statutory_rule(id),
	CONSTRAINT ppmtb_piece_rate_config_fk_ot FOREIGN KEY (ot_multiplier_rule_id) REFERENCES payroll.ppmtb_statutory_rule(id),
	CONSTRAINT ppmtb_piece_rate_config_fk_profile FOREIGN KEY (pay_profile_id) REFERENCES payroll.ppmtb_pay_profile(id)
);
CREATE INDEX ppmtb_piece_rate_config_idx_product_date ON payroll.ppmtb_piece_rate_config USING btree (product_code, effective_start);
CREATE INDEX ppmtb_piece_rate_config_idx_product_grade ON payroll.ppmtb_piece_rate_config USING btree (product_code, quality_grade);
CREATE INDEX ppmtb_piece_rate_config_idx_profile_active ON payroll.ppmtb_piece_rate_config USING btree (pay_profile_id, active_flg);
COMMENT ON TABLE payroll.ppmtb_piece_rate_config IS 'NEW 27Mar2026: AQ-13 Option C — Piece-Rate Configuration. Rate lookup table cho lương sản phẩm: (product × quality_grade) → rate_per_unit.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.pay_profile_id IS 'FK tới ppmtb_pay_profile. NULL = global rate; non-null = profile-specific override';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.product_code IS 'Mã sản phẩm: SHIRT | SHOE | PCB_BOARD | ASSEMBLY_UNIT_A';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.product_name IS 'Tên sản phẩm hiển thị';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.quality_grade IS 'Cấp chất lượng: STANDARD | GRADE_A | GRADE_B | GRADE_C | REJECT';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.rate_per_unit IS 'VND/sản phẩm — giá trực tiếp';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.quality_multiplier IS 'Hệ số chất lượng (NULL = dùng rate_per_unit trực tiếp). Vd GRADE_A = 1.2 × base rate';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.unit_code IS 'Đơn vị đo lường: PIECE | KG | METER | PAIR | SET';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.min_wage_rule_id IS 'FK tới ppmtb_statutory_rule cho lương tối thiểu vùng';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.ot_multiplier_rule_id IS 'FK tới ppmtb_statutory_rule cho hệ số OT (vd: VN_OT_MULTIPLIER)';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.effective_start IS 'Ngày hiệu lực bắt đầu';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.effective_end IS 'Ngày hiệu lực kết thúc';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.current_flg IS 'Cờ bản ghi hiện hành';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_piece_rate_config.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppmtb_piece_rate_config OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_piece_rate_config TO apipayroll;


-- payroll.ppmtb_termination_pay_config definition

-- Drop table

-- DROP TABLE payroll.ppmtb_termination_pay_config;

CREATE TABLE payroll.ppmtb_termination_pay_config (
	id numeric DEFAULT nextval('payroll.ppmsq_termination_pay_config'::regclass) NOT NULL,
	pay_profile_id numeric NOT NULL, -- FK tới ppmtb_pay_profile
	pay_profile_code varchar(50) NULL,
	termination_type varchar(30) NOT NULL, -- Loại nghỉ việc: RESIGNATION | MUTUAL_AGREEMENT | REDUCTION_IN_FORCE | END_OF_CONTRACT | DISMISSAL | RETIREMENT
	element_id numeric NOT NULL, -- FK tới ppmtb_pay_element để tính trong final-pay
	element_code varchar(50) NULL,
	is_mandatory bool DEFAULT true NULL, -- Element bắt buộc phải có trong final-pay?
	execution_order int2 DEFAULT 0 NULL, -- Thứ tự tính toán (1=proration, 2=leave_payout, 3=13th_month, 4=severance)
	formula_override_json jsonb NULL, -- Override công thức cho context termination. Vd severance: {"formula":"tenure_years*coefficient*avg_monthly_salary"}
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_termination_pay_config_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_termination_pay_config_uk UNIQUE (pay_profile_id, termination_type, element_id),
	CONSTRAINT ppmtb_termination_pay_config_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id),
	CONSTRAINT ppmtb_termination_pay_config_fk_profile FOREIGN KEY (pay_profile_id) REFERENCES payroll.ppmtb_pay_profile(id)
);
CREATE INDEX ppmtb_termination_pay_config_idx_element ON payroll.ppmtb_termination_pay_config USING btree (element_id);
CREATE INDEX ppmtb_termination_pay_config_idx_type ON payroll.ppmtb_termination_pay_config USING btree (termination_type);
CREATE INDEX ppmtb_termination_pay_config_idx_type_order ON payroll.ppmtb_termination_pay_config USING btree (pay_profile_id, termination_type, execution_order);
COMMENT ON TABLE payroll.ppmtb_termination_pay_config IS 'NEW 27Mar2026: AQ-10 Option D — Termination Pay Configuration. Maps (termination_type × pay_profile) → list of PayElements for final-pay run.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.pay_profile_id IS 'FK tới ppmtb_pay_profile';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.termination_type IS 'Loại nghỉ việc: RESIGNATION | MUTUAL_AGREEMENT | REDUCTION_IN_FORCE | END_OF_CONTRACT | DISMISSAL | RETIREMENT';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.element_id IS 'FK tới ppmtb_pay_element để tính trong final-pay';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.is_mandatory IS 'Element bắt buộc phải có trong final-pay?';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.execution_order IS 'Thứ tự tính toán (1=proration, 2=leave_payout, 3=13th_month, 4=severance)';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.formula_override_json IS 'Override công thức cho context termination. Vd severance: {"formula":"tenure_years*coefficient*avg_monthly_salary"}';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.effective_start IS 'Ngày hiệu lực bắt đầu';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.effective_end IS 'Ngày hiệu lực kết thúc';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.current_flg IS 'Cờ bản ghi hiện hành';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_termination_pay_config.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppmtb_termination_pay_config OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_termination_pay_config TO apipayroll;


-- payroll.ppmtb_worker_rate_override definition

-- Drop table

-- DROP TABLE payroll.ppmtb_worker_rate_override;

CREATE TABLE payroll.ppmtb_worker_rate_override (
	id numeric DEFAULT nextval('payroll.ppmsq_worker_rate_override'::regclass) NOT NULL,
	worker_id numeric NOT NULL, -- FK tới employee/worker (payroll.emptb_employee.id)
	worker_code varchar(50) NULL,
	pay_profile_id numeric NOT NULL, -- FK tới ppmtb_pay_profile: override áp dụng trong context profile nào
	pay_profile_code varchar(50) NULL,
	rate_dimension varchar(30) NOT NULL, -- Loại giờ làm việc: REGULAR | NIGHT | OT_WEEKDAY | OT_WEEKEND | OT_HOLIDAY | HAZARDOUS | SPECIALIZED
	override_rate numeric(15, 4) NOT NULL, -- VND/h — giá trị TUYỆT ĐỐI override cho worker này (không phải multiplier)
	currency_code bpchar(3) DEFAULT 'VND'::bpchar NULL,
	reason_code varchar(50) NULL, -- Lý do override: SKILL_PREMIUM | SENIORITY | NEGOTIATED | PROBATION_DISCOUNT | GRADE_ADJUSTMENT
	reason_text text NULL,
	approved_by numeric NULL, -- ID người approve rate override này
	approved_at timestamptz NULL, -- Thời điểm approve
	active_flg bool DEFAULT true NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL, -- Ngày hiệu lực bắt đầu
	effective_end timestamptz NULL, -- Ngày hiệu lực kết thúc
	current_flg bool DEFAULT true NULL, -- Cờ bản ghi hiện hành
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmtb_worker_rate_override_pk PRIMARY KEY (id),
	CONSTRAINT ppmtb_worker_rate_override_uk UNIQUE (worker_id, pay_profile_id, rate_dimension),
	CONSTRAINT ppmtb_worker_rate_override_fk_profile FOREIGN KEY (pay_profile_id) REFERENCES payroll.ppmtb_pay_profile(id)
);
CREATE INDEX ppmtb_worker_rate_override_idx_profile_dim ON payroll.ppmtb_worker_rate_override USING btree (pay_profile_id, rate_dimension);
CREATE INDEX ppmtb_worker_rate_override_idx_worker_active ON payroll.ppmtb_worker_rate_override USING btree (worker_id, active_flg);
CREATE INDEX ppmtb_worker_rate_override_idx_worker_profile ON payroll.ppmtb_worker_rate_override USING btree (worker_id, pay_profile_id);
COMMENT ON TABLE payroll.ppmtb_worker_rate_override IS 'NEW 27Mar2026: AQ-12 Hybrid C+D — Worker-level rate override (Layer 1). Optional: chỉ tạo record cho workers có rate khác biệt với profile default.';

-- Column comments

COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.worker_id IS 'FK tới employee/worker (payroll.emptb_employee.id)';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.pay_profile_id IS 'FK tới ppmtb_pay_profile: override áp dụng trong context profile nào';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.rate_dimension IS 'Loại giờ làm việc: REGULAR | NIGHT | OT_WEEKDAY | OT_WEEKEND | OT_HOLIDAY | HAZARDOUS | SPECIALIZED';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.override_rate IS 'VND/h — giá trị TUYỆT ĐỐI override cho worker này (không phải multiplier)';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.reason_code IS 'Lý do override: SKILL_PREMIUM | SENIORITY | NEGOTIATED | PROBATION_DISCOUNT | GRADE_ADJUSTMENT';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.approved_by IS 'ID người approve rate override này';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.approved_at IS 'Thời điểm approve';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.effective_start IS 'Ngày hiệu lực bắt đầu';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.effective_end IS 'Ngày hiệu lực kết thúc';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.current_flg IS 'Cờ bản ghi hiện hành';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmtb_worker_rate_override.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppmtb_worker_rate_override OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmtb_worker_rate_override TO apipayroll;


-- payroll.ppmttb_pay_period definition

-- Drop table

-- DROP TABLE payroll.ppmttb_pay_period;

CREATE TABLE payroll.ppmttb_pay_period (
	id numeric DEFAULT nextval('payroll.ppmtsq_pay_period'::regclass) NOT NULL, -- Định danh duy nhất
	calendar_id numeric NOT NULL, -- FK tới ppmtb_pay_calendar
	calendar_code varchar(50) NULL,
	period_seq int4 NOT NULL, -- Số thứ tự kỳ trong năm: 1..12 (hoặc 24 nếu bán-nguyệt)
	period_year int2 NOT NULL, -- Năm của kỳ lương
	period_start date NOT NULL, -- Ngày bắt đầu kỳ lương
	period_end date NOT NULL, -- Ngày kết thúc kỳ lương
	pay_date date NOT NULL, -- Ngày thực tế trả lương cho nhân viên
	cut_off_date date NULL, -- Ngày chốt dữ liệu chấm công / phúc lợi. NULL = không có cut-off riêng
	status_code varchar(20) DEFAULT 'FUTURE'::character varying NOT NULL, -- Lifecycle: FUTURE (chưa tới) | OPEN (đang nhận dữ liệu) | PROCESSING (đang chạy engine) | CLOSED (khoá sổ) | ADJUSTED (có bổ sung/retro)
	closed_at timestamptz NULL, -- Thời điểm kỳ được đóng sổ
	closed_by numeric NULL, -- ID nhân viên thực hiện đóng kỳ (FK → emptb_employee.id)
	metadata jsonb NULL, -- Thông tin mở rộng: ghi chú, cờ đặc biệt, số lượng nhân viên...
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Ngày tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmttb_pay_period_pk PRIMARY KEY (id),
	CONSTRAINT ppmttb_pay_period_uk UNIQUE (calendar_id, period_year, period_seq),
	CONSTRAINT ppmttb_pay_period_fk_calendar FOREIGN KEY (calendar_id) REFERENCES payroll.ppmtb_pay_calendar(id)
);
CREATE INDEX ppmttb_pay_period_idx_calendar_status ON payroll.ppmttb_pay_period USING btree (calendar_id, status_code);
CREATE INDEX ppmttb_pay_period_idx_date_range ON payroll.ppmttb_pay_period USING btree (period_start, period_end);
CREATE INDEX ppmttb_pay_period_idx_status ON payroll.ppmttb_pay_period USING btree (status_code);
COMMENT ON TABLE payroll.ppmttb_pay_period IS 'NEW V4: Explicit payroll period aggregate root. Replaces implicit period tracking in V3 pprtb_batch. Lifecycle: FUTURE → OPEN → PROCESSING → CLOSED → ADJUSTED.';

-- Column comments

COMMENT ON COLUMN payroll.ppmttb_pay_period.id IS 'Định danh duy nhất';
COMMENT ON COLUMN payroll.ppmttb_pay_period.calendar_id IS 'FK tới ppmtb_pay_calendar';
COMMENT ON COLUMN payroll.ppmttb_pay_period.period_seq IS 'Số thứ tự kỳ trong năm: 1..12 (hoặc 24 nếu bán-nguyệt)';
COMMENT ON COLUMN payroll.ppmttb_pay_period.period_year IS 'Năm của kỳ lương';
COMMENT ON COLUMN payroll.ppmttb_pay_period.period_start IS 'Ngày bắt đầu kỳ lương';
COMMENT ON COLUMN payroll.ppmttb_pay_period.period_end IS 'Ngày kết thúc kỳ lương';
COMMENT ON COLUMN payroll.ppmttb_pay_period.pay_date IS 'Ngày thực tế trả lương cho nhân viên';
COMMENT ON COLUMN payroll.ppmttb_pay_period.cut_off_date IS 'Ngày chốt dữ liệu chấm công / phúc lợi. NULL = không có cut-off riêng';
COMMENT ON COLUMN payroll.ppmttb_pay_period.status_code IS 'Lifecycle: FUTURE (chưa tới) | OPEN (đang nhận dữ liệu) | PROCESSING (đang chạy engine) | CLOSED (khoá sổ) | ADJUSTED (có bổ sung/retro)';
COMMENT ON COLUMN payroll.ppmttb_pay_period.closed_at IS 'Thời điểm kỳ được đóng sổ';
COMMENT ON COLUMN payroll.ppmttb_pay_period.closed_by IS 'ID nhân viên thực hiện đóng kỳ (FK → emptb_employee.id)';
COMMENT ON COLUMN payroll.ppmttb_pay_period.metadata IS 'Thông tin mở rộng: ghi chú, cờ đặc biệt, số lượng nhân viên...';
COMMENT ON COLUMN payroll.ppmttb_pay_period.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmttb_pay_period.maker_date IS 'Ngày tạo';

-- Permissions

ALTER TABLE payroll.ppmttb_pay_period OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmttb_pay_period TO apipayroll;


-- payroll.pgwtb_iface_file definition

-- Drop table

-- DROP TABLE payroll.pgwtb_iface_file;

CREATE TABLE payroll.pgwtb_iface_file (
	id numeric DEFAULT nextval('payroll.pgwsq_iface_file'::regclass) NOT NULL,
	job_id numeric NOT NULL,
	file_name varchar(255) NOT NULL,
	file_dt timestamptz NOT NULL,
	status_code varchar(20) NOT NULL,
	processed_at timestamptz NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT pgwtb_iface_file_pk PRIMARY KEY (id),
	CONSTRAINT pgwtb_iface_file_uk UNIQUE (tenant_code, job_id, file_name),
	CONSTRAINT pgwtb_iface_file_fk_job FOREIGN KEY (job_id) REFERENCES payroll.pgwtb_iface_job(id)
);
COMMENT ON TABLE payroll.pgwtb_iface_file IS 'Files processed within each interface job run';

-- Permissions

ALTER TABLE payroll.pgwtb_iface_file OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.pgwtb_iface_file TO apipayroll;


-- payroll.pgwtb_iface_line definition

-- Drop table

-- DROP TABLE payroll.pgwtb_iface_line;

CREATE TABLE payroll.pgwtb_iface_line (
	id numeric DEFAULT nextval('payroll.pgwsq_iface_line'::regclass) NOT NULL,
	file_id numeric NOT NULL,
	line_num int4 NOT NULL,
	payload_json jsonb NOT NULL,
	status_code varchar(20) NOT NULL,
	error_msg text NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT pgwtb_iface_line_pk PRIMARY KEY (id),
	CONSTRAINT pgwtb_iface_line_uk UNIQUE (tenant_code, file_id, line_num),
	CONSTRAINT pgwtb_iface_line_fk_file FOREIGN KEY (file_id) REFERENCES payroll.pgwtb_iface_file(id)
);
COMMENT ON TABLE payroll.pgwtb_iface_line IS 'Individual data lines within each interface file — OK or ERROR per row';

-- Permissions

ALTER TABLE payroll.pgwtb_iface_line OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.pgwtb_iface_line TO apipayroll;


-- payroll.ppatb_generated_file definition

-- Drop table

-- DROP TABLE payroll.ppatb_generated_file;

CREATE TABLE payroll.ppatb_generated_file (
	id numeric DEFAULT nextval('payroll.ppasq_generated_file'::regclass) NOT NULL,
	generated_type varchar(20) NOT NULL,
	payroll_run_id numeric NOT NULL,
	employee_id numeric NULL,
	file_name varchar(255) NOT NULL,
	file_path varchar(512) NOT NULL,
	generated_at timestamptz NOT NULL,
	expires_at timestamptz NULL,
	status varchar(35) NOT NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppatb_generated_file_pk PRIMARY KEY (id)
);
COMMENT ON TABLE payroll.ppatb_generated_file IS 'System-generated output files: payment transfers, payslips, and tax reports';

-- Permissions

ALTER TABLE payroll.ppatb_generated_file OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppatb_generated_file TO apipayroll;


-- payroll.ppbtb_payment_batch definition

-- Drop table

-- DROP TABLE payroll.ppbtb_payment_batch;

CREATE TABLE payroll.ppbtb_payment_batch (
	id numeric DEFAULT nextval('payroll.ppbsq_payment_batch'::regclass) NOT NULL,
	run_batch_id numeric NOT NULL,
	bank_account_id numeric NOT NULL,
	file_status varchar(20) NOT NULL,
	submitted_at timestamptz NULL,
	file_url varchar(255) NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppbtb_payment_batch_pk PRIMARY KEY (id),
	CONSTRAINT ppbtb_payment_batch_uk UNIQUE (tenant_code, run_batch_id, bank_account_id)
);
COMMENT ON TABLE payroll.ppbtb_payment_batch IS 'Payment disbursement batches — one per payroll batch × bank account combination';

-- Permissions

ALTER TABLE payroll.ppbtb_payment_batch OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppbtb_payment_batch TO apipayroll;


-- payroll.ppbtb_payment_line definition

-- Drop table

-- DROP TABLE payroll.ppbtb_payment_line;

CREATE TABLE payroll.ppbtb_payment_line (
	id numeric DEFAULT nextval('payroll.ppbsq_payment_line'::regclass) NOT NULL,
	payment_batch_id numeric NOT NULL,
	employee_id numeric NOT NULL,
	net_amount numeric(18, 2) NOT NULL,
	bank_routing varchar(20) NULL,
	account_number varchar(30) NULL,
	status_code varchar(20) NOT NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL,
	maker_date timestamptz NULL,
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppbtb_payment_line_pk PRIMARY KEY (id),
	CONSTRAINT ppbtb_payment_line_uk UNIQUE (tenant_code, payment_batch_id, employee_id)
);
COMMENT ON TABLE payroll.ppbtb_payment_line IS 'Individual employee bank transfer lines within each payment batch';

-- Permissions

ALTER TABLE payroll.ppbtb_payment_line OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppbtb_payment_line TO apipayroll;


-- payroll.ppetb_balance definition

-- Drop table

-- DROP TABLE payroll.ppetb_balance;

CREATE TABLE payroll.ppetb_balance (
	id numeric DEFAULT nextval('payroll.ppesq_balance'::regclass) NOT NULL,
	emp_run_id numeric NOT NULL, -- FK tới ppetb_run_employee
	balance_id numeric NOT NULL, -- FK tới ppmtb_balance_def (GROSS | NET | YTD_INC | SI_EMPLOYEE_YTD...)
	balance_value numeric(18, 2) NOT NULL, -- Giá trị balance sau khi tính lương trong kỳ này
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_balance_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_balance_uk UNIQUE (tenant_code, emp_run_id, balance_id)
);
CREATE INDEX ppetb_balance_idx_emp_balance ON payroll.ppetb_balance USING btree (emp_run_id, balance_id);
COMMENT ON TABLE payroll.ppetb_balance IS 'MIGRATED V3→V4: pprtb_balance → ppetb_balance. Period balance snapshot per worker per run. Source for cumulative_balance updates and payslip reporting.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_balance.emp_run_id IS 'FK tới ppetb_run_employee';
COMMENT ON COLUMN payroll.ppetb_balance.balance_id IS 'FK tới ppmtb_balance_def (GROSS | NET | YTD_INC | SI_EMPLOYEE_YTD...)';
COMMENT ON COLUMN payroll.ppetb_balance.balance_value IS 'Giá trị balance sau khi tính lương trong kỳ này';
COMMENT ON COLUMN payroll.ppetb_balance.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_balance.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_balance OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_balance TO apipayroll;


-- payroll.ppetb_calc_log definition

-- Drop table

-- DROP TABLE payroll.ppetb_calc_log;

CREATE TABLE payroll.ppetb_calc_log (
	id numeric DEFAULT nextval('payroll.ppesq_calc_log'::regclass) NOT NULL,
	emp_run_id numeric NOT NULL, -- FK tới ppetb_run_employee
	step_label varchar(50) NOT NULL, -- Nhãn bước: INPUT_COLLECTION | PRE_CALC | BHXH_EMPLOYEE | BHYT | PIT | NET_PAY...
	message text NOT NULL,
	payload_json jsonb NULL, -- Chi tiết step: {"input":{...},"output":{...},"formula_version":"VN_SI_2025_V1"}
	logged_at timestamptz DEFAULT now() NULL, -- Thời điểm ghi log (có thể khác maker_date nếu batch log)
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_calc_log_pk PRIMARY KEY (id)
);
CREATE INDEX ppetb_calc_log_idx_emp_step ON payroll.ppetb_calc_log USING btree (emp_run_id, step_label);
CREATE INDEX ppetb_calc_log_idx_logged_at ON payroll.ppetb_calc_log USING btree (logged_at);
COMMENT ON TABLE payroll.ppetb_calc_log IS 'MIGRATED V3→V4: pprtb_calc_log → ppetb_calc_log. Full calculation audit trail per step per worker. Enables reproducibility and debugging.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_calc_log.emp_run_id IS 'FK tới ppetb_run_employee';
COMMENT ON COLUMN payroll.ppetb_calc_log.step_label IS 'Nhãn bước: INPUT_COLLECTION | PRE_CALC | BHXH_EMPLOYEE | BHYT | PIT | NET_PAY...';
COMMENT ON COLUMN payroll.ppetb_calc_log.payload_json IS 'Chi tiết step: {"input":{...},"output":{...},"formula_version":"VN_SI_2025_V1"}';
COMMENT ON COLUMN payroll.ppetb_calc_log.logged_at IS 'Thời điểm ghi log (có thể khác maker_date nếu batch log)';
COMMENT ON COLUMN payroll.ppetb_calc_log.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_calc_log.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_calc_log OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_calc_log TO apipayroll;


-- payroll.ppetb_costing definition

-- Drop table

-- DROP TABLE payroll.ppetb_costing;

CREATE TABLE payroll.ppetb_costing (
	id numeric DEFAULT nextval('payroll.ppesq_costing'::regclass) NOT NULL,
	result_id numeric NOT NULL, -- FK tới ppetb_result: kết quả tính lương phát sinh bút toán này (V4 updated from pprtb_result)
	account_code varchar(50) NOT NULL, -- Mã tài khoản GL. Vd: TK334 (Phải trả NLĐ), TK642 (Chi phí QLDN)
	dr_cr bpchar(1) NOT NULL, -- D = Debit (Nợ) | C = Credit (Có)
	amount numeric(18, 2) NOT NULL,
	currency_code bpchar(3) NOT NULL,
	segment_json jsonb NOT NULL, -- Phân đoạn kế toán: {"cost_center":"CC001","department":"HR","project":"PRJ_X"}
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_costing_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_costing_uk UNIQUE (tenant_code, result_id, account_code, dr_cr)
);
CREATE INDEX ppetb_costing_idx_account ON payroll.ppetb_costing USING btree (account_code);
CREATE INDEX ppetb_costing_idx_result ON payroll.ppetb_costing USING btree (result_id);
COMMENT ON TABLE payroll.ppetb_costing IS 'MIGRATED V3→V4: pprtb_costing → ppetb_costing. GL journal entries generated from payroll results. V4: result_id FK updated to ppetb_result.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_costing.result_id IS 'FK tới ppetb_result: kết quả tính lương phát sinh bút toán này (V4 updated from pprtb_result)';
COMMENT ON COLUMN payroll.ppetb_costing.account_code IS 'Mã tài khoản GL. Vd: TK334 (Phải trả NLĐ), TK642 (Chi phí QLDN)';
COMMENT ON COLUMN payroll.ppetb_costing.dr_cr IS 'D = Debit (Nợ) | C = Credit (Có)';
COMMENT ON COLUMN payroll.ppetb_costing.segment_json IS 'Phân đoạn kế toán: {"cost_center":"CC001","department":"HR","project":"PRJ_X"}';
COMMENT ON COLUMN payroll.ppetb_costing.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_costing.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_costing OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_costing TO apipayroll;


-- payroll.ppetb_cumulative_balance definition

-- Drop table

-- DROP TABLE payroll.ppetb_cumulative_balance;

CREATE TABLE payroll.ppetb_cumulative_balance (
	id numeric DEFAULT nextval('payroll.ppesq_cumulative_balance'::regclass) NOT NULL,
	employee_id numeric NOT NULL, -- FK tới emptb_employee.id
	employee_code varchar(50) NULL,
	balance_def_id numeric NOT NULL, -- FK tới ppmtb_balance_def
	balance_type varchar(10) NOT NULL, -- YTD (year-to-date) | QTD (quarter-to-date) | LTD (life-to-date/inception)
	period_year int2 NOT NULL, -- Năm tính lũy kế
	period_quarter int2 NULL, -- Quý (1–4) cho QTD. NULL cho YTD hoặc LTD
	balance_value numeric(18, 2) DEFAULT 0 NOT NULL, -- Giá trị tích lũy. Ví dụ: GROSS_YTD = 75,000,000 (T1+T2+T3/2025)
	currency_code bpchar(3) NOT NULL,
	last_updated_by_run_id numeric NULL, -- FK tới ppetb_run_request: run nào cập nhật giá trị này lần cuối (audit trail)
	last_updated_at timestamptz NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_cumulative_balance_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_cumulative_balance_uk UNIQUE (employee_id, balance_def_id, balance_type, period_year)
);
CREATE INDEX ppetb_cumulative_balance_idx_emp_year ON payroll.ppetb_cumulative_balance USING btree (employee_id, period_year);
CREATE INDEX ppetb_cumulative_balance_idx_type_year ON payroll.ppetb_cumulative_balance USING btree (balance_type, period_year);
COMMENT ON TABLE payroll.ppetb_cumulative_balance IS 'NEW V4: Persistent YTD/QTD/LTD balance accumulation. Performance optimization — avoids re-aggregating from ppetb_balance each query. Updated incrementally after each run.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_cumulative_balance.employee_id IS 'FK tới emptb_employee.id';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.balance_def_id IS 'FK tới ppmtb_balance_def';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.balance_type IS 'YTD (year-to-date) | QTD (quarter-to-date) | LTD (life-to-date/inception)';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.period_year IS 'Năm tính lũy kế';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.period_quarter IS 'Quý (1–4) cho QTD. NULL cho YTD hoặc LTD';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.balance_value IS 'Giá trị tích lũy. Ví dụ: GROSS_YTD = 75,000,000 (T1+T2+T3/2025)';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.last_updated_by_run_id IS 'FK tới ppetb_run_request: run nào cập nhật giá trị này lần cuối (audit trail)';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_cumulative_balance.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_cumulative_balance OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_cumulative_balance TO apipayroll;


-- payroll.ppetb_input_value definition

-- Drop table

-- DROP TABLE payroll.ppetb_input_value;

CREATE TABLE payroll.ppetb_input_value (
	id numeric DEFAULT nextval('payroll.ppesq_input_value'::regclass) NOT NULL,
	emp_run_id numeric NOT NULL, -- FK tới ppetb_run_employee
	element_id numeric NOT NULL, -- FK tới ppmtb_pay_element
	element_code varchar(50) NOT NULL,
	input_code varchar(50) NOT NULL, -- Loại input: RATE (đơn giá) | HOURS (giờ OT) | AMOUNT (số tiền) | DAYS (ngày) | UNITS (sản phẩm)
	input_value numeric(18, 4) NULL,
	source_ref varchar(50) NULL, -- Tham chiếu nguồn cụ thể: TA_123 (timesheet) | MAN_ADJ_9 (manual adjust) | COMP_SNAP_456 (compensation snapshot)
	source_type varchar(30) NOT NULL, -- TimeAttendance | Absence | Compensation | Benefits | ManualAdjust | ManualInput
	unit varchar(10) NULL,
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_input_value_pk PRIMARY KEY (id)
);
CREATE INDEX ppetb_input_value_idx_emp_element ON payroll.ppetb_input_value USING btree (emp_run_id, element_id);
CREATE INDEX ppetb_input_value_idx_source_type ON payroll.ppetb_input_value USING btree (source_type);
COMMENT ON TABLE payroll.ppetb_input_value IS 'MIGRATED V3→V4: pprtb_input_value → ppetb_input_value. Input values driving calculation (hours, amounts, rates). input_value precision upgraded to 18,4.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_input_value.emp_run_id IS 'FK tới ppetb_run_employee';
COMMENT ON COLUMN payroll.ppetb_input_value.element_id IS 'FK tới ppmtb_pay_element';
COMMENT ON COLUMN payroll.ppetb_input_value.input_code IS 'Loại input: RATE (đơn giá) | HOURS (giờ OT) | AMOUNT (số tiền) | DAYS (ngày) | UNITS (sản phẩm)';
COMMENT ON COLUMN payroll.ppetb_input_value.source_ref IS 'Tham chiếu nguồn cụ thể: TA_123 (timesheet) | MAN_ADJ_9 (manual adjust) | COMP_SNAP_456 (compensation snapshot)';
COMMENT ON COLUMN payroll.ppetb_input_value.source_type IS 'TimeAttendance | Absence | Compensation | Benefits | ManualAdjust | ManualInput';
COMMENT ON COLUMN payroll.ppetb_input_value.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_input_value.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_input_value OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_input_value TO apipayroll;


-- payroll.ppetb_result definition

-- Drop table

-- DROP TABLE payroll.ppetb_result;

CREATE TABLE payroll.ppetb_result (
	id numeric DEFAULT nextval('payroll.ppesq_result'::regclass) NOT NULL,
	emp_run_id numeric NOT NULL, -- FK tới ppetb_run_employee
	element_id numeric NOT NULL, -- FK tới ppmtb_pay_element
	element_code varchar(50) NOT NULL,
	result_amount numeric(18, 2) NOT NULL,
	currency_code bpchar(3) NOT NULL,
	classification varchar(20) NOT NULL, -- EARNING | DEDUCTION | TAX | EMPLOYER_CONTRIBUTION | INFORMATIONAL (V4 adds EMPLOYER_CONTRIBUTION, INFORMATIONAL)
	metadata jsonb NULL, -- Thông tin mở rộng: inputs đầu vào, formula version, intermediate values
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_result_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_result_uk UNIQUE (tenant_code, emp_run_id, element_id)
);
CREATE INDEX ppetb_result_idx_classification ON payroll.ppetb_result USING btree (classification);
CREATE INDEX ppetb_result_idx_emp_element ON payroll.ppetb_result USING btree (emp_run_id, element_id);
COMMENT ON TABLE payroll.ppetb_result IS 'MIGRATED V3→V4: pprtb_result → ppetb_result. Calculated amount per element per worker per run. V4: classification expanded (+ EMPLOYER_CONTRIBUTION, INFORMATIONAL).';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_result.emp_run_id IS 'FK tới ppetb_run_employee';
COMMENT ON COLUMN payroll.ppetb_result.element_id IS 'FK tới ppmtb_pay_element';
COMMENT ON COLUMN payroll.ppetb_result.classification IS 'EARNING | DEDUCTION | TAX | EMPLOYER_CONTRIBUTION | INFORMATIONAL (V4 adds EMPLOYER_CONTRIBUTION, INFORMATIONAL)';
COMMENT ON COLUMN payroll.ppetb_result.metadata IS 'Thông tin mở rộng: inputs đầu vào, formula version, intermediate values';
COMMENT ON COLUMN payroll.ppetb_result.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_result.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_result OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_result TO apipayroll;


-- payroll.ppetb_retro_delta definition

-- Drop table

-- DROP TABLE payroll.ppetb_retro_delta;

CREATE TABLE payroll.ppetb_retro_delta (
	id numeric DEFAULT nextval('payroll.ppesq_retro_delta'::regclass) NOT NULL,
	emp_run_id numeric NOT NULL, -- FK tới ppetb_run_employee: kỳ hiện tại đang xử lý retro
	orig_batch_id numeric NOT NULL, -- FK tới ppmttb_batch: batch gốc bị điều chỉnh (V4: updated from pprtb_batch)
	element_id numeric NOT NULL,
	element_code varchar(50) NOT NULL,
	delta_amount numeric(18, 2) NOT NULL, -- Chênh lệch = recalculated_amount - original_amount. Áp dụng vào kỳ hiện tại như RETRO_ADJUSTMENT element
	currency_code bpchar(3) NOT NULL,
	metadata jsonb NULL, -- original_amount, recalculated_amount, period_affected, adjustment_reason
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_retro_delta_pk PRIMARY KEY (id)
);
CREATE INDEX ppetb_retro_delta_idx_emp_element ON payroll.ppetb_retro_delta USING btree (emp_run_id, element_id);
CREATE INDEX ppetb_retro_delta_idx_orig_batch ON payroll.ppetb_retro_delta USING btree (orig_batch_id);
COMMENT ON TABLE payroll.ppetb_retro_delta IS 'MIGRATED V3→V4: pprtb_retro_delta → ppetb_retro_delta. Records delta between recalculated amount and original for retroactive adjustments. V4: orig_batch_id FK updated to ppmttb_batch.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_retro_delta.emp_run_id IS 'FK tới ppetb_run_employee: kỳ hiện tại đang xử lý retro';
COMMENT ON COLUMN payroll.ppetb_retro_delta.orig_batch_id IS 'FK tới ppmttb_batch: batch gốc bị điều chỉnh (V4: updated from pprtb_batch)';
COMMENT ON COLUMN payroll.ppetb_retro_delta.delta_amount IS 'Chênh lệch = recalculated_amount - original_amount. Áp dụng vào kỳ hiện tại như RETRO_ADJUSTMENT element';
COMMENT ON COLUMN payroll.ppetb_retro_delta.metadata IS 'original_amount, recalculated_amount, period_affected, adjustment_reason';
COMMENT ON COLUMN payroll.ppetb_retro_delta.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_retro_delta.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_retro_delta OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_retro_delta TO apipayroll;


-- payroll.ppetb_run_employee definition

-- Drop table

-- DROP TABLE payroll.ppetb_run_employee;

CREATE TABLE payroll.ppetb_run_employee (
	id numeric DEFAULT nextval('payroll.ppesq_run_employee'::regclass) NOT NULL,
	request_id numeric NULL, -- FK tới ppetb_run_request (NEW V4 — engine context)
	batch_id numeric NOT NULL, -- FK tới ppmttb_batch (orchestration context)
	employee_id numeric NOT NULL, -- FK tới emptb_employee.id
	employee_code varchar(50) NULL,
	assignment_id numeric NULL, -- FK tới assignment record (NEW V4 — multi-assignment: 1 nhân viên có thể có nhiều job assignments)
	pay_group_id numeric NULL,
	pay_group_code varchar(50) NULL,
	status_code varchar(20) NOT NULL, -- SELECTED: chờ tính | CALC_OK: OK | WARNINGS: OK kèm cảnh báo | ERROR: lỗi | EXCLUDED: bị loại khỏi batch
	gross_amount numeric(18, 2) NULL,
	net_amount numeric(18, 2) NULL,
	currency_code bpchar(3) NULL,
	prev_gross_amount numeric(18, 2) NULL, -- Gross kỳ trước — dùng để phát hiện biến động bất thường (NEW 27Mar2026)
	prev_net_amount numeric(18, 2) NULL, -- Net kỳ trước — dùng để phát hiện biến động bất thường (NEW 27Mar2026)
	variance_amount numeric(18, 2) NULL, -- variance_amount = current_net - prev_net (NEW 27Mar2026)
	variance_flag bool DEFAULT false NULL, -- true nếu |variance_amount| > ngưỡng cấu hình. Partial index để tối ưu query (NEW 27Mar2026)
	error_message text NULL, -- Chi tiết lỗi khi status = ERROR
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_run_employee_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_run_employee_uk UNIQUE (request_id, employee_id)
);
CREATE INDEX ppetb_run_employee_idx_assignment ON payroll.ppetb_run_employee USING btree (assignment_id);
CREATE INDEX ppetb_run_employee_idx_batch_emp ON payroll.ppetb_run_employee USING btree (batch_id, employee_id);
CREATE INDEX ppetb_run_employee_idx_status ON payroll.ppetb_run_employee USING btree (status_code);
CREATE INDEX ppetb_run_employee_idx_variance ON payroll.ppetb_run_employee USING btree (variance_flag) WHERE (variance_flag = true);
COMMENT ON TABLE payroll.ppetb_run_employee IS 'MIGRATED V3→V4: pprtb_employee → ppetb_run_employee. Per-worker calculation record. V4 adds: request_id, assignment_id, pay_group_id, WARNINGS/EXCLUDED status, variance detection fields.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_run_employee.request_id IS 'FK tới ppetb_run_request (NEW V4 — engine context)';
COMMENT ON COLUMN payroll.ppetb_run_employee.batch_id IS 'FK tới ppmttb_batch (orchestration context)';
COMMENT ON COLUMN payroll.ppetb_run_employee.employee_id IS 'FK tới emptb_employee.id';
COMMENT ON COLUMN payroll.ppetb_run_employee.assignment_id IS 'FK tới assignment record (NEW V4 — multi-assignment: 1 nhân viên có thể có nhiều job assignments)';
COMMENT ON COLUMN payroll.ppetb_run_employee.status_code IS 'SELECTED: chờ tính | CALC_OK: OK | WARNINGS: OK kèm cảnh báo | ERROR: lỗi | EXCLUDED: bị loại khỏi batch';
COMMENT ON COLUMN payroll.ppetb_run_employee.prev_gross_amount IS 'Gross kỳ trước — dùng để phát hiện biến động bất thường (NEW 27Mar2026)';
COMMENT ON COLUMN payroll.ppetb_run_employee.prev_net_amount IS 'Net kỳ trước — dùng để phát hiện biến động bất thường (NEW 27Mar2026)';
COMMENT ON COLUMN payroll.ppetb_run_employee.variance_amount IS 'variance_amount = current_net - prev_net (NEW 27Mar2026)';
COMMENT ON COLUMN payroll.ppetb_run_employee.variance_flag IS 'true nếu |variance_amount| > ngưỡng cấu hình. Partial index để tối ưu query (NEW 27Mar2026)';
COMMENT ON COLUMN payroll.ppetb_run_employee.error_message IS 'Chi tiết lỗi khi status = ERROR';
COMMENT ON COLUMN payroll.ppetb_run_employee.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_run_employee.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_run_employee OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_run_employee TO apipayroll;


-- payroll.ppetb_run_request definition

-- Drop table

-- DROP TABLE payroll.ppetb_run_request;

CREATE TABLE payroll.ppetb_run_request (
	id numeric DEFAULT nextval('payroll.ppesq_run_request'::regclass) NOT NULL,
	batch_id numeric NOT NULL, -- FK tới ppmttb_batch: batch yêu cầu engine chạy tính lương
	batch_code varchar(50) NULL,
	request_type varchar(20) NOT NULL, -- CALCULATE | VALIDATE | COSTING | RETRO | QUICKPAY | REVERSAL
	status_code varchar(20) DEFAULT 'QUEUED'::character varying NOT NULL, -- Lifecycle: QUEUED→PROCESSING→COMPLETED|FAILED|CANCELLED
	priority int2 DEFAULT 5 NULL, -- 1(cao nhất)→10(thấp nhất). Engine xử lý QUEUED request theo thứ tự priority ASC, requested_at ASC
	parameters_json jsonb NULL, -- Override settings, filters (vd: chỉ tính cho department X, hoặc override tax bracket)
	employee_count int4 NULL,
	engine_version varchar(20) NULL, -- Phiên bản engine thực thi request. Dùng cho audit và tái tính
	requested_by numeric NOT NULL, -- ID nhân viên tạo request (FK → emptb_employee.id)
	requested_at timestamptz DEFAULT now() NOT NULL,
	started_at timestamptz NULL,
	completed_at timestamptz NULL,
	error_count int4 DEFAULT 0 NULL,
	warning_count int4 DEFAULT 0 NULL,
	error_summary text NULL, -- Tóm tắt lỗi khi status = FAILED
	metadata jsonb NULL,
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_run_request_pk PRIMARY KEY (id)
);
CREATE INDEX ppetb_run_request_idx_batch ON payroll.ppetb_run_request USING btree (batch_id);
CREATE INDEX ppetb_run_request_idx_requested_at ON payroll.ppetb_run_request USING btree (requested_at);
CREATE INDEX ppetb_run_request_idx_status_priority ON payroll.ppetb_run_request USING btree (status_code, priority);
CREATE INDEX ppetb_run_request_idx_type_status ON payroll.ppetb_run_request USING btree (request_type, status_code);
COMMENT ON TABLE payroll.ppetb_run_request IS 'NEW V4: Engine interface contract — aggregate root. Decouples orchestration (ppmttb_batch) from calculation (ppetb_*). Lifecycle: QUEUED→PROCESSING→COMPLETED|FAILED|CANCELLED.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_run_request.batch_id IS 'FK tới ppmttb_batch: batch yêu cầu engine chạy tính lương';
COMMENT ON COLUMN payroll.ppetb_run_request.request_type IS 'CALCULATE | VALIDATE | COSTING | RETRO | QUICKPAY | REVERSAL';
COMMENT ON COLUMN payroll.ppetb_run_request.status_code IS 'Lifecycle: QUEUED→PROCESSING→COMPLETED|FAILED|CANCELLED';
COMMENT ON COLUMN payroll.ppetb_run_request.priority IS '1(cao nhất)→10(thấp nhất). Engine xử lý QUEUED request theo thứ tự priority ASC, requested_at ASC';
COMMENT ON COLUMN payroll.ppetb_run_request.parameters_json IS 'Override settings, filters (vd: chỉ tính cho department X, hoặc override tax bracket)';
COMMENT ON COLUMN payroll.ppetb_run_request.engine_version IS 'Phiên bản engine thực thi request. Dùng cho audit và tái tính';
COMMENT ON COLUMN payroll.ppetb_run_request.requested_by IS 'ID nhân viên tạo request (FK → emptb_employee.id)';
COMMENT ON COLUMN payroll.ppetb_run_request.error_summary IS 'Tóm tắt lỗi khi status = FAILED';
COMMENT ON COLUMN payroll.ppetb_run_request.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_run_request.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_run_request OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_run_request TO apipayroll;


-- payroll.ppetb_run_step definition

-- Drop table

-- DROP TABLE payroll.ppetb_run_step;

CREATE TABLE payroll.ppetb_run_step (
	id numeric DEFAULT nextval('payroll.ppesq_run_step'::regclass) NOT NULL,
	request_id numeric NOT NULL, -- FK tới ppetb_run_request
	step_code varchar(30) NOT NULL, -- FK tới ppetb_calculation_step.code (INPUT_COLLECTION | PRE_CALC | ... | COSTING)
	status_code varchar(20) DEFAULT 'PENDING'::character varying NOT NULL, -- PENDING | RUNNING | COMPLETED | FAILED | SKIPPED
	started_at timestamptz NULL,
	completed_at timestamptz NULL,
	record_count int4 DEFAULT 0 NULL,
	error_count int4 DEFAULT 0 NULL,
	duration_ms int8 NULL, -- Thời gian thực thi tính bằng milliseconds. Dùng để phân tích hiệu năng pipeline
	error_detail text NULL, -- Chi tiết lỗi khi status = FAILED. Stack trace hoặc thông tin debug
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Thời điểm tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppetb_run_step_pk PRIMARY KEY (id),
	CONSTRAINT ppetb_run_step_uk UNIQUE (request_id, step_code)
);
CREATE INDEX ppetb_run_step_idx_request_status ON payroll.ppetb_run_step USING btree (request_id, status_code);
COMMENT ON TABLE payroll.ppetb_run_step IS 'NEW V4: Tracks execution of each calculation step per run_request. Enables progress monitoring and post-run performance analysis.';

-- Column comments

COMMENT ON COLUMN payroll.ppetb_run_step.request_id IS 'FK tới ppetb_run_request';
COMMENT ON COLUMN payroll.ppetb_run_step.step_code IS 'FK tới ppetb_calculation_step.code (INPUT_COLLECTION | PRE_CALC | ... | COSTING)';
COMMENT ON COLUMN payroll.ppetb_run_step.status_code IS 'PENDING | RUNNING | COMPLETED | FAILED | SKIPPED';
COMMENT ON COLUMN payroll.ppetb_run_step.duration_ms IS 'Thời gian thực thi tính bằng milliseconds. Dùng để phân tích hiệu năng pipeline';
COMMENT ON COLUMN payroll.ppetb_run_step.error_detail IS 'Chi tiết lỗi khi status = FAILED. Stack trace hoặc thông tin debug';
COMMENT ON COLUMN payroll.ppetb_run_step.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppetb_run_step.maker_date IS 'Thời điểm tạo';

-- Permissions

ALTER TABLE payroll.ppetb_run_step OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppetb_run_step TO apipayroll;


-- payroll.ppmttb_batch definition

-- Drop table

-- DROP TABLE payroll.ppmttb_batch;

CREATE TABLE payroll.ppmttb_batch (
	id numeric DEFAULT nextval('payroll.ppmtsq_batch'::regclass) NOT NULL, -- Định danh duy nhất
	pay_calendar_id numeric NOT NULL, -- FK tới ppmtb_pay_calendar
	pay_calendar_code varchar(50) NULL,
	period_id numeric NULL, -- FK tới ppmttb_pay_period (NEW V4 — links batch to explicit period)
	pay_group_id numeric NULL, -- FK tới ppmtb_pay_group (RESTORED V4 — was deprecated in V3)
	pay_group_code varchar(50) NULL,
	period_start date NOT NULL, -- Ngày bắt đầu kỳ lương
	period_end date NOT NULL, -- Ngày kết thúc kỳ lương
	batch_type varchar(20) NOT NULL, -- Loại batch: REGULAR | SUPPLEMENTAL | RETRO | QUICKPAY | TERMINATION (V4 adds QUICKPAY, TERMINATION)
	run_label varchar(100) NULL, -- Nhãn tùy ý để phân biệt batch: "T4/2025 - Main Run"
	status_code varchar(20) DEFAULT 'DRAFT'::character varying NOT NULL, -- Lifecycle: DRAFT → SELECTING → SUBMITTED → ENGINE_PROCESSING → REVIEW → APPROVED → CONFIRMED → CLOSED. Also: FAILED
	engine_request_id numeric NULL, -- FK tới ppetb_run_request (NEW V4 — interface đến calculation engine)
	original_run_id numeric NULL, -- Self-ref FK: batch gốc (nếu đây là retro/reversal của batch đó)
	reversed_by_run_id numeric NULL, -- Self-ref FK: batch nào đã đảo ngược batch này
	submitted_at timestamptz NULL, -- Thời điểm batch được submit lên engine (NEW V4)
	executed_at timestamptz NULL, -- Thời điểm engine bắt đầu xử lý
	calc_completed_at timestamptz NULL, -- Thời điểm engine hoàn thành tính toán (NEW V4)
	finalized_at timestamptz NULL, -- Thời điểm batch được confirm / đóng sổ
	costed_flg bool DEFAULT false NULL, -- true = đã chạy phân bổ chi phí kế toán (costing)
	metadata jsonb NULL, -- Thông tin mở rộng: ghi chú bước, số nhân viên, cấu hình riêng...
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Ngày tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmttb_batch_pk PRIMARY KEY (id)
);
CREATE INDEX ppmttb_batch_idx_calendar_period_type ON payroll.ppmttb_batch USING btree (pay_calendar_id, period_start, batch_type);
CREATE INDEX ppmttb_batch_idx_engine_request ON payroll.ppmttb_batch USING btree (engine_request_id);
CREATE INDEX ppmttb_batch_idx_pay_group ON payroll.ppmttb_batch USING btree (pay_group_id);
CREATE INDEX ppmttb_batch_idx_period ON payroll.ppmttb_batch USING btree (period_id);
CREATE INDEX ppmttb_batch_idx_status ON payroll.ppmttb_batch USING btree (status_code);
COMMENT ON TABLE payroll.ppmttb_batch IS 'MIGRATED V3→V4: pprtb_batch → ppmttb_batch. Payroll execution batch (orchestration unit). V4 adds: period_id, pay_group_id (restored), engine_request_id, expanded status/batch_type, submitted_at, calc_completed_at.';

-- Column comments

COMMENT ON COLUMN payroll.ppmttb_batch.id IS 'Định danh duy nhất';
COMMENT ON COLUMN payroll.ppmttb_batch.pay_calendar_id IS 'FK tới ppmtb_pay_calendar';
COMMENT ON COLUMN payroll.ppmttb_batch.period_id IS 'FK tới ppmttb_pay_period (NEW V4 — links batch to explicit period)';
COMMENT ON COLUMN payroll.ppmttb_batch.pay_group_id IS 'FK tới ppmtb_pay_group (RESTORED V4 — was deprecated in V3)';
COMMENT ON COLUMN payroll.ppmttb_batch.period_start IS 'Ngày bắt đầu kỳ lương';
COMMENT ON COLUMN payroll.ppmttb_batch.period_end IS 'Ngày kết thúc kỳ lương';
COMMENT ON COLUMN payroll.ppmttb_batch.batch_type IS 'Loại batch: REGULAR | SUPPLEMENTAL | RETRO | QUICKPAY | TERMINATION (V4 adds QUICKPAY, TERMINATION)';
COMMENT ON COLUMN payroll.ppmttb_batch.run_label IS 'Nhãn tùy ý để phân biệt batch: "T4/2025 - Main Run"';
COMMENT ON COLUMN payroll.ppmttb_batch.status_code IS 'Lifecycle: DRAFT → SELECTING → SUBMITTED → ENGINE_PROCESSING → REVIEW → APPROVED → CONFIRMED → CLOSED. Also: FAILED';
COMMENT ON COLUMN payroll.ppmttb_batch.engine_request_id IS 'FK tới ppetb_run_request (NEW V4 — interface đến calculation engine)';
COMMENT ON COLUMN payroll.ppmttb_batch.original_run_id IS 'Self-ref FK: batch gốc (nếu đây là retro/reversal của batch đó)';
COMMENT ON COLUMN payroll.ppmttb_batch.reversed_by_run_id IS 'Self-ref FK: batch nào đã đảo ngược batch này';
COMMENT ON COLUMN payroll.ppmttb_batch.submitted_at IS 'Thời điểm batch được submit lên engine (NEW V4)';
COMMENT ON COLUMN payroll.ppmttb_batch.executed_at IS 'Thời điểm engine bắt đầu xử lý';
COMMENT ON COLUMN payroll.ppmttb_batch.calc_completed_at IS 'Thời điểm engine hoàn thành tính toán (NEW V4)';
COMMENT ON COLUMN payroll.ppmttb_batch.finalized_at IS 'Thời điểm batch được confirm / đóng sổ';
COMMENT ON COLUMN payroll.ppmttb_batch.costed_flg IS 'true = đã chạy phân bổ chi phí kế toán (costing)';
COMMENT ON COLUMN payroll.ppmttb_batch.metadata IS 'Thông tin mở rộng: ghi chú bước, số nhân viên, cấu hình riêng...';
COMMENT ON COLUMN payroll.ppmttb_batch.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmttb_batch.maker_date IS 'Ngày tạo';

-- Permissions

ALTER TABLE payroll.ppmttb_batch OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmttb_batch TO apipayroll;


-- payroll.ppmttb_manual_adjust definition

-- Drop table

-- DROP TABLE payroll.ppmttb_manual_adjust;

CREATE TABLE payroll.ppmttb_manual_adjust (
	id numeric DEFAULT nextval('payroll.ppmtsq_manual_adjust'::regclass) NOT NULL, -- Định danh duy nhất
	employee_id numeric NOT NULL, -- Nhân viên nhận điều chỉnh (FK → emptb_employee.id)
	employee_code varchar(50) NULL,
	period_start date NOT NULL, -- Ngày bắt đầu kỳ điều chỉnh
	period_end date NULL, -- Ngày kết thúc kỳ điều chỉnh. NULL = single-period
	element_id numeric NOT NULL, -- FK tới ppmtb_pay_element: phần tử lương cần điều chỉnh
	element_code varchar(50) NOT NULL, -- Mã element (dự phòng tham chiếu)
	amount numeric(18, 2) NOT NULL, -- Số tiền điều chỉnh. Dương = cộng thêm, âm = trừ bớt
	reason text NULL, -- Lý do điều chỉnh (văn bản tự do)
	status_code varchar(20) NOT NULL, -- PENDING: chờ xử lý | APPLIED: đã được tính trong batch
	payroll_run_id numeric NULL, -- FK tới ppmttb_batch: batch được chỉ định áp dụng điều chỉnh này (V4 updated from pprtb_batch)
	applied_in_run_id numeric NULL, -- FK tới ppmttb_batch: batch đã thực sự thực thi điều chỉnh (V4 updated from pprtb_batch)
	created_by numeric NOT NULL, -- ID nhân viên tạo điều chỉnh (FK → emptb_employee.id)
	created_at timestamptz DEFAULT now() NULL, -- Thời điểm tạo điều chỉnh
	metadata jsonb NULL, -- Thông tin mở rộng: approval chain, reference docs, attachments... (NEW V4)
	tenant_code varchar(40) DEFAULT 'A4B'::character varying NULL,
	app_code varchar(50) DEFAULT 'HCM'::character varying NULL,
	bu_code varchar(50) NULL,
	emp_code varchar(50) NULL,
	description varchar(2000) NULL,
	fts_string_value text NULL,
	agg_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	effective_start timestamptz DEFAULT now() NOT NULL,
	effective_end timestamptz NULL,
	current_flg bool DEFAULT true NULL,
	record_order int4 DEFAULT 1 NULL,
	record_status varchar(1) DEFAULT 'O'::character varying NULL,
	auth_status varchar(1) DEFAULT 'A'::character varying NULL,
	maker_id varchar(50) NULL, -- Người tạo
	maker_date timestamptz NULL, -- Ngày tạo
	checker_id varchar(50) NULL,
	checker_date timestamptz NULL,
	update_id varchar(50) NULL,
	update_date timestamptz NULL,
	mod_no numeric DEFAULT 0 NULL,
	create_date timestamptz DEFAULT now() NULL,
	fts_value tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, TRIM(BOTH FROM COALESCE(fts_string_value, ''::text)) || ' '::text)) STORED NULL,
	CONSTRAINT ppmttb_manual_adjust_pk PRIMARY KEY (id)
);
CREATE INDEX ppmttb_manual_adjust_idx_applied_batch ON payroll.ppmttb_manual_adjust USING btree (applied_in_run_id);
CREATE INDEX ppmttb_manual_adjust_idx_batch ON payroll.ppmttb_manual_adjust USING btree (payroll_run_id);
CREATE INDEX ppmttb_manual_adjust_idx_element ON payroll.ppmttb_manual_adjust USING btree (element_id);
CREATE INDEX ppmttb_manual_adjust_idx_employee_status ON payroll.ppmttb_manual_adjust USING btree (employee_id, status_code);
COMMENT ON TABLE payroll.ppmttb_manual_adjust IS 'MIGRATED V3→V4: pprtb_manual_adjust → ppmttb_manual_adjust. Manual payroll adjustment by HR/Admin. V4: FK updated to ppmttb_batch, + metadata jsonb.';

-- Column comments

COMMENT ON COLUMN payroll.ppmttb_manual_adjust.id IS 'Định danh duy nhất';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.employee_id IS 'Nhân viên nhận điều chỉnh (FK → emptb_employee.id)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.period_start IS 'Ngày bắt đầu kỳ điều chỉnh';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.period_end IS 'Ngày kết thúc kỳ điều chỉnh. NULL = single-period';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.element_id IS 'FK tới ppmtb_pay_element: phần tử lương cần điều chỉnh';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.element_code IS 'Mã element (dự phòng tham chiếu)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.amount IS 'Số tiền điều chỉnh. Dương = cộng thêm, âm = trừ bớt';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.reason IS 'Lý do điều chỉnh (văn bản tự do)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.status_code IS 'PENDING: chờ xử lý | APPLIED: đã được tính trong batch';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.payroll_run_id IS 'FK tới ppmttb_batch: batch được chỉ định áp dụng điều chỉnh này (V4 updated from pprtb_batch)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.applied_in_run_id IS 'FK tới ppmttb_batch: batch đã thực sự thực thi điều chỉnh (V4 updated from pprtb_batch)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.created_by IS 'ID nhân viên tạo điều chỉnh (FK → emptb_employee.id)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.created_at IS 'Thời điểm tạo điều chỉnh';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.metadata IS 'Thông tin mở rộng: approval chain, reference docs, attachments... (NEW V4)';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.maker_id IS 'Người tạo';
COMMENT ON COLUMN payroll.ppmttb_manual_adjust.maker_date IS 'Ngày tạo';

-- Permissions

ALTER TABLE payroll.ppmttb_manual_adjust OWNER TO apipayroll;
GRANT DELETE, SELECT, UPDATE, TRUNCATE, INSERT, TRIGGER, REFERENCES ON TABLE payroll.ppmttb_manual_adjust TO apipayroll;


-- payroll.ppatb_generated_file foreign keys

ALTER TABLE payroll.ppatb_generated_file ADD CONSTRAINT ppatb_generated_file_fk_batch FOREIGN KEY (payroll_run_id) REFERENCES payroll.ppmttb_batch(id);


-- payroll.ppbtb_payment_batch foreign keys

ALTER TABLE payroll.ppbtb_payment_batch ADD CONSTRAINT ppbtb_payment_batch_fk_bank_account FOREIGN KEY (bank_account_id) REFERENCES payroll.ppbtb_bank_account(id);
ALTER TABLE payroll.ppbtb_payment_batch ADD CONSTRAINT ppbtb_payment_batch_fk_batch FOREIGN KEY (run_batch_id) REFERENCES payroll.ppmttb_batch(id);


-- payroll.ppbtb_payment_line foreign keys

ALTER TABLE payroll.ppbtb_payment_line ADD CONSTRAINT ppbtb_payment_line_fk_payment_batch FOREIGN KEY (payment_batch_id) REFERENCES payroll.ppbtb_payment_batch(id);


-- payroll.ppetb_balance foreign keys

ALTER TABLE payroll.ppetb_balance ADD CONSTRAINT ppetb_balance_fk_balance_def FOREIGN KEY (balance_id) REFERENCES payroll.ppmtb_balance_def(id);
ALTER TABLE payroll.ppetb_balance ADD CONSTRAINT ppetb_balance_fk_emp_run FOREIGN KEY (emp_run_id) REFERENCES payroll.ppetb_run_employee(id);


-- payroll.ppetb_calc_log foreign keys

ALTER TABLE payroll.ppetb_calc_log ADD CONSTRAINT ppetb_calc_log_fk_emp_run FOREIGN KEY (emp_run_id) REFERENCES payroll.ppetb_run_employee(id);


-- payroll.ppetb_costing foreign keys

ALTER TABLE payroll.ppetb_costing ADD CONSTRAINT ppetb_costing_fk_result FOREIGN KEY (result_id) REFERENCES payroll.ppetb_result(id);


-- payroll.ppetb_cumulative_balance foreign keys

ALTER TABLE payroll.ppetb_cumulative_balance ADD CONSTRAINT ppetb_cumulative_balance_fk_balance_def FOREIGN KEY (balance_def_id) REFERENCES payroll.ppmtb_balance_def(id);
ALTER TABLE payroll.ppetb_cumulative_balance ADD CONSTRAINT ppetb_cumulative_balance_fk_run FOREIGN KEY (last_updated_by_run_id) REFERENCES payroll.ppetb_run_request(id);


-- payroll.ppetb_input_value foreign keys

ALTER TABLE payroll.ppetb_input_value ADD CONSTRAINT ppetb_input_value_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id);
ALTER TABLE payroll.ppetb_input_value ADD CONSTRAINT ppetb_input_value_fk_emp_run FOREIGN KEY (emp_run_id) REFERENCES payroll.ppetb_run_employee(id);


-- payroll.ppetb_result foreign keys

ALTER TABLE payroll.ppetb_result ADD CONSTRAINT ppetb_result_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id);
ALTER TABLE payroll.ppetb_result ADD CONSTRAINT ppetb_result_fk_emp_run FOREIGN KEY (emp_run_id) REFERENCES payroll.ppetb_run_employee(id);


-- payroll.ppetb_retro_delta foreign keys

ALTER TABLE payroll.ppetb_retro_delta ADD CONSTRAINT ppetb_retro_delta_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id);
ALTER TABLE payroll.ppetb_retro_delta ADD CONSTRAINT ppetb_retro_delta_fk_emp_run FOREIGN KEY (emp_run_id) REFERENCES payroll.ppetb_run_employee(id);
ALTER TABLE payroll.ppetb_retro_delta ADD CONSTRAINT ppetb_retro_delta_fk_orig_batch FOREIGN KEY (orig_batch_id) REFERENCES payroll.ppmttb_batch(id);


-- payroll.ppetb_run_employee foreign keys

ALTER TABLE payroll.ppetb_run_employee ADD CONSTRAINT ppetb_run_employee_fk_batch FOREIGN KEY (batch_id) REFERENCES payroll.ppmttb_batch(id);
ALTER TABLE payroll.ppetb_run_employee ADD CONSTRAINT ppetb_run_employee_fk_pay_group FOREIGN KEY (pay_group_id) REFERENCES payroll.ppmtb_pay_group(id);
ALTER TABLE payroll.ppetb_run_employee ADD CONSTRAINT ppetb_run_employee_fk_request FOREIGN KEY (request_id) REFERENCES payroll.ppetb_run_request(id);


-- payroll.ppetb_run_request foreign keys

ALTER TABLE payroll.ppetb_run_request ADD CONSTRAINT ppetb_run_request_fk_batch FOREIGN KEY (batch_id) REFERENCES payroll.ppmttb_batch(id);


-- payroll.ppetb_run_step foreign keys

ALTER TABLE payroll.ppetb_run_step ADD CONSTRAINT ppetb_run_step_fk_calc_step FOREIGN KEY (step_code) REFERENCES payroll.ppetb_calculation_step(code);
ALTER TABLE payroll.ppetb_run_step ADD CONSTRAINT ppetb_run_step_fk_request FOREIGN KEY (request_id) REFERENCES payroll.ppetb_run_request(id);


-- payroll.ppmttb_batch foreign keys

ALTER TABLE payroll.ppmttb_batch ADD CONSTRAINT ppmttb_batch_fk_calendar FOREIGN KEY (pay_calendar_id) REFERENCES payroll.ppmtb_pay_calendar(id);
ALTER TABLE payroll.ppmttb_batch ADD CONSTRAINT ppmttb_batch_fk_engine_request FOREIGN KEY (engine_request_id) REFERENCES payroll.ppetb_run_request(id);
ALTER TABLE payroll.ppmttb_batch ADD CONSTRAINT ppmttb_batch_fk_pay_group FOREIGN KEY (pay_group_id) REFERENCES payroll.ppmtb_pay_group(id);
ALTER TABLE payroll.ppmttb_batch ADD CONSTRAINT ppmttb_batch_fk_period FOREIGN KEY (period_id) REFERENCES payroll.ppmttb_pay_period(id);
ALTER TABLE payroll.ppmttb_batch ADD CONSTRAINT ppmttb_batch_fk_self_original FOREIGN KEY (original_run_id) REFERENCES payroll.ppmttb_batch(id);
ALTER TABLE payroll.ppmttb_batch ADD CONSTRAINT ppmttb_batch_fk_self_reversed FOREIGN KEY (reversed_by_run_id) REFERENCES payroll.ppmttb_batch(id);


-- payroll.ppmttb_manual_adjust foreign keys

ALTER TABLE payroll.ppmttb_manual_adjust ADD CONSTRAINT ppmttb_manual_adjust_fk_applied_batch FOREIGN KEY (applied_in_run_id) REFERENCES payroll.ppmttb_batch(id);
ALTER TABLE payroll.ppmttb_manual_adjust ADD CONSTRAINT ppmttb_manual_adjust_fk_batch FOREIGN KEY (payroll_run_id) REFERENCES payroll.ppmttb_batch(id);
ALTER TABLE payroll.ppmttb_manual_adjust ADD CONSTRAINT ppmttb_manual_adjust_fk_element FOREIGN KEY (element_id) REFERENCES payroll.ppmtb_pay_element(id);


-- payroll.pgwvw_iface_def source

CREATE OR REPLACE VIEW payroll.pgwvw_iface_def
AS SELECT pgwtb_iface_def.id,
    pgwtb_iface_def.code,
    pgwtb_iface_def.name,
    pgwtb_iface_def.direction,
    pgwtb_iface_def.file_type,
    pgwtb_iface_def.mapping_json,
    pgwtb_iface_def.schedule_json,
    pgwtb_iface_def.active_flg,
    pgwtb_iface_def.tenant_code,
    pgwtb_iface_def.app_code,
    pgwtb_iface_def.bu_code,
    pgwtb_iface_def.emp_code,
    pgwtb_iface_def.description,
    pgwtb_iface_def.fts_string_value,
    pgwtb_iface_def.fts_value,
    pgwtb_iface_def.agg_id,
    pgwtb_iface_def.effective_start,
    pgwtb_iface_def.effective_end,
    pgwtb_iface_def.current_flg,
    pgwtb_iface_def.record_order,
    pgwtb_iface_def.record_status,
    pgwtb_iface_def.auth_status,
    pgwtb_iface_def.maker_id,
    pgwtb_iface_def.maker_date,
    pgwtb_iface_def.checker_id,
    pgwtb_iface_def.checker_date,
    pgwtb_iface_def.update_id,
    pgwtb_iface_def.update_date,
    pgwtb_iface_def.mod_no,
    pgwtb_iface_def.create_date
   FROM payroll.pgwtb_iface_def;

-- Permissions

ALTER TABLE payroll.pgwvw_iface_def OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.pgwvw_iface_def TO apipayroll;


-- payroll.pgwvw_iface_file source

CREATE OR REPLACE VIEW payroll.pgwvw_iface_file
AS SELECT pgwtb_iface_file.id,
    pgwtb_iface_file.job_id,
    pgwtb_iface_file.file_name,
    pgwtb_iface_file.file_dt,
    pgwtb_iface_file.status_code,
    pgwtb_iface_file.processed_at,
    pgwtb_iface_file.metadata,
    pgwtb_iface_file.tenant_code,
    pgwtb_iface_file.app_code,
    pgwtb_iface_file.bu_code,
    pgwtb_iface_file.emp_code,
    pgwtb_iface_file.description,
    pgwtb_iface_file.fts_string_value,
    pgwtb_iface_file.fts_value,
    pgwtb_iface_file.agg_id,
    pgwtb_iface_file.effective_start,
    pgwtb_iface_file.effective_end,
    pgwtb_iface_file.current_flg,
    pgwtb_iface_file.record_order,
    pgwtb_iface_file.record_status,
    pgwtb_iface_file.auth_status,
    pgwtb_iface_file.maker_id,
    pgwtb_iface_file.maker_date,
    pgwtb_iface_file.checker_id,
    pgwtb_iface_file.checker_date,
    pgwtb_iface_file.update_id,
    pgwtb_iface_file.update_date,
    pgwtb_iface_file.mod_no,
    pgwtb_iface_file.create_date
   FROM payroll.pgwtb_iface_file;

-- Permissions

ALTER TABLE payroll.pgwvw_iface_file OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.pgwvw_iface_file TO apipayroll;


-- payroll.pgwvw_iface_job source

CREATE OR REPLACE VIEW payroll.pgwvw_iface_job
AS SELECT pgwtb_iface_job.id,
    pgwtb_iface_job.iface_id,
    pgwtb_iface_job.run_time,
    pgwtb_iface_job.status_code,
    pgwtb_iface_job.metadata,
    pgwtb_iface_job.tenant_code,
    pgwtb_iface_job.app_code,
    pgwtb_iface_job.bu_code,
    pgwtb_iface_job.emp_code,
    pgwtb_iface_job.description,
    pgwtb_iface_job.fts_string_value,
    pgwtb_iface_job.fts_value,
    pgwtb_iface_job.agg_id,
    pgwtb_iface_job.effective_start,
    pgwtb_iface_job.effective_end,
    pgwtb_iface_job.current_flg,
    pgwtb_iface_job.record_order,
    pgwtb_iface_job.record_status,
    pgwtb_iface_job.auth_status,
    pgwtb_iface_job.maker_id,
    pgwtb_iface_job.maker_date,
    pgwtb_iface_job.checker_id,
    pgwtb_iface_job.checker_date,
    pgwtb_iface_job.update_id,
    pgwtb_iface_job.update_date,
    pgwtb_iface_job.mod_no,
    pgwtb_iface_job.create_date
   FROM payroll.pgwtb_iface_job;

-- Permissions

ALTER TABLE payroll.pgwvw_iface_job OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.pgwvw_iface_job TO apipayroll;


-- payroll.pgwvw_iface_line source

CREATE OR REPLACE VIEW payroll.pgwvw_iface_line
AS SELECT pgwtb_iface_line.id,
    pgwtb_iface_line.file_id,
    pgwtb_iface_line.line_num,
    pgwtb_iface_line.payload_json,
    pgwtb_iface_line.status_code,
    pgwtb_iface_line.error_msg,
    pgwtb_iface_line.tenant_code,
    pgwtb_iface_line.app_code,
    pgwtb_iface_line.bu_code,
    pgwtb_iface_line.emp_code,
    pgwtb_iface_line.description,
    pgwtb_iface_line.fts_string_value,
    pgwtb_iface_line.fts_value,
    pgwtb_iface_line.agg_id,
    pgwtb_iface_line.effective_start,
    pgwtb_iface_line.effective_end,
    pgwtb_iface_line.current_flg,
    pgwtb_iface_line.record_order,
    pgwtb_iface_line.record_status,
    pgwtb_iface_line.auth_status,
    pgwtb_iface_line.maker_id,
    pgwtb_iface_line.maker_date,
    pgwtb_iface_line.checker_id,
    pgwtb_iface_line.checker_date,
    pgwtb_iface_line.update_id,
    pgwtb_iface_line.update_date,
    pgwtb_iface_line.mod_no,
    pgwtb_iface_line.create_date
   FROM payroll.pgwtb_iface_line;

-- Permissions

ALTER TABLE payroll.pgwvw_iface_line OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.pgwvw_iface_line TO apipayroll;


-- payroll.ppavw_audit_log source

CREATE OR REPLACE VIEW payroll.ppavw_audit_log
AS SELECT ppatb_audit_log.id,
    ppatb_audit_log.log_time,
    ppatb_audit_log.user_name,
    ppatb_audit_log.category,
    ppatb_audit_log.log_action,
    ppatb_audit_log.log_detail,
    ppatb_audit_log.reference_id,
    ppatb_audit_log.employee_id,
    ppatb_audit_log.payroll_run_id,
    ppatb_audit_log.tenant_code,
    ppatb_audit_log.app_code,
    ppatb_audit_log.bu_code,
    ppatb_audit_log.emp_code,
    ppatb_audit_log.fts_string_value,
    ppatb_audit_log.fts_value,
    ppatb_audit_log.agg_id,
    ppatb_audit_log.effective_start,
    ppatb_audit_log.effective_end,
    ppatb_audit_log.current_flg,
    ppatb_audit_log.record_order,
    ppatb_audit_log.record_status,
    ppatb_audit_log.auth_status,
    ppatb_audit_log.maker_id,
    ppatb_audit_log.maker_date,
    ppatb_audit_log.checker_id,
    ppatb_audit_log.checker_date,
    ppatb_audit_log.update_id,
    ppatb_audit_log.update_date,
    ppatb_audit_log.mod_no,
    ppatb_audit_log.create_date
   FROM payroll.ppatb_audit_log;

COMMENT ON VIEW payroll.ppavw_audit_log IS 'Immutable payroll audit log view. payroll_run_id is a soft ref to ppmttb_batch (no FK on base table).';

-- Permissions

ALTER TABLE payroll.ppavw_audit_log OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppavw_audit_log TO apipayroll;


-- payroll.ppavw_bank_template source

CREATE OR REPLACE VIEW payroll.ppavw_bank_template
AS SELECT ppatb_bank_template.id,
    ppatb_bank_template.code,
    ppatb_bank_template.name,
    ppatb_bank_template.format,
    ppatb_bank_template.delimiter,
    ppatb_bank_template.columns_json,
    ppatb_bank_template.tenant_code,
    ppatb_bank_template.app_code,
    ppatb_bank_template.bu_code,
    ppatb_bank_template.emp_code,
    ppatb_bank_template.fts_string_value,
    ppatb_bank_template.fts_value,
    ppatb_bank_template.agg_id,
    ppatb_bank_template.effective_start,
    ppatb_bank_template.effective_end,
    ppatb_bank_template.current_flg,
    ppatb_bank_template.record_order,
    ppatb_bank_template.record_status,
    ppatb_bank_template.auth_status,
    ppatb_bank_template.maker_id,
    ppatb_bank_template.maker_date,
    ppatb_bank_template.checker_id,
    ppatb_bank_template.checker_date,
    ppatb_bank_template.update_id,
    ppatb_bank_template.update_date,
    ppatb_bank_template.mod_no,
    ppatb_bank_template.create_date
   FROM payroll.ppatb_bank_template;

COMMENT ON VIEW payroll.ppavw_bank_template IS 'Bank file format template view (SCD2). Columns define CSV/TXT file structure for salary transfers.';

-- Permissions

ALTER TABLE payroll.ppavw_bank_template OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppavw_bank_template TO apipayroll;


-- payroll.ppavw_generated_file source

CREATE OR REPLACE VIEW payroll.ppavw_generated_file
AS SELECT ppatb_generated_file.id,
    ppatb_generated_file.generated_type,
    ppatb_generated_file.payroll_run_id,
    ppatb_generated_file.employee_id,
    ppatb_generated_file.file_name,
    ppatb_generated_file.file_path,
    ppatb_generated_file.generated_at,
    ppatb_generated_file.expires_at,
    ppatb_generated_file.status,
    ppatb_generated_file.tenant_code,
    ppatb_generated_file.app_code,
    ppatb_generated_file.bu_code,
    ppatb_generated_file.emp_code,
    ppatb_generated_file.fts_string_value,
    ppatb_generated_file.fts_value,
    ppatb_generated_file.agg_id,
    ppatb_generated_file.effective_start,
    ppatb_generated_file.effective_end,
    ppatb_generated_file.current_flg,
    ppatb_generated_file.record_order,
    ppatb_generated_file.record_status,
    ppatb_generated_file.auth_status,
    ppatb_generated_file.maker_id,
    ppatb_generated_file.maker_date,
    ppatb_generated_file.checker_id,
    ppatb_generated_file.checker_date,
    ppatb_generated_file.update_id,
    ppatb_generated_file.update_date,
    ppatb_generated_file.mod_no,
    ppatb_generated_file.create_date
   FROM payroll.ppatb_generated_file;

COMMENT ON VIEW payroll.ppavw_generated_file IS 'System-generated output files view — payroll_run_id FK references ppmttb_batch.';

-- Permissions

ALTER TABLE payroll.ppavw_generated_file OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppavw_generated_file TO apipayroll;


-- payroll.ppavw_import_job source

CREATE OR REPLACE VIEW payroll.ppavw_import_job
AS SELECT ppatb_import_job.id,
    ppatb_import_job.file_name,
    ppatb_import_job.pay_group_code,
    ppatb_import_job.period_start,
    ppatb_import_job.period_end,
    ppatb_import_job.total_records,
    ppatb_import_job.success_count,
    ppatb_import_job.fail_count,
    ppatb_import_job.status,
    ppatb_import_job.submitted_by,
    ppatb_import_job.submitted_at,
    ppatb_import_job.completed_at,
    ppatb_import_job.tenant_code,
    ppatb_import_job.app_code,
    ppatb_import_job.bu_code,
    ppatb_import_job.emp_code,
    ppatb_import_job.fts_string_value,
    ppatb_import_job.fts_value,
    ppatb_import_job.agg_id,
    ppatb_import_job.effective_start,
    ppatb_import_job.effective_end,
    ppatb_import_job.current_flg,
    ppatb_import_job.record_order,
    ppatb_import_job.record_status,
    ppatb_import_job.auth_status,
    ppatb_import_job.maker_id,
    ppatb_import_job.maker_date,
    ppatb_import_job.checker_id,
    ppatb_import_job.checker_date,
    ppatb_import_job.update_id,
    ppatb_import_job.update_date,
    ppatb_import_job.mod_no,
    ppatb_import_job.create_date
   FROM payroll.ppatb_import_job;

COMMENT ON VIEW payroll.ppavw_import_job IS 'Bulk file import job tracking view.';

-- Permissions

ALTER TABLE payroll.ppavw_import_job OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppavw_import_job TO apipayroll;


-- payroll.ppavw_tax_report_template source

CREATE OR REPLACE VIEW payroll.ppavw_tax_report_template
AS SELECT ppatb_tax_report_template.id,
    ppatb_tax_report_template.code,
    ppatb_tax_report_template.country_code,
    ppatb_tax_report_template.format,
    ppatb_tax_report_template.template_blob,
    ppatb_tax_report_template.tenant_code,
    ppatb_tax_report_template.app_code,
    ppatb_tax_report_template.bu_code,
    ppatb_tax_report_template.emp_code,
    ppatb_tax_report_template.fts_string_value,
    ppatb_tax_report_template.fts_value,
    ppatb_tax_report_template.agg_id,
    ppatb_tax_report_template.effective_start,
    ppatb_tax_report_template.effective_end,
    ppatb_tax_report_template.current_flg,
    ppatb_tax_report_template.record_order,
    ppatb_tax_report_template.record_status,
    ppatb_tax_report_template.auth_status,
    ppatb_tax_report_template.maker_id,
    ppatb_tax_report_template.maker_date,
    ppatb_tax_report_template.checker_id,
    ppatb_tax_report_template.checker_date,
    ppatb_tax_report_template.update_id,
    ppatb_tax_report_template.update_date,
    ppatb_tax_report_template.mod_no,
    ppatb_tax_report_template.create_date
   FROM payroll.ppatb_tax_report_template;

COMMENT ON VIEW payroll.ppavw_tax_report_template IS 'Tax report template view (SCD2, PDF/XML by country).';

-- Permissions

ALTER TABLE payroll.ppavw_tax_report_template OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppavw_tax_report_template TO apipayroll;


-- payroll.ppbvw_bank_account source

CREATE OR REPLACE VIEW payroll.ppbvw_bank_account
AS SELECT ppbtb_bank_account.id,
    ppbtb_bank_account.legal_entity_id,
    ppbtb_bank_account.legal_entity_code,
    ppbtb_bank_account.bank_name,
    ppbtb_bank_account.account_no,
    ppbtb_bank_account.currency_code,
    ppbtb_bank_account.metadata,
    ppbtb_bank_account.tenant_code,
    ppbtb_bank_account.app_code,
    ppbtb_bank_account.bu_code,
    ppbtb_bank_account.emp_code,
    ppbtb_bank_account.description,
    ppbtb_bank_account.fts_string_value,
    ppbtb_bank_account.fts_value,
    ppbtb_bank_account.agg_id,
    ppbtb_bank_account.effective_start,
    ppbtb_bank_account.effective_end,
    ppbtb_bank_account.current_flg,
    ppbtb_bank_account.record_order,
    ppbtb_bank_account.record_status,
    ppbtb_bank_account.auth_status,
    ppbtb_bank_account.maker_id,
    ppbtb_bank_account.maker_date,
    ppbtb_bank_account.checker_id,
    ppbtb_bank_account.checker_date,
    ppbtb_bank_account.update_id,
    ppbtb_bank_account.update_date,
    ppbtb_bank_account.mod_no,
    ppbtb_bank_account.create_date
   FROM payroll.ppbtb_bank_account;

-- View Triggers

create trigger ppbvw_bank_account_instead_of instead of
insert
    or
delete
    or
update
    on
    payroll.ppbvw_bank_account for each row execute function payroll.ppbtf_bank_account();

-- Permissions

ALTER TABLE payroll.ppbvw_bank_account OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppbvw_bank_account TO apipayroll;


-- payroll.ppbvw_payment_batch source

CREATE OR REPLACE VIEW payroll.ppbvw_payment_batch
AS SELECT ppbtb_payment_batch.id,
    ppbtb_payment_batch.run_batch_id,
    ppbtb_payment_batch.bank_account_id,
    ppbtb_payment_batch.file_status,
    ppbtb_payment_batch.submitted_at,
    ppbtb_payment_batch.file_url,
    ppbtb_payment_batch.metadata,
    ppbtb_payment_batch.tenant_code,
    ppbtb_payment_batch.app_code,
    ppbtb_payment_batch.bu_code,
    ppbtb_payment_batch.emp_code,
    ppbtb_payment_batch.description,
    ppbtb_payment_batch.fts_string_value,
    ppbtb_payment_batch.fts_value,
    ppbtb_payment_batch.agg_id,
    ppbtb_payment_batch.effective_start,
    ppbtb_payment_batch.effective_end,
    ppbtb_payment_batch.current_flg,
    ppbtb_payment_batch.record_order,
    ppbtb_payment_batch.record_status,
    ppbtb_payment_batch.auth_status,
    ppbtb_payment_batch.maker_id,
    ppbtb_payment_batch.maker_date,
    ppbtb_payment_batch.checker_id,
    ppbtb_payment_batch.checker_date,
    ppbtb_payment_batch.update_id,
    ppbtb_payment_batch.update_date,
    ppbtb_payment_batch.mod_no,
    ppbtb_payment_batch.create_date
   FROM payroll.ppbtb_payment_batch;

-- Permissions

ALTER TABLE payroll.ppbvw_payment_batch OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppbvw_payment_batch TO apipayroll;


-- payroll.ppbvw_payment_line source

CREATE OR REPLACE VIEW payroll.ppbvw_payment_line
AS SELECT ppbtb_payment_line.id,
    ppbtb_payment_line.payment_batch_id,
    ppbtb_payment_line.employee_id,
    ppbtb_payment_line.net_amount,
    ppbtb_payment_line.bank_routing,
    ppbtb_payment_line.account_number,
    ppbtb_payment_line.status_code,
    ppbtb_payment_line.metadata,
    ppbtb_payment_line.tenant_code,
    ppbtb_payment_line.app_code,
    ppbtb_payment_line.bu_code,
    ppbtb_payment_line.emp_code,
    ppbtb_payment_line.description,
    ppbtb_payment_line.fts_string_value,
    ppbtb_payment_line.fts_value,
    ppbtb_payment_line.agg_id,
    ppbtb_payment_line.effective_start,
    ppbtb_payment_line.effective_end,
    ppbtb_payment_line.current_flg,
    ppbtb_payment_line.record_order,
    ppbtb_payment_line.record_status,
    ppbtb_payment_line.auth_status,
    ppbtb_payment_line.maker_id,
    ppbtb_payment_line.maker_date,
    ppbtb_payment_line.checker_id,
    ppbtb_payment_line.checker_date,
    ppbtb_payment_line.update_id,
    ppbtb_payment_line.update_date,
    ppbtb_payment_line.mod_no,
    ppbtb_payment_line.create_date
   FROM payroll.ppbtb_payment_line;

-- Permissions

ALTER TABLE payroll.ppbvw_payment_line OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppbvw_payment_line TO apipayroll;


-- payroll.ppevw_balance source

CREATE OR REPLACE VIEW payroll.ppevw_balance
AS SELECT ppetb_balance.id,
    ppetb_balance.emp_run_id,
    ppetb_balance.balance_id,
    ppetb_balance.balance_value,
    ppetb_balance.metadata,
    ppetb_balance.tenant_code,
    ppetb_balance.app_code,
    ppetb_balance.bu_code,
    ppetb_balance.emp_code,
    ppetb_balance.description,
    ppetb_balance.fts_string_value,
    ppetb_balance.fts_value,
    ppetb_balance.agg_id,
    ppetb_balance.effective_start,
    ppetb_balance.effective_end,
    ppetb_balance.current_flg,
    ppetb_balance.record_order,
    ppetb_balance.record_status,
    ppetb_balance.auth_status,
    ppetb_balance.maker_id,
    ppetb_balance.maker_date,
    ppetb_balance.checker_id,
    ppetb_balance.checker_date,
    ppetb_balance.update_id,
    ppetb_balance.update_date,
    ppetb_balance.mod_no,
    ppetb_balance.create_date
   FROM payroll.ppetb_balance;

COMMENT ON VIEW payroll.ppevw_balance IS 'V4 RENAMED: pprvw_balance → ppevw_balance. FROM ppetb_balance (migrated pprtb_balance).';

-- Permissions

ALTER TABLE payroll.ppevw_balance OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_balance TO apipayroll;


-- payroll.ppevw_calc_log source

CREATE OR REPLACE VIEW payroll.ppevw_calc_log
AS SELECT ppetb_calc_log.id,
    ppetb_calc_log.emp_run_id,
    ppetb_calc_log.step_label,
    ppetb_calc_log.message,
    ppetb_calc_log.payload_json,
    ppetb_calc_log.logged_at,
    ppetb_calc_log.tenant_code,
    ppetb_calc_log.app_code,
    ppetb_calc_log.bu_code,
    ppetb_calc_log.emp_code,
    ppetb_calc_log.description,
    ppetb_calc_log.fts_string_value,
    ppetb_calc_log.fts_value,
    ppetb_calc_log.agg_id,
    ppetb_calc_log.effective_start,
    ppetb_calc_log.effective_end,
    ppetb_calc_log.current_flg,
    ppetb_calc_log.record_order,
    ppetb_calc_log.record_status,
    ppetb_calc_log.auth_status,
    ppetb_calc_log.maker_id,
    ppetb_calc_log.maker_date,
    ppetb_calc_log.checker_id,
    ppetb_calc_log.checker_date,
    ppetb_calc_log.update_id,
    ppetb_calc_log.update_date,
    ppetb_calc_log.mod_no,
    ppetb_calc_log.create_date
   FROM payroll.ppetb_calc_log;

COMMENT ON VIEW payroll.ppevw_calc_log IS 'V4 RENAMED: pprvw_calc_log → ppevw_calc_log. Full step-by-step calculation audit trail.';

-- Permissions

ALTER TABLE payroll.ppevw_calc_log OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_calc_log TO apipayroll;


-- payroll.ppevw_calculation_step source

CREATE OR REPLACE VIEW payroll.ppevw_calculation_step
AS SELECT ppetb_calculation_step.id,
    ppetb_calculation_step.code,
    ppetb_calculation_step.name,
    ppetb_calculation_step.sequence,
    ppetb_calculation_step.is_active,
    ppetb_calculation_step.is_mandatory,
    ppetb_calculation_step.description,
    ppetb_calculation_step.tenant_code,
    ppetb_calculation_step.app_code,
    ppetb_calculation_step.bu_code,
    ppetb_calculation_step.emp_code,
    ppetb_calculation_step.fts_string_value,
    ppetb_calculation_step.fts_value,
    ppetb_calculation_step.agg_id,
    ppetb_calculation_step.effective_start,
    ppetb_calculation_step.effective_end,
    ppetb_calculation_step.current_flg,
    ppetb_calculation_step.record_order,
    ppetb_calculation_step.record_status,
    ppetb_calculation_step.auth_status,
    ppetb_calculation_step.maker_id,
    ppetb_calculation_step.maker_date,
    ppetb_calculation_step.checker_id,
    ppetb_calculation_step.checker_date,
    ppetb_calculation_step.update_id,
    ppetb_calculation_step.update_date,
    ppetb_calculation_step.mod_no,
    ppetb_calculation_step.create_date
   FROM payroll.ppetb_calculation_step;

COMMENT ON VIEW payroll.ppevw_calculation_step IS 'V4 NEW: Calculation pipeline step reference view.';

-- Permissions

ALTER TABLE payroll.ppevw_calculation_step OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_calculation_step TO apipayroll;


-- payroll.ppevw_costing source

CREATE OR REPLACE VIEW payroll.ppevw_costing
AS SELECT ppetb_costing.id,
    ppetb_costing.result_id,
    ppetb_costing.account_code,
    ppetb_costing.dr_cr,
    ppetb_costing.amount,
    ppetb_costing.currency_code,
    ppetb_costing.segment_json,
    ppetb_costing.tenant_code,
    ppetb_costing.app_code,
    ppetb_costing.bu_code,
    ppetb_costing.emp_code,
    ppetb_costing.description,
    ppetb_costing.fts_string_value,
    ppetb_costing.fts_value,
    ppetb_costing.agg_id,
    ppetb_costing.effective_start,
    ppetb_costing.effective_end,
    ppetb_costing.current_flg,
    ppetb_costing.record_order,
    ppetb_costing.record_status,
    ppetb_costing.auth_status,
    ppetb_costing.maker_id,
    ppetb_costing.maker_date,
    ppetb_costing.checker_id,
    ppetb_costing.checker_date,
    ppetb_costing.update_id,
    ppetb_costing.update_date,
    ppetb_costing.mod_no,
    ppetb_costing.create_date
   FROM payroll.ppetb_costing;

COMMENT ON VIEW payroll.ppevw_costing IS 'V4 RENAMED: pprvw_costing → ppevw_costing. result_id FK updated to ppetb_result.';

-- Permissions

ALTER TABLE payroll.ppevw_costing OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_costing TO apipayroll;


-- payroll.ppevw_cumulative_balance source

CREATE OR REPLACE VIEW payroll.ppevw_cumulative_balance
AS SELECT ppetb_cumulative_balance.id,
    ppetb_cumulative_balance.employee_id,
    ppetb_cumulative_balance.employee_code,
    ppetb_cumulative_balance.balance_def_id,
    ppetb_cumulative_balance.balance_type,
    ppetb_cumulative_balance.period_year,
    ppetb_cumulative_balance.period_quarter,
    ppetb_cumulative_balance.balance_value,
    ppetb_cumulative_balance.currency_code,
    ppetb_cumulative_balance.last_updated_by_run_id,
    ppetb_cumulative_balance.last_updated_at,
    ppetb_cumulative_balance.tenant_code,
    ppetb_cumulative_balance.app_code,
    ppetb_cumulative_balance.bu_code,
    ppetb_cumulative_balance.emp_code,
    ppetb_cumulative_balance.description,
    ppetb_cumulative_balance.fts_string_value,
    ppetb_cumulative_balance.fts_value,
    ppetb_cumulative_balance.agg_id,
    ppetb_cumulative_balance.effective_start,
    ppetb_cumulative_balance.effective_end,
    ppetb_cumulative_balance.current_flg,
    ppetb_cumulative_balance.record_order,
    ppetb_cumulative_balance.record_status,
    ppetb_cumulative_balance.auth_status,
    ppetb_cumulative_balance.maker_id,
    ppetb_cumulative_balance.maker_date,
    ppetb_cumulative_balance.checker_id,
    ppetb_cumulative_balance.checker_date,
    ppetb_cumulative_balance.update_id,
    ppetb_cumulative_balance.update_date,
    ppetb_cumulative_balance.mod_no,
    ppetb_cumulative_balance.create_date
   FROM payroll.ppetb_cumulative_balance;

COMMENT ON VIEW payroll.ppevw_cumulative_balance IS 'V4 NEW: Persistent YTD/QTD/LTD balance accumulation view. Performance optimization.';

-- Permissions

ALTER TABLE payroll.ppevw_cumulative_balance OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_cumulative_balance TO apipayroll;


-- payroll.ppevw_element_dependency source

CREATE OR REPLACE VIEW payroll.ppevw_element_dependency
AS SELECT ppetb_element_dependency.id,
    ppetb_element_dependency.element_id,
    ppetb_element_dependency.element_code,
    ppetb_element_dependency.depends_on_element_id,
    ppetb_element_dependency.depends_on_element_code,
    ppetb_element_dependency.dependency_type,
    ppetb_element_dependency.is_active,
    ppetb_element_dependency.description,
    ppetb_element_dependency.tenant_code,
    ppetb_element_dependency.app_code,
    ppetb_element_dependency.bu_code,
    ppetb_element_dependency.emp_code,
    ppetb_element_dependency.fts_string_value,
    ppetb_element_dependency.fts_value,
    ppetb_element_dependency.agg_id,
    ppetb_element_dependency.effective_start,
    ppetb_element_dependency.effective_end,
    ppetb_element_dependency.current_flg,
    ppetb_element_dependency.record_order,
    ppetb_element_dependency.record_status,
    ppetb_element_dependency.auth_status,
    ppetb_element_dependency.maker_id,
    ppetb_element_dependency.maker_date,
    ppetb_element_dependency.checker_id,
    ppetb_element_dependency.checker_date,
    ppetb_element_dependency.update_id,
    ppetb_element_dependency.update_date,
    ppetb_element_dependency.mod_no,
    ppetb_element_dependency.create_date
   FROM payroll.ppetb_element_dependency;

COMMENT ON VIEW payroll.ppevw_element_dependency IS 'V4 NEW: Element calculation order DAG — REQUIRES_OUTPUT | USES_BALANCE | SEQUENCED_AFTER.';

-- Permissions

ALTER TABLE payroll.ppevw_element_dependency OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_element_dependency TO apipayroll;


-- payroll.ppevw_input_source_config source

CREATE OR REPLACE VIEW payroll.ppevw_input_source_config
AS SELECT ppetb_input_source_config.id,
    ppetb_input_source_config.source_module,
    ppetb_input_source_config.source_type,
    ppetb_input_source_config.target_element_id,
    ppetb_input_source_config.target_element_code,
    ppetb_input_source_config.mapping_json,
    ppetb_input_source_config.is_active,
    ppetb_input_source_config.priority,
    ppetb_input_source_config.description,
    ppetb_input_source_config.metadata,
    ppetb_input_source_config.tenant_code,
    ppetb_input_source_config.app_code,
    ppetb_input_source_config.bu_code,
    ppetb_input_source_config.emp_code,
    ppetb_input_source_config.fts_string_value,
    ppetb_input_source_config.fts_value,
    ppetb_input_source_config.agg_id,
    ppetb_input_source_config.effective_start,
    ppetb_input_source_config.effective_end,
    ppetb_input_source_config.current_flg,
    ppetb_input_source_config.record_order,
    ppetb_input_source_config.record_status,
    ppetb_input_source_config.auth_status,
    ppetb_input_source_config.maker_id,
    ppetb_input_source_config.maker_date,
    ppetb_input_source_config.checker_id,
    ppetb_input_source_config.checker_date,
    ppetb_input_source_config.update_id,
    ppetb_input_source_config.update_date,
    ppetb_input_source_config.mod_no,
    ppetb_input_source_config.create_date
   FROM payroll.ppetb_input_source_config;

COMMENT ON VIEW payroll.ppevw_input_source_config IS 'V4 NEW: Automated input collection config — maps (source_module × source_type) → target pay_element.';

-- Permissions

ALTER TABLE payroll.ppevw_input_source_config OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_input_source_config TO apipayroll;


-- payroll.ppevw_input_value source

CREATE OR REPLACE VIEW payroll.ppevw_input_value
AS SELECT ppetb_input_value.id,
    ppetb_input_value.emp_run_id,
    ppetb_input_value.element_id,
    ppetb_input_value.element_code,
    ppetb_input_value.input_code,
    ppetb_input_value.input_value,
    ppetb_input_value.source_ref,
    ppetb_input_value.source_type,
    ppetb_input_value.unit,
    ppetb_input_value.metadata,
    ppetb_input_value.tenant_code,
    ppetb_input_value.app_code,
    ppetb_input_value.bu_code,
    ppetb_input_value.emp_code,
    ppetb_input_value.description,
    ppetb_input_value.fts_string_value,
    ppetb_input_value.fts_value,
    ppetb_input_value.agg_id,
    ppetb_input_value.effective_start,
    ppetb_input_value.effective_end,
    ppetb_input_value.current_flg,
    ppetb_input_value.record_order,
    ppetb_input_value.record_status,
    ppetb_input_value.auth_status,
    ppetb_input_value.maker_id,
    ppetb_input_value.maker_date,
    ppetb_input_value.checker_id,
    ppetb_input_value.checker_date,
    ppetb_input_value.update_id,
    ppetb_input_value.update_date,
    ppetb_input_value.mod_no,
    ppetb_input_value.create_date
   FROM payroll.ppetb_input_value;

COMMENT ON VIEW payroll.ppevw_input_value IS 'V4 RENAMED: pprvw_input_value → ppevw_input_value. Adds source_type, unit columns. input_value precision upgraded to 18,4.';

-- Permissions

ALTER TABLE payroll.ppevw_input_value OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_input_value TO apipayroll;


-- payroll.ppevw_result source

CREATE OR REPLACE VIEW payroll.ppevw_result
AS SELECT ppetb_result.id,
    ppetb_result.emp_run_id,
    ppetb_result.element_id,
    ppetb_result.element_code,
    ppetb_result.result_amount,
    ppetb_result.currency_code,
    ppetb_result.classification,
    ppetb_result.metadata,
    ppetb_result.tenant_code,
    ppetb_result.app_code,
    ppetb_result.bu_code,
    ppetb_result.emp_code,
    ppetb_result.description,
    ppetb_result.fts_string_value,
    ppetb_result.fts_value,
    ppetb_result.agg_id,
    ppetb_result.effective_start,
    ppetb_result.effective_end,
    ppetb_result.current_flg,
    ppetb_result.record_order,
    ppetb_result.record_status,
    ppetb_result.auth_status,
    ppetb_result.maker_id,
    ppetb_result.maker_date,
    ppetb_result.checker_id,
    ppetb_result.checker_date,
    ppetb_result.update_id,
    ppetb_result.update_date,
    ppetb_result.mod_no,
    ppetb_result.create_date
   FROM payroll.ppetb_result;

COMMENT ON VIEW payroll.ppevw_result IS 'V4 RENAMED: pprvw_result → ppevw_result. classification expanded: + EMPLOYER_CONTRIBUTION | INFORMATIONAL.';

-- Permissions

ALTER TABLE payroll.ppevw_result OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_result TO apipayroll;


-- payroll.ppevw_retro_delta source

CREATE OR REPLACE VIEW payroll.ppevw_retro_delta
AS SELECT ppetb_retro_delta.id,
    ppetb_retro_delta.emp_run_id,
    ppetb_retro_delta.orig_batch_id,
    ppetb_retro_delta.element_id,
    ppetb_retro_delta.element_code,
    ppetb_retro_delta.delta_amount,
    ppetb_retro_delta.currency_code,
    ppetb_retro_delta.metadata,
    ppetb_retro_delta.tenant_code,
    ppetb_retro_delta.app_code,
    ppetb_retro_delta.bu_code,
    ppetb_retro_delta.emp_code,
    ppetb_retro_delta.description,
    ppetb_retro_delta.fts_string_value,
    ppetb_retro_delta.fts_value,
    ppetb_retro_delta.agg_id,
    ppetb_retro_delta.effective_start,
    ppetb_retro_delta.effective_end,
    ppetb_retro_delta.current_flg,
    ppetb_retro_delta.record_order,
    ppetb_retro_delta.record_status,
    ppetb_retro_delta.auth_status,
    ppetb_retro_delta.maker_id,
    ppetb_retro_delta.maker_date,
    ppetb_retro_delta.checker_id,
    ppetb_retro_delta.checker_date,
    ppetb_retro_delta.update_id,
    ppetb_retro_delta.update_date,
    ppetb_retro_delta.mod_no,
    ppetb_retro_delta.create_date
   FROM payroll.ppetb_retro_delta;

COMMENT ON VIEW payroll.ppevw_retro_delta IS 'V4 RENAMED: pprvw_retro_delta → ppevw_retro_delta. orig_batch_id FK updated to ppmttb_batch.';

-- Permissions

ALTER TABLE payroll.ppevw_retro_delta OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_retro_delta TO apipayroll;


-- payroll.ppevw_run_employee source

CREATE OR REPLACE VIEW payroll.ppevw_run_employee
AS SELECT ppetb_run_employee.id,
    ppetb_run_employee.request_id,
    ppetb_run_employee.batch_id,
    ppetb_run_employee.employee_id,
    ppetb_run_employee.employee_code,
    ppetb_run_employee.assignment_id,
    ppetb_run_employee.pay_group_id,
    ppetb_run_employee.pay_group_code,
    ppetb_run_employee.status_code,
    ppetb_run_employee.gross_amount,
    ppetb_run_employee.net_amount,
    ppetb_run_employee.currency_code,
    ppetb_run_employee.prev_gross_amount,
    ppetb_run_employee.prev_net_amount,
    ppetb_run_employee.variance_amount,
    ppetb_run_employee.variance_flag,
    ppetb_run_employee.error_message,
    ppetb_run_employee.metadata,
    ppetb_run_employee.tenant_code,
    ppetb_run_employee.app_code,
    ppetb_run_employee.bu_code,
    ppetb_run_employee.emp_code,
    ppetb_run_employee.description,
    ppetb_run_employee.fts_string_value,
    ppetb_run_employee.fts_value,
    ppetb_run_employee.agg_id,
    ppetb_run_employee.effective_start,
    ppetb_run_employee.effective_end,
    ppetb_run_employee.current_flg,
    ppetb_run_employee.record_order,
    ppetb_run_employee.record_status,
    ppetb_run_employee.auth_status,
    ppetb_run_employee.maker_id,
    ppetb_run_employee.maker_date,
    ppetb_run_employee.checker_id,
    ppetb_run_employee.checker_date,
    ppetb_run_employee.update_id,
    ppetb_run_employee.update_date,
    ppetb_run_employee.mod_no,
    ppetb_run_employee.create_date
   FROM payroll.ppetb_run_employee;

COMMENT ON VIEW payroll.ppevw_run_employee IS 'V4 RENAMED: pprvw_employee → ppevw_run_employee. FROM ppetb_run_employee (migrated pprtb_employee). Adds: request_id, assignment_id, pay_group_id, variance detection fields.';

-- Permissions

ALTER TABLE payroll.ppevw_run_employee OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_run_employee TO apipayroll;


-- payroll.ppevw_run_request source

CREATE OR REPLACE VIEW payroll.ppevw_run_request
AS SELECT ppetb_run_request.id,
    ppetb_run_request.batch_id,
    ppetb_run_request.batch_code,
    ppetb_run_request.request_type,
    ppetb_run_request.status_code,
    ppetb_run_request.priority,
    ppetb_run_request.parameters_json,
    ppetb_run_request.employee_count,
    ppetb_run_request.engine_version,
    ppetb_run_request.requested_by,
    ppetb_run_request.requested_at,
    ppetb_run_request.started_at,
    ppetb_run_request.completed_at,
    ppetb_run_request.error_count,
    ppetb_run_request.warning_count,
    ppetb_run_request.error_summary,
    ppetb_run_request.metadata,
    ppetb_run_request.tenant_code,
    ppetb_run_request.app_code,
    ppetb_run_request.bu_code,
    ppetb_run_request.emp_code,
    ppetb_run_request.description,
    ppetb_run_request.fts_string_value,
    ppetb_run_request.fts_value,
    ppetb_run_request.agg_id,
    ppetb_run_request.effective_start,
    ppetb_run_request.effective_end,
    ppetb_run_request.current_flg,
    ppetb_run_request.record_order,
    ppetb_run_request.record_status,
    ppetb_run_request.auth_status,
    ppetb_run_request.maker_id,
    ppetb_run_request.maker_date,
    ppetb_run_request.checker_id,
    ppetb_run_request.checker_date,
    ppetb_run_request.update_id,
    ppetb_run_request.update_date,
    ppetb_run_request.mod_no,
    ppetb_run_request.create_date
   FROM payroll.ppetb_run_request;

COMMENT ON VIEW payroll.ppevw_run_request IS 'V4 NEW: Engine run request view. Aggregate root decoupling orchestration from calculation.';

-- Permissions

ALTER TABLE payroll.ppevw_run_request OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_run_request TO apipayroll;


-- payroll.ppevw_run_step source

CREATE OR REPLACE VIEW payroll.ppevw_run_step
AS SELECT ppetb_run_step.id,
    ppetb_run_step.request_id,
    ppetb_run_step.step_code,
    ppetb_run_step.status_code,
    ppetb_run_step.started_at,
    ppetb_run_step.completed_at,
    ppetb_run_step.record_count,
    ppetb_run_step.error_count,
    ppetb_run_step.duration_ms,
    ppetb_run_step.error_detail,
    ppetb_run_step.tenant_code,
    ppetb_run_step.app_code,
    ppetb_run_step.bu_code,
    ppetb_run_step.emp_code,
    ppetb_run_step.description,
    ppetb_run_step.fts_string_value,
    ppetb_run_step.fts_value,
    ppetb_run_step.agg_id,
    ppetb_run_step.effective_start,
    ppetb_run_step.effective_end,
    ppetb_run_step.current_flg,
    ppetb_run_step.record_order,
    ppetb_run_step.record_status,
    ppetb_run_step.auth_status,
    ppetb_run_step.maker_id,
    ppetb_run_step.maker_date,
    ppetb_run_step.checker_id,
    ppetb_run_step.checker_date,
    ppetb_run_step.update_id,
    ppetb_run_step.update_date,
    ppetb_run_step.mod_no,
    ppetb_run_step.create_date
   FROM payroll.ppetb_run_step;

COMMENT ON VIEW payroll.ppevw_run_step IS 'V4 NEW: Per-step execution tracking for each run_request.';

-- Permissions

ALTER TABLE payroll.ppevw_run_step OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppevw_run_step TO apipayroll;


-- payroll.ppmtvw_batch source

CREATE OR REPLACE VIEW payroll.ppmtvw_batch
AS SELECT ppmttb_batch.id,
    ppmttb_batch.pay_calendar_id,
    ppmttb_batch.pay_calendar_code,
    ppmttb_batch.period_id,
    ppmttb_batch.pay_group_id,
    ppmttb_batch.pay_group_code,
    ppmttb_batch.period_start,
    ppmttb_batch.period_end,
    ppmttb_batch.batch_type,
    ppmttb_batch.run_label,
    ppmttb_batch.status_code,
    ppmttb_batch.engine_request_id,
    ppmttb_batch.original_run_id,
    ppmttb_batch.reversed_by_run_id,
    ppmttb_batch.submitted_at,
    ppmttb_batch.executed_at,
    ppmttb_batch.calc_completed_at,
    ppmttb_batch.finalized_at,
    ppmttb_batch.costed_flg,
    ppmttb_batch.metadata,
    ppmttb_batch.tenant_code,
    ppmttb_batch.app_code,
    ppmttb_batch.bu_code,
    ppmttb_batch.emp_code,
    ppmttb_batch.description,
    ppmttb_batch.fts_string_value,
    ppmttb_batch.fts_value,
    ppmttb_batch.agg_id,
    ppmttb_batch.effective_start,
    ppmttb_batch.effective_end,
    ppmttb_batch.current_flg,
    ppmttb_batch.record_order,
    ppmttb_batch.record_status,
    ppmttb_batch.auth_status,
    ppmttb_batch.maker_id,
    ppmttb_batch.maker_date,
    ppmttb_batch.checker_id,
    ppmttb_batch.checker_date,
    ppmttb_batch.update_id,
    ppmttb_batch.update_date,
    ppmttb_batch.mod_no,
    ppmttb_batch.create_date
   FROM payroll.ppmttb_batch;

COMMENT ON VIEW payroll.ppmtvw_batch IS 'V4 RENAMED: pprvw_batch → ppmtvw_batch. Now references ppmttb_batch (migrated from pprtb_batch).';

-- Permissions

ALTER TABLE payroll.ppmtvw_batch OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmtvw_batch TO apipayroll;


-- payroll.ppmtvw_manual_adjust source

CREATE OR REPLACE VIEW payroll.ppmtvw_manual_adjust
AS SELECT ppmttb_manual_adjust.id,
    ppmttb_manual_adjust.employee_id,
    ppmttb_manual_adjust.employee_code,
    ppmttb_manual_adjust.period_start,
    ppmttb_manual_adjust.period_end,
    ppmttb_manual_adjust.element_id,
    ppmttb_manual_adjust.element_code,
    ppmttb_manual_adjust.amount,
    ppmttb_manual_adjust.reason,
    ppmttb_manual_adjust.status_code,
    ppmttb_manual_adjust.payroll_run_id,
    ppmttb_manual_adjust.applied_in_run_id,
    ppmttb_manual_adjust.created_by,
    ppmttb_manual_adjust.created_at,
    ppmttb_manual_adjust.metadata,
    ppmttb_manual_adjust.tenant_code,
    ppmttb_manual_adjust.app_code,
    ppmttb_manual_adjust.bu_code,
    ppmttb_manual_adjust.emp_code,
    ppmttb_manual_adjust.description,
    ppmttb_manual_adjust.fts_string_value,
    ppmttb_manual_adjust.fts_value,
    ppmttb_manual_adjust.agg_id,
    ppmttb_manual_adjust.effective_start,
    ppmttb_manual_adjust.effective_end,
    ppmttb_manual_adjust.current_flg,
    ppmttb_manual_adjust.record_order,
    ppmttb_manual_adjust.record_status,
    ppmttb_manual_adjust.auth_status,
    ppmttb_manual_adjust.maker_id,
    ppmttb_manual_adjust.maker_date,
    ppmttb_manual_adjust.checker_id,
    ppmttb_manual_adjust.checker_date,
    ppmttb_manual_adjust.update_id,
    ppmttb_manual_adjust.update_date,
    ppmttb_manual_adjust.mod_no,
    ppmttb_manual_adjust.create_date
   FROM payroll.ppmttb_manual_adjust;

COMMENT ON VIEW payroll.ppmtvw_manual_adjust IS 'V4 RENAMED: pprvw_manual_adjust → ppmtvw_manual_adjust. Now references ppmttb_manual_adjust (FK updated to ppmttb_batch).';

-- Permissions

ALTER TABLE payroll.ppmtvw_manual_adjust OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmtvw_manual_adjust TO apipayroll;


-- payroll.ppmtvw_pay_period source

CREATE OR REPLACE VIEW payroll.ppmtvw_pay_period
AS SELECT ppmttb_pay_period.id,
    ppmttb_pay_period.calendar_id,
    ppmttb_pay_period.calendar_code,
    ppmttb_pay_period.period_seq,
    ppmttb_pay_period.period_year,
    ppmttb_pay_period.period_start,
    ppmttb_pay_period.period_end,
    ppmttb_pay_period.pay_date,
    ppmttb_pay_period.cut_off_date,
    ppmttb_pay_period.status_code,
    ppmttb_pay_period.closed_at,
    ppmttb_pay_period.closed_by,
    ppmttb_pay_period.metadata,
    ppmttb_pay_period.tenant_code,
    ppmttb_pay_period.app_code,
    ppmttb_pay_period.bu_code,
    ppmttb_pay_period.emp_code,
    ppmttb_pay_period.description,
    ppmttb_pay_period.fts_string_value,
    ppmttb_pay_period.fts_value,
    ppmttb_pay_period.agg_id,
    ppmttb_pay_period.effective_start,
    ppmttb_pay_period.effective_end,
    ppmttb_pay_period.current_flg,
    ppmttb_pay_period.record_order,
    ppmttb_pay_period.record_status,
    ppmttb_pay_period.auth_status,
    ppmttb_pay_period.maker_id,
    ppmttb_pay_period.maker_date,
    ppmttb_pay_period.checker_id,
    ppmttb_pay_period.checker_date,
    ppmttb_pay_period.update_id,
    ppmttb_pay_period.update_date,
    ppmttb_pay_period.mod_no,
    ppmttb_pay_period.create_date
   FROM payroll.ppmttb_pay_period;

COMMENT ON VIEW payroll.ppmtvw_pay_period IS 'V4 NEW: Payroll period view. Lifecycle: FUTURE → OPEN → PROCESSING → CLOSED → ADJUSTED.';

-- Permissions

ALTER TABLE payroll.ppmtvw_pay_period OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmtvw_pay_period TO apipayroll;


-- payroll.ppmvw_balance_def source

CREATE OR REPLACE VIEW payroll.ppmvw_balance_def
AS SELECT ppmtb_balance_def.id,
    ppmtb_balance_def.code,
    ppmtb_balance_def.name,
    ppmtb_balance_def.balance_type,
    ppmtb_balance_def.formula_json,
    ppmtb_balance_def.reset_freq_id,
    ppmtb_balance_def.metadata,
    ppmtb_balance_def.tenant_code,
    ppmtb_balance_def.app_code,
    ppmtb_balance_def.bu_code,
    ppmtb_balance_def.emp_code,
    ppmtb_balance_def.description,
    ppmtb_balance_def.fts_string_value,
    ppmtb_balance_def.fts_value,
    ppmtb_balance_def.agg_id,
    ppmtb_balance_def.effective_start,
    ppmtb_balance_def.effective_end,
    ppmtb_balance_def.current_flg,
    ppmtb_balance_def.record_order,
    ppmtb_balance_def.record_status,
    ppmtb_balance_def.auth_status,
    ppmtb_balance_def.maker_id,
    ppmtb_balance_def.maker_date,
    ppmtb_balance_def.checker_id,
    ppmtb_balance_def.checker_date,
    ppmtb_balance_def.update_id,
    ppmtb_balance_def.update_date,
    ppmtb_balance_def.mod_no,
    ppmtb_balance_def.create_date
   FROM payroll.ppmtb_balance_def;

-- Permissions

ALTER TABLE payroll.ppmvw_balance_def OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmvw_balance_def TO apipayroll;


-- payroll.ppmvw_costing_rule source

CREATE OR REPLACE VIEW payroll.ppmvw_costing_rule
AS SELECT ppmtb_costing_rule.id,
    ppmtb_costing_rule.code,
    ppmtb_costing_rule.name,
    ppmtb_costing_rule.level_scope,
    ppmtb_costing_rule.mapping_json,
    ppmtb_costing_rule.metadata,
    ppmtb_costing_rule.tenant_code,
    ppmtb_costing_rule.app_code,
    ppmtb_costing_rule.bu_code,
    ppmtb_costing_rule.emp_code,
    ppmtb_costing_rule.description,
    ppmtb_costing_rule.fts_string_value,
    ppmtb_costing_rule.fts_value,
    ppmtb_costing_rule.agg_id,
    ppmtb_costing_rule.effective_start,
    ppmtb_costing_rule.effective_end,
    ppmtb_costing_rule.current_flg,
    ppmtb_costing_rule.record_order,
    ppmtb_costing_rule.record_status,
    ppmtb_costing_rule.auth_status,
    ppmtb_costing_rule.maker_id,
    ppmtb_costing_rule.maker_date,
    ppmtb_costing_rule.checker_id,
    ppmtb_costing_rule.checker_date,
    ppmtb_costing_rule.update_id,
    ppmtb_costing_rule.update_date,
    ppmtb_costing_rule.mod_no,
    ppmtb_costing_rule.create_date
   FROM payroll.ppmtb_costing_rule;

-- Permissions

ALTER TABLE payroll.ppmvw_costing_rule OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmvw_costing_rule TO apipayroll;


-- payroll.ppmvw_pay_calendar source

CREATE OR REPLACE VIEW payroll.ppmvw_pay_calendar
AS SELECT ppmtb_pay_calendar.id,
    ppmtb_pay_calendar.legal_entity_id,
    ppmtb_pay_calendar.legal_entity_code,
    ppmtb_pay_calendar.frequency_id,
    ppmtb_pay_calendar.code,
    ppmtb_pay_calendar.name,
    ppmtb_pay_calendar.calendar_json,
    ppmtb_pay_calendar.metadata,
    ppmtb_pay_calendar.tenant_code,
    ppmtb_pay_calendar.app_code,
    ppmtb_pay_calendar.bu_code,
    ppmtb_pay_calendar.emp_code,
    ppmtb_pay_calendar.description,
    ppmtb_pay_calendar.fts_string_value,
    ppmtb_pay_calendar.fts_value,
    ppmtb_pay_calendar.agg_id,
    ppmtb_pay_calendar.effective_start,
    ppmtb_pay_calendar.effective_end,
    ppmtb_pay_calendar.current_flg,
    ppmtb_pay_calendar.record_order,
    ppmtb_pay_calendar.record_status,
    ppmtb_pay_calendar.auth_status,
    ppmtb_pay_calendar.maker_id,
    ppmtb_pay_calendar.maker_date,
    ppmtb_pay_calendar.checker_id,
    ppmtb_pay_calendar.checker_date,
    ppmtb_pay_calendar.update_id,
    ppmtb_pay_calendar.update_date,
    ppmtb_pay_calendar.mod_no,
    ppmtb_pay_calendar.create_date
   FROM payroll.ppmtb_pay_calendar;

-- View Triggers

create trigger ppmvw_pay_calendar_instead_of instead of
insert
    or
delete
    or
update
    on
    payroll.ppmvw_pay_calendar for each row execute function payroll.ppmtf_pay_calendar();

-- Permissions

ALTER TABLE payroll.ppmvw_pay_calendar OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmvw_pay_calendar TO apipayroll;


-- payroll.ppmvw_pay_element source

CREATE OR REPLACE VIEW payroll.ppmvw_pay_element
AS SELECT ppmtb_pay_element.id,
    ppmtb_pay_element.code,
    ppmtb_pay_element.name,
    ppmtb_pay_element.classification,
    ppmtb_pay_element.unit,
    ppmtb_pay_element.input_required,
    ppmtb_pay_element.formula_json,
    ppmtb_pay_element.priority_order,
    ppmtb_pay_element.taxable_flag,
    ppmtb_pay_element.pre_tax_flag,
    ppmtb_pay_element.metadata,
    ppmtb_pay_element.tenant_code,
    ppmtb_pay_element.app_code,
    ppmtb_pay_element.bu_code,
    ppmtb_pay_element.emp_code,
    ppmtb_pay_element.description,
    ppmtb_pay_element.fts_string_value,
    ppmtb_pay_element.fts_value,
    ppmtb_pay_element.agg_id,
    ppmtb_pay_element.effective_start,
    ppmtb_pay_element.effective_end,
    ppmtb_pay_element.current_flg,
    ppmtb_pay_element.record_order,
    ppmtb_pay_element.record_status,
    ppmtb_pay_element.auth_status,
    ppmtb_pay_element.maker_id,
    ppmtb_pay_element.maker_date,
    ppmtb_pay_element.checker_id,
    ppmtb_pay_element.checker_date,
    ppmtb_pay_element.update_id,
    ppmtb_pay_element.update_date,
    ppmtb_pay_element.mod_no,
    ppmtb_pay_element.create_date
   FROM payroll.ppmtb_pay_element;

-- View Triggers

create trigger ppmvw_pay_element_instead_of instead of
insert
    or
delete
    or
update
    on
    payroll.ppmvw_pay_element for each row execute function payroll.ppmtf_pay_element();

-- Permissions

ALTER TABLE payroll.ppmvw_pay_element OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmvw_pay_element TO apipayroll;


-- payroll.ppmvw_pay_frequency source

CREATE OR REPLACE VIEW payroll.ppmvw_pay_frequency
AS SELECT ppmtb_pay_frequency.id,
    ppmtb_pay_frequency.code,
    ppmtb_pay_frequency.name,
    ppmtb_pay_frequency.description,
    ppmtb_pay_frequency.period_days,
    ppmtb_pay_frequency.metadata,
    ppmtb_pay_frequency.tenant_code,
    ppmtb_pay_frequency.app_code,
    ppmtb_pay_frequency.bu_code,
    ppmtb_pay_frequency.emp_code,
    ppmtb_pay_frequency.fts_string_value,
    ppmtb_pay_frequency.fts_value,
    ppmtb_pay_frequency.agg_id,
    ppmtb_pay_frequency.effective_start,
    ppmtb_pay_frequency.effective_end,
    ppmtb_pay_frequency.current_flg,
    ppmtb_pay_frequency.record_order,
    ppmtb_pay_frequency.record_status,
    ppmtb_pay_frequency.auth_status,
    ppmtb_pay_frequency.maker_id,
    ppmtb_pay_frequency.maker_date,
    ppmtb_pay_frequency.checker_id,
    ppmtb_pay_frequency.checker_date,
    ppmtb_pay_frequency.update_id,
    ppmtb_pay_frequency.update_date,
    ppmtb_pay_frequency.mod_no,
    ppmtb_pay_frequency.create_date
   FROM payroll.ppmtb_pay_frequency;

-- View Triggers

create trigger ppmvw_pay_frequency_instead_of instead of
insert
    or
delete
    or
update
    on
    payroll.ppmvw_pay_frequency for each row execute function payroll.ppmtf_pay_frequency();

-- Permissions

ALTER TABLE payroll.ppmvw_pay_frequency OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmvw_pay_frequency TO apipayroll;


-- payroll.ppmvw_pay_group source

CREATE OR REPLACE VIEW payroll.ppmvw_pay_group
AS SELECT ppmtb_pay_group.id,
    ppmtb_pay_group.legal_entity_id,
    ppmtb_pay_group.legal_entity_code,
    ppmtb_pay_group.calendar_id,
    ppmtb_pay_group.calendar_code,
    ppmtb_pay_group.bank_account_id,
    ppmtb_pay_group.code,
    ppmtb_pay_group.name,
    ppmtb_pay_group.currency_code,
    ppmtb_pay_group.metadata,
    ppmtb_pay_group.tenant_code,
    ppmtb_pay_group.app_code,
    ppmtb_pay_group.bu_code,
    ppmtb_pay_group.emp_code,
    ppmtb_pay_group.description,
    ppmtb_pay_group.fts_string_value,
    ppmtb_pay_group.fts_value,
    ppmtb_pay_group.agg_id,
    ppmtb_pay_group.effective_start,
    ppmtb_pay_group.effective_end,
    ppmtb_pay_group.current_flg,
    ppmtb_pay_group.record_order,
    ppmtb_pay_group.record_status,
    ppmtb_pay_group.auth_status,
    ppmtb_pay_group.maker_id,
    ppmtb_pay_group.maker_date,
    ppmtb_pay_group.checker_id,
    ppmtb_pay_group.checker_date,
    ppmtb_pay_group.update_id,
    ppmtb_pay_group.update_date,
    ppmtb_pay_group.mod_no,
    ppmtb_pay_group.create_date
   FROM payroll.ppmtb_pay_group;

-- View Triggers

create trigger ppmvw_pay_group_instead_of instead of
insert
    or
delete
    or
update
    on
    payroll.ppmvw_pay_group for each row execute function payroll.ppmtf_pay_group();

-- Permissions

ALTER TABLE payroll.ppmvw_pay_group OWNER TO apipayroll;
GRANT ALL ON TABLE payroll.ppmvw_pay_group TO apipayroll;



-- DROP FUNCTION payroll.fts_string_value_trigger();

CREATE OR REPLACE FUNCTION payroll.fts_string_value_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_fts_value text := '';
BEGIN
    -- KHONG XU LY DELETE DATA
    IF (TG_OP = 'UPDATE') THEN
        p_fts_value := payroll.unaccent(
                        trim(COALESCE(NEW.fts_string_value, '')) || ' ');
        NEW.fts_value := to_tsvector(p_fts_value);
        RETURN NEW;
    ELSEIF (TG_OP = 'INSERT') THEN
        p_fts_value := payroll.unaccent(
                        trim(COALESCE(NEW.fts_string_value, '')) || ' ');
        NEW.fts_value := to_tsvector(p_fts_value);
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.fts_string_value_trigger() OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.fts_string_value_trigger() TO public;
GRANT ALL ON FUNCTION payroll.fts_string_value_trigger() TO apipayroll;

-- DROP FUNCTION payroll.ppbtf_bank_account();

CREATE OR REPLACE FUNCTION payroll.ppbtf_bank_account()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        PERFORM payroll.ppmfn_bank_account_insert(
            NEW.id,
            NEW.legal_entity_id,
            NEW.legal_entity_code,
            NEW.bank_name,
            NEW.account_no,
            NEW.currency_code,
            NEW.metadata,
            NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
            NEW.description,
            NEW.fts_string_value,
            NEW.agg_id, NEW.effective_start, NEW.effective_end,
            NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
            NEW.maker_id, NEW.maker_date,
            NEW.checker_id, NEW.checker_date,
            NEW.update_id, NEW.update_date,
            NEW.mod_no, NEW.create_date
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE payroll.ppbtb_bank_account
        SET
            legal_entity_id   = NEW.legal_entity_id,
            legal_entity_code = NEW.legal_entity_code,
            bank_name         = NEW.bank_name,
            account_no        = NEW.account_no,
            currency_code     = NEW.currency_code,
            metadata          = NEW.metadata,
            tenant_code       = NEW.tenant_code,
            app_code          = NEW.app_code,
            bu_code           = NEW.bu_code,
            emp_code          = NEW.emp_code,
            description       = NEW.description,
            fts_string_value  = NEW.fts_string_value,
            agg_id            = COALESCE(NEW.agg_id, uuid_generate_v4()),
            effective_start   = NEW.effective_start,
            effective_end     = NEW.effective_end,
            current_flg       = NEW.current_flg,
            record_order      = NEW.record_order,
            record_status     = NEW.record_status,
            auth_status       = NEW.auth_status,
            maker_id          = NEW.maker_id,
            maker_date        = NEW.maker_date,
            checker_id        = NEW.checker_id,
            checker_date      = NEW.checker_date,
            update_id         = NEW.update_id,
            update_date       = COALESCE(NEW.update_date, now()),
            mod_no            = COALESCE(NEW.mod_no, 0),
            create_date       = NEW.create_date
        WHERE id = NEW.id;
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE payroll.ppbtb_bank_account
        SET record_status = 'C'
        WHERE id = OLD.id;
        RETURN OLD;
    END IF;

    RETURN NEW;
EXCEPTION WHEN others THEN
    RAISE;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppbtf_bank_account() OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppbtf_bank_account() TO public;
GRANT ALL ON FUNCTION payroll.ppbtf_bank_account() TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_bank_account_insert(p_id numeric, p_legal_entity_id numeric, p_legal_entity_code character varying, p_bank_name character varying, p_account_no character varying, p_currency_code character, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    -- Gán mặc định nếu chưa có
    p_id              := COALESCE(p_id, nextval('payroll.ppbsq_bank_account'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now(); -- Type 2
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppbtb_bank_account (
        id, legal_entity_id, legal_entity_code,
        bank_name, account_no, currency_code,
        metadata, tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_legal_entity_id, p_legal_entity_code,
        p_bank_name, p_account_no, p_currency_code,
        p_metadata, p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_bank_account_insert(p_id numeric, p_legal_entity_id numeric, p_legal_entity_code character varying, p_bank_name character varying, p_account_no character varying, p_currency_code character, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_fts_value tsvector, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    -- Gán mặc định nếu chưa có
    p_id              := COALESCE(p_id, nextval('payroll.ppbsq_bank_account'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now(); -- Type 2
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppbtb_bank_account (
        id, legal_entity_id, legal_entity_code,
        bank_name, account_no, currency_code,
        metadata, tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value, fts_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_legal_entity_id, p_legal_entity_code,
        p_bank_name, p_account_no, p_currency_code,
        p_metadata, p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value, p_fts_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_bank_account_insert(numeric, numeric, varchar, varchar, varchar, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_calendar_insert(p_id numeric, p_legal_entity_id numeric, p_legal_entity_code character varying, p_frequency_id numeric, p_code character varying, p_name jsonb, p_calendar_json jsonb, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    -- Vô hiệu bản hiện hành nếu trùng code trong cùng tenant
    UPDATE payroll.ppmtb_pay_calendar
    SET current_flg = false,
        effective_end = now() - interval '1 second'
    WHERE code = p_code
      AND current_flg = true
      AND tenant_code = COALESCE(p_tenant_code, 'A4B');

    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_calendar'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now();
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_calendar (
        id, legal_entity_id, legal_entity_code, frequency_id,
        code, name, calendar_json, metadata,
        tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_legal_entity_id, p_legal_entity_code, p_frequency_id,
        p_code, p_name, p_calendar_json, p_metadata,
        p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_calendar_insert(p_id numeric, p_legal_entity_id numeric, p_legal_entity_code character varying, p_frequency_id numeric, p_code character varying, p_name jsonb, p_calendar_json jsonb, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_fts_value tsvector, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    -- Vô hiệu bản hiện hành nếu trùng code trong cùng tenant
    UPDATE payroll.ppmtb_pay_calendar
    SET current_flg = false,
        effective_end = now() - interval '1 second'
    WHERE code = p_code
      AND current_flg = true
      AND tenant_code = COALESCE(p_tenant_code, 'A4B');

    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_calendar'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now();
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_calendar (
        id, legal_entity_id, legal_entity_code, frequency_id,
        code, name, calendar_json, metadata,
        tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value, fts_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_legal_entity_id, p_legal_entity_code, p_frequency_id,
        p_code, p_name, p_calendar_json, p_metadata,
        p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value, p_fts_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_calendar_insert(numeric, numeric, varchar, numeric, varchar, jsonb, jsonb, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_element_insert(p_id numeric, p_code character varying, p_name jsonb, p_classification character varying, p_unit character varying, p_input_required boolean, p_formula_json jsonb, p_priority_order integer, p_taxable_flag boolean, p_pre_tax_flag boolean, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    -- Vô hiệu bản hiện hành nếu trùng code trong cùng tenant
    UPDATE payroll.ppmtb_pay_element
    SET current_flg = false,
        effective_end = now() - interval '1 second'
    WHERE code = p_code
      AND current_flg = true
      AND tenant_code = COALESCE(p_tenant_code, 'A4B');

    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_element'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now();
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_element (
        id, code, name,
        classification, unit, input_required,
        formula_json, priority_order, taxable_flag, pre_tax_flag,
        metadata, tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_code, p_name,
        p_classification, p_unit, p_input_required,
        p_formula_json, p_priority_order, p_taxable_flag, p_pre_tax_flag,
        p_metadata, p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_element_insert(p_id numeric, p_code character varying, p_name jsonb, p_classification character varying, p_unit character varying, p_input_required boolean, p_formula_json jsonb, p_priority_order integer, p_taxable_flag boolean, p_pre_tax_flag boolean, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_fts_value tsvector, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    -- Vô hiệu bản hiện hành nếu trùng code trong cùng tenant
    UPDATE payroll.ppmtb_pay_element
    SET current_flg = false,
        effective_end = now() - interval '1 second'
    WHERE code = p_code
      AND current_flg = true
      AND tenant_code = COALESCE(p_tenant_code, 'A4B');

    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_element'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now();
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_element (
        id, code, name,
        classification, unit, input_required,
        formula_json, priority_order, taxable_flag, pre_tax_flag,
        metadata, tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value, fts_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_code, p_name,
        p_classification, p_unit, p_input_required,
        p_formula_json, p_priority_order, p_taxable_flag, p_pre_tax_flag,
        p_metadata, p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value, p_fts_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_element_insert(numeric, varchar, jsonb, varchar, varchar, bool, jsonb, int4, bool, bool, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_frequency_insert(p_id numeric, p_code character varying, p_name jsonb, p_description character varying, p_period_days smallint, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_fts_string_value character varying, p_fts_value tsvector, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_frequency'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now();
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_frequency (
        id, code, name, description, period_days,
        metadata, tenant_code, app_code, bu_code, emp_code,
        fts_string_value, fts_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_code, p_name, p_description, p_period_days,
        p_metadata, p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_fts_string_value, p_fts_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_frequency_insert(p_id numeric, p_code character varying, p_name jsonb, p_description character varying, p_period_days smallint, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_fts_string_value character varying, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_frequency'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := now();
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_frequency (
        id, code, name, description, period_days,
        metadata, tenant_code, app_code, bu_code, emp_code,
        fts_string_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_code, p_name, p_description, p_period_days,
        p_metadata, p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_fts_string_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_frequency_insert(numeric, varchar, jsonb, varchar, int2, jsonb, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_group_insert(p_id numeric, p_legal_entity_id numeric, p_legal_entity_code character varying, p_calendar_id numeric, p_calendar_code character varying, p_bank_account_id numeric, p_code character varying, p_name jsonb, p_currency_code character, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    UPDATE payroll.ppmtb_pay_group
    SET current_flg = false,
        effective_end = now() - interval '1 second'
    WHERE code = p_code
      AND current_flg = true
      AND tenant_code = COALESCE(p_tenant_code, 'A4B');

    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_group'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := COALESCE(p_effective_start, now());
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_group (
        id, legal_entity_id, legal_entity_code,
        calendar_id, calendar_code,
        bank_account_id,
        code, name, currency_code, metadata,
        tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_legal_entity_id, p_legal_entity_code,
        p_calendar_id, p_calendar_code,
        p_bank_account_id,
        p_code, p_name, p_currency_code, p_metadata,
        p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz);

CREATE OR REPLACE FUNCTION payroll.ppmfn_pay_group_insert(p_id numeric, p_legal_entity_id numeric, p_legal_entity_code character varying, p_calendar_id numeric, p_calendar_code character varying, p_bank_account_id numeric, p_code character varying, p_name jsonb, p_currency_code character, p_metadata jsonb, p_tenant_code character varying, p_app_code character varying, p_bu_code character varying, p_emp_code character varying, p_description character varying, p_fts_string_value character varying, p_fts_value tsvector, p_agg_id uuid, p_effective_start timestamp with time zone, p_effective_end timestamp with time zone, p_current_flg boolean, p_record_order integer, p_record_status character varying, p_auth_status character varying, p_maker_id character varying, p_maker_date timestamp with time zone, p_checker_id character varying, p_checker_date timestamp with time zone, p_update_id character varying, p_update_date timestamp with time zone, p_mod_no numeric, p_create_date timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO '$user', 'public'
AS $function$
BEGIN
    UPDATE payroll.ppmtb_pay_group
    SET current_flg = false,
        effective_end = now() - interval '1 second'
    WHERE code = p_code
      AND current_flg = true
      AND tenant_code = COALESCE(p_tenant_code, 'A4B');

    p_id              := COALESCE(p_id, nextval('payroll.ppmsq_pay_group'));
    p_tenant_code     := COALESCE(p_tenant_code, 'A4B');
    p_app_code        := COALESCE(p_app_code, 'HCM');
    p_agg_id          := COALESCE(p_agg_id, uuid_generate_v4());
    p_effective_start := COALESCE(p_effective_start, now());
    p_effective_end   := NULL;
    p_current_flg     := true;
    p_record_order    := COALESCE(p_record_order, 1);
    p_record_status   := COALESCE(p_record_status, 'O');
    p_auth_status     := COALESCE(p_auth_status, 'A');
    p_maker_date      := COALESCE(p_maker_date, now());
    p_mod_no          := COALESCE(p_mod_no, 0);
    p_create_date     := COALESCE(p_create_date, now());

    INSERT INTO payroll.ppmtb_pay_group (
        id, legal_entity_id, legal_entity_code,
        calendar_id, calendar_code,
        bank_account_id,
        code, name, currency_code, metadata,
        tenant_code, app_code, bu_code, emp_code,
        description, fts_string_value, fts_value,
        agg_id, effective_start, effective_end,
        current_flg, record_order, record_status, auth_status,
        maker_id, maker_date, checker_id, checker_date,
        update_id, update_date, mod_no, create_date
    ) VALUES (
        p_id, p_legal_entity_id, p_legal_entity_code,
        p_calendar_id, p_calendar_code,
        p_bank_account_id,
        p_code, p_name, p_currency_code, p_metadata,
        p_tenant_code, p_app_code, p_bu_code, p_emp_code,
        p_description, p_fts_string_value, p_fts_value,
        p_agg_id, p_effective_start, p_effective_end,
        p_current_flg, p_record_order, p_record_status, p_auth_status,
        p_maker_id, p_maker_date, p_checker_id, p_checker_date,
        p_update_id, p_update_date, p_mod_no, p_create_date
    );
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO public;
GRANT ALL ON FUNCTION payroll.ppmfn_pay_group_insert(numeric, numeric, varchar, numeric, varchar, numeric, varchar, jsonb, bpchar, jsonb, varchar, varchar, varchar, varchar, varchar, varchar, tsvector, uuid, timestamptz, timestamptz, bool, int4, varchar, varchar, varchar, timestamptz, varchar, timestamptz, varchar, timestamptz, numeric, timestamptz) TO apipayroll;

-- DROP FUNCTION payroll.ppmtf_pay_calendar();

CREATE OR REPLACE FUNCTION payroll.ppmtf_pay_calendar()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_ntableid numeric;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.effective_start IS NOT NULL AND NEW.effective_start < now()) THEN
            RAISE EXCEPTION 'Violation of the provision in Section 3.2';
        ELSIF (NEW.effective_start IS NOT NULL AND NEW.effective_start > now()) THEN
            RAISE EXCEPTION 'Violation of the provision in Section 3.5';
        END IF;

        PERFORM payroll.ppmfn_pay_calendar_insert(
            NEW.id, NEW.legal_entity_id, NEW.legal_entity_code,
            NEW.frequency_id, NEW.code, NEW.name, NEW.calendar_json, NEW.metadata,
            NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
            NEW.description, NEW.fts_string_value,
            NEW.agg_id, NEW.effective_start, NEW.effective_end,
            NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
            NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
            NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        SELECT max(id) INTO p_ntableid
        FROM payroll.ppmtb_pay_calendar WHERE code = NEW.code;

        IF (NEW.id = p_ntableid) THEN
            PERFORM payroll.ppmfn_pay_calendar_insert(
                NULL, NEW.legal_entity_id, NEW.legal_entity_code,
                NEW.frequency_id, NEW.code, NEW.name, NEW.calendar_json, NEW.metadata,
                NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
                NEW.description, NEW.fts_string_value,
                NULL, NEW.effective_start, NEW.effective_end,
                NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
                NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
                NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
            );
            RETURN NEW;
        END IF;

    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE payroll.ppmtb_pay_calendar
        SET record_status = 'C'
        WHERE code = OLD.code;
        RETURN OLD;
    END IF;

    RETURN NEW;
EXCEPTION WHEN others THEN
    RAISE;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmtf_pay_calendar() OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_calendar() TO public;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_calendar() TO apipayroll;

-- DROP FUNCTION payroll.ppmtf_pay_element();

CREATE OR REPLACE FUNCTION payroll.ppmtf_pay_element()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_ntableid numeric;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.effective_start IS NOT NULL AND NEW.effective_start < now()) THEN
            RAISE EXCEPTION 'Violation of the provision in Section 3.2';
        ELSIF (NEW.effective_start IS NOT NULL AND NEW.effective_start > now()) THEN
            RAISE EXCEPTION 'Violation of the provision in Section 3.5';
        END IF;

        PERFORM payroll.ppmfn_pay_element_insert(
            NEW.id, NEW.code, NEW.name,
            NEW.classification, NEW.unit, NEW.input_required,
            NEW.formula_json, NEW.priority_order, NEW.taxable_flag, NEW.pre_tax_flag,
            NEW.metadata,
            NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
            NEW.description, NEW.fts_string_value,
            NEW.agg_id, NEW.effective_start, NEW.effective_end,
            NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
            NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
            NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        SELECT max(id) INTO p_ntableid
        FROM payroll.ppmtb_pay_element WHERE code = NEW.code;

        IF (NEW.id = p_ntableid) THEN
            PERFORM payroll.ppmfn_pay_element_insert(
                NULL, NEW.code, NEW.name,
                NEW.classification, NEW.unit, NEW.input_required,
                NEW.formula_json, NEW.priority_order, NEW.taxable_flag, NEW.pre_tax_flag,
                NEW.metadata,
                NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
                NEW.description, NEW.fts_string_value,
                NULL, NEW.effective_start, NEW.effective_end,
                NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
                NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
                NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
            );
            RETURN NEW;
        END IF;

    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE payroll.ppmtb_pay_element
        SET record_status = 'C'
        WHERE code = OLD.code;
        RETURN OLD;
    END IF;

    RETURN NEW;
EXCEPTION WHEN others THEN
    RAISE;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmtf_pay_element() OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_element() TO public;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_element() TO apipayroll;

-- DROP FUNCTION payroll.ppmtf_pay_frequency();

CREATE OR REPLACE FUNCTION payroll.ppmtf_pay_frequency()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        PERFORM payroll.ppmfn_pay_frequency_insert(
            NEW.id, NEW.code, NEW.name,
            NEW.description, NEW.period_days, NEW.metadata,
            NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
            NEW.fts_string_value,
            NEW.agg_id, NEW.effective_start, NEW.effective_end,
            NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
            NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
            NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE payroll.ppmtb_pay_frequency
        SET
            code             = NEW.code,
            name             = NEW.name,
            description      = NEW.description,
            period_days      = NEW.period_days,
            metadata         = NEW.metadata,
            tenant_code      = NEW.tenant_code,
            app_code         = NEW.app_code,
            bu_code          = NEW.bu_code,
            emp_code         = NEW.emp_code,
            fts_string_value = NEW.fts_string_value,
            agg_id           = COALESCE(NEW.agg_id, uuid_generate_v4()),
            effective_start  = NEW.effective_start,
            effective_end    = NEW.effective_end,
            current_flg      = NEW.current_flg,
            record_order     = NEW.record_order,
            record_status    = NEW.record_status,
            auth_status      = NEW.auth_status,
            maker_id         = NEW.maker_id,
            maker_date       = NEW.maker_date,
            checker_id       = NEW.checker_id,
            checker_date     = NEW.checker_date,
            update_id        = NEW.update_id,
            update_date      = COALESCE(NEW.update_date, now()),
            mod_no           = COALESCE(NEW.mod_no, 0),
            create_date      = NEW.create_date
        WHERE id = NEW.id;
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE payroll.ppmtb_pay_frequency
        SET record_status = 'C'
        WHERE id = OLD.id;
        RETURN OLD;
    END IF;

    RETURN NEW;
EXCEPTION WHEN others THEN
    RAISE;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmtf_pay_frequency() OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_frequency() TO public;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_frequency() TO apipayroll;

-- DROP FUNCTION payroll.ppmtf_pay_group();

CREATE OR REPLACE FUNCTION payroll.ppmtf_pay_group()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_ntableid numeric;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.effective_start IS NOT NULL AND NEW.effective_start < now()) THEN
            RAISE EXCEPTION 'Violation of the provision in Section 3.2';
        ELSIF (NEW.effective_start IS NOT NULL AND NEW.effective_start > now()) THEN
            RAISE EXCEPTION 'Violation of the provision in Section 3.5';
        END IF;

        PERFORM payroll.ppmfn_pay_group_insert(
            NEW.id, NEW.legal_entity_id, NEW.legal_entity_code,
            NEW.calendar_id, NEW.calendar_code, NEW.bank_account_id,
            NEW.code, NEW.name, NEW.currency_code, NEW.metadata,
            NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
            NEW.description, NEW.fts_string_value,
            NEW.agg_id, NEW.effective_start, NEW.effective_end,
            NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
            NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
            NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        SELECT max(id) INTO p_ntableid
        FROM payroll.ppmtb_pay_group WHERE code = NEW.code;

        IF (NEW.id = p_ntableid) THEN
            PERFORM payroll.ppmfn_pay_group_insert(
                NULL, NEW.legal_entity_id, NEW.legal_entity_code,
                NEW.calendar_id, NEW.calendar_code, NEW.bank_account_id,
                NEW.code, NEW.name, NEW.currency_code, NEW.metadata,
                NEW.tenant_code, NEW.app_code, NEW.bu_code, NEW.emp_code,
                NEW.description, NEW.fts_string_value,
                NULL, NEW.effective_start, NEW.effective_end,
                NEW.current_flg, NEW.record_order, NEW.record_status, NEW.auth_status,
                NEW.maker_id, NEW.maker_date, NEW.checker_id, NEW.checker_date,
                NEW.update_id, NEW.update_date, NEW.mod_no, NEW.create_date
            );
            RETURN NEW;
        END IF;

    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE payroll.ppmtb_pay_group
        SET record_status = 'C'
        WHERE code = OLD.code;
        RETURN OLD;
    END IF;

    RETURN NEW;
EXCEPTION WHEN others THEN
    RAISE;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.ppmtf_pay_group() OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_group() TO public;
GRANT ALL ON FUNCTION payroll.ppmtf_pay_group() TO apipayroll;

-- DROP FUNCTION payroll.unaccent(text);

CREATE OR REPLACE FUNCTION payroll.unaccent(text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE STRICT COST 1
AS $function$
DECLARE
    input_string text := $1;
BEGIN
    input_string := translate(input_string,'áàạãảÁÀẠÃẢ','aaaaaAAAAA');
    input_string := translate(input_string,'ăắằặẵẳĂẮẰẶẴẲ','aaaaaaAAAAAA');
    input_string := translate(input_string,'âấầậẫẩÂẤẦẬẪẨ','aaaaaaAAAAAA');
    input_string := translate(input_string,'đĐ','dD');
    input_string := translate(input_string,'éèẹẽẻÉÈẸẼẺ','eeeeeEEEEE');
    input_string := translate(input_string,'êếềệễểÊẾỀỆỄỂ','eeeeeeEEEEEE');
    input_string := translate(input_string,'íìịĩỉÍÌỊĨỈ','iiiiiIIIII');
    input_string := translate(input_string,'óòọõỏÓÒỌÕỎ','oooooOOOOO');
    input_string := translate(input_string,'ôốồộỗổÔỐỒỘỖỔ','ooooooOOOOOO');
    input_string := translate(input_string,'ơớờợỡởƠỚỜỢỠỞ','ooooooOOOOOO');
    input_string := translate(input_string,'úùụũủÚÙỤŨỦ','uuuuuUUUUU');
    input_string := translate(input_string,'ưứừựữửƯỨỪỰỮỬ','uuuuuuUUUUUU');
    input_string := translate(input_string,'ýỳỵỹỷÝỲỴỸỶ','yyyyyYYYYY');
    RETURN input_string;
END;
$function$
;

-- Permissions

ALTER FUNCTION payroll.unaccent(text) OWNER TO apipayroll;
GRANT ALL ON FUNCTION payroll.unaccent(text) TO public;
GRANT ALL ON FUNCTION payroll.unaccent(text) TO apipayroll;


-- Permissions

GRANT ALL ON SCHEMA payroll TO apipayroll;