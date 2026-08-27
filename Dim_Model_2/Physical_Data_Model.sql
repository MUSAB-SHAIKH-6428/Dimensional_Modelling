create schema dim_model_1;

set search_path to dim_model_1

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date DATE NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL,
    holiday_name VARCHAR(100)
);

CREATE TABLE dim_employee (
    employee_key BIGSERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    role_level VARCHAR(50),
    hire_date DATE,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);
CREATE TABLE dim_department (
    department_key BIGSERIAL PRIMARY KEY,
    department_id INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    manager_id INT,
    location VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);

CREATE TABLE fact_attendance_per_day (
    employee_key BIGINT NOT NULL,
    department_key BIGINT NOT NULL,
    date_key INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    is_present BOOLEAN NOT NULL,
    attendance_count INT NOT NULL,
    hours_worked NUMERIC(5,2),
    CONSTRAINT fk_attendance_employee
        FOREIGN KEY (employee_key)
        REFERENCES dim_employee(employee_key),
    CONSTRAINT fk_attendance_department
        FOREIGN KEY (department_key)
        REFERENCES dim_department(department_key),
    CONSTRAINT fk_attendance_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),
    CONSTRAINT uq_employee_date
        UNIQUE (employee_key, date_key)
);

CREATE TABLE fact_pto_balance (
    pto_key BIGSERIAL PRIMARY KEY,
    employee_key BIGINT NOT NULL,
    year INT NOT NULL,
    pto_days_available NUMERIC(5,2) NOT NULL,
    pto_days_used NUMERIC(5,2) NOT NULL,
    CONSTRAINT fk_pto_employee
        FOREIGN KEY (employee_key)
        REFERENCES dim_employee(employee_key),
    CONSTRAINT uq_employee_year
        UNIQUE (employee_key, year)
);