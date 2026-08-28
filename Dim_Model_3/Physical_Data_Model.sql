create schema dim_model_2

set search_path to dim_model_2

CREATE TABLE dim_agent (
    agent_key BIGSERIAL PRIMARY KEY,
    agent_id INT NOT NULL,
    agent_name VARCHAR(100) NOT NULL,
    primary_skills VARCHAR(255),
    shift_id INT,
    hire_date DATE,
    performance_tier VARCHAR(50)
);

CREATE TABLE dim_queue (
    queue_key BIGSERIAL PRIMARY KEY,
    queue_id INT NOT NULL,
    queue_name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    priority_level VARCHAR(50)
);

CREATE TABLE dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50),
    region VARCHAR(100)
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date DATE NOT NULL,
    day INT,
    day_of_week INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(100)
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
    time TIME NOT NULL,
    hour INT,
    minute INT,
    am_pm VARCHAR(2),
    shift_period VARCHAR(30)
);

CREATE TABLE dim_call_status (
    call_status_key BIGSERIAL PRIMARY KEY,
    call_outcome VARCHAR(20) NOT NULL,
    first_call_resolution VARCHAR(3) NOT NULL
);

CREATE TABLE fact_call (
    call_key BIGSERIAL PRIMARY KEY,
    call_id INT NOT NULL,
    agent_key BIGINT NOT NULL,
    queue_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    date_key INT NOT NULL,
    time_key INT NOT NULL,
    call_status_key BIGINT NOT NULL,
    duration_seconds INT,
    hold_time_seconds INT,
    customer_satisfaction INT,
    CONSTRAINT fk_call_agent
        FOREIGN KEY (agent_key)
        REFERENCES dim_agent(agent_key),
    CONSTRAINT fk_call_queue
        FOREIGN KEY (queue_key)
        REFERENCES dim_queue(queue_key),
    CONSTRAINT fk_call_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_call_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),
    CONSTRAINT fk_call_time
        FOREIGN KEY (time_key)
        REFERENCES dim_time(time_key),
    CONSTRAINT fk_call_status
        FOREIGN KEY (call_status_key)
        REFERENCES dim_call_status(call_status_key),
    CONSTRAINT chk_satisfaction
        CHECK (customer_satisfaction BETWEEN 1 AND 5)
);