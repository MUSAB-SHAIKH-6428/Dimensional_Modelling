create table dim_product (
    product_key bigserial primary key,
    product_id int not null,
    product_name varchar(150) not null,
    category varchar(100),
    supplier_id int,
    start_date date not null,
    end_date date,
    is_current boolean not null
);

create table dim_customer (
    customer_key bigserial primary key,
    customer_id int not null,
    customer_name varchar(150) not null,
    country varchar(100),
    acquisition_channel varchar(100),
    signup_date date,
    start_date date not null,
    end_date date,
    is_current boolean not null
);

create table dim_date (
    date_key int primary key,
    date date not null,
    day int,
    month int,
    month_name varchar(20),
    quarter int,
    year int,
    day_of_week int,
    is_weekend boolean,
    is_holiday boolean,
    holiday_name varchar(100)
);

create table fact_order_item (
    order_id int not null,
    product_key bigint not null,
    customer_key bigint not null,
    date_key int not null,
    quantity int not null,
    unit_price numeric(12,2) not null,
    discount numeric(12,2),
    revenue numeric(12,2) not null,

    foreign key (product_key)
        references dim_product(product_key),

    foreign key (customer_key)
        references dim_customer(customer_key),

    foreign key (date_key)
        references dim_date(date_key)
);