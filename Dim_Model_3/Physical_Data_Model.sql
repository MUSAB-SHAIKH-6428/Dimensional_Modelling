create schema if not exists dim_model_2;

set search_path to dim_model_2;

create table dim_agent (
    agent_key bigserial primary key,
    agent_id int not null,
    agent_name varchar(100) not null,
    primary_skills varchar(255),
    shift_id int,
    hire_date date,
    performance_tier varchar(50)
);

create table dim_queue (
    queue_key bigserial primary key,
    queue_id int not null,
    queue_name varchar(100) not null,
    department varchar(100),
    priority_level varchar(50)
);

create table dim_customer (
    customer_key bigserial primary key,
    customer_id int not null,
    customer_name varchar(100) not null,
    account_type varchar(50),
    region varchar(100)
);

create table dim_date (
    date_key int primary key,
    date date not null,
    day int,
    day_of_week int,
    month int,
    month_name varchar(20),
    quarter int,
    year int,
    is_weekend boolean,
    is_holiday boolean,
    holiday_name varchar(100)
);

create table dim_time (
    time_key int primary key,
    time time not null,
    hour int,
    minute int,
    am_pm varchar(2),
    shift_period varchar(30)
);

create table dim_call_status (
    call_status_key bigserial primary key,
    call_outcome varchar(20) not null,
    first_call_resolution varchar(3) not null
);

create table fact_call (
    call_key bigserial primary key,
    call_id int not null,
    agent_key bigint not null,
    queue_key bigint not null,
    customer_key bigint not null,
    date_key int not null,
    time_key int not null,
    call_status_key bigint not null,
    duration_seconds int,
    hold_time_seconds int,
    customer_satisfaction int,
    constraint fk_call_agent
        foreign key (agent_key)
        references dim_agent(agent_key),
    constraint fk_call_queue
        foreign key (queue_key)
        references dim_queue(queue_key),
    constraint fk_call_customer
        foreign key (customer_key)
        references dim_customer(customer_key),
    constraint fk_call_date
        foreign key (date_key)
        references dim_date(date_key),
    constraint fk_call_time
        foreign key (time_key)
        references dim_time(time_key),
    constraint fk_call_status
        foreign key (call_status_key)
        references dim_call_status(call_status_key),
    constraint chk_satisfaction
        check (customer_satisfaction between 1 and 5)
);