CREATE TABLE dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    supplier_id INT,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);

CREATE TABLE dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    country VARCHAR(100),
    acquisition_channel VARCHAR(100),
    signup_date DATE,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    day_of_week INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(100)
);

CREATE TABLE fact_order_item (
    order_id INT NOT NULL,
    product_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    date_key INT NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    discount NUMERIC(12,2),
    revenue NUMERIC(12,2) NOT NULL,

    FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key)
);