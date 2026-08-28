create schema if not exists dim_model_1;

set search_path to dim_model_1;

create table dim_date (
    date_key int primary key,
    date date not null,
    day int not null,
    day_of_week int not null,
    month int not null,
    month_name varchar(20) not null,
    quarter int not null,
    year int not null,
    is_weekend boolean not null,
    is_holiday boolean not null,
    holiday_name varchar(100)
);

create table dim_employee (
    employee_key bigserial primary key,
    employee_id int not null,
    employee_name varchar(100) not null,
    role_level varchar(50),
    hire_date date,
    start_date date not null,
    end_date date,
    is_current boolean not null
);

create table dim_department (
    department_key bigserial primary key,
    department_id int not null,
    department_name varchar(100) not null,
    manager_id int,
    location varchar(100),
    start_date date not null,
    end_date date,
    is_current boolean not null
);

create table fact_attendance_per_day (
    employee_key bigint not null,
    department_key bigint not null,
    date_key int not null,
    status varchar(20) not null,
    is_present boolean not null,
    attendance_count int not null,
    hours_worked numeric(5,2),
    constraint fk_attendance_employee
        foreign key (employee_key)
        references dim_employee(employee_key),
    constraint fk_attendance_department
        foreign key (department_key)
        references dim_department(department_key),
    constraint fk_attendance_date
        foreign key (date_key)
        references dim_date(date_key),
    constraint uq_employee_date
        unique (employee_key, date_key)
);

create table fact_pto_balance (
    pto_key bigserial primary key,
    employee_key bigint not null,
    year int not null,
    pto_days_available numeric(5,2) not null,
    pto_days_used numeric(5,2) not null,
    constraint fk_pto_employee
        foreign key (employee_key)
        references dim_employee(employee_key),
    constraint uq_employee_year
        unique (employee_key, year)
);