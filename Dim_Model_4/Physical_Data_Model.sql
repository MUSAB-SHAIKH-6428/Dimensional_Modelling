CREATE SCHEMA IF NOT EXISTS loyalty_model;

CREATE TABLE loyalty_model.dim_member (
    member_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL,
    member_name VARCHAR(100),
    signup_date DATE,
    country VARCHAR(50),
    segment VARCHAR(20),
    is_vip BOOLEAN,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
);

CREATE TABLE loyalty_model.dim_tier (
    tier_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tier_id INT NOT NULL,
    tier_name VARCHAR(20) NOT NULL,
    min_annual_spend NUMERIC(12,2),
    point_multiplier NUMERIC(5,2),
    annual_benefits_value NUMERIC(12,2)
);

CREATE TABLE loyalty_model.dim_campaign (
    campaign_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaign_id INT NOT NULL,
    campaign_name VARCHAR(100),
    campaign_type VARCHAR(30),
    start_date DATE,
    end_date DATE,
    point_multiplier NUMERIC(5,2),
    campaign_cost NUMERIC(12,2)
);

CREATE TABLE loyalty_model.dim_date (
    date_key INT PRIMARY KEY,
    date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    is_month_end BOOLEAN
);

CREATE TABLE loyalty_model.fact_point_earning (
    earning_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id INT NOT NULL,
    member_key INT NOT NULL,
    tier_key INT NOT NULL,
    campaign_key INT,
    date_key INT NOT NULL,
    earning_type VARCHAR(30),
    transaction_amount NUMERIC(12,2),
    points_earned INT,
    FOREIGN KEY (member_key) REFERENCES loyalty_model.dim_member(member_key),
    FOREIGN KEY (tier_key) REFERENCES loyalty_model.dim_tier(tier_key),
    FOREIGN KEY (campaign_key) REFERENCES loyalty_model.dim_campaign(campaign_key),
    FOREIGN KEY (date_key) REFERENCES loyalty_model.dim_date(date_key)
);

CREATE TABLE loyalty_model.fact_point_redemption (
    redemption_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    redemption_id INT NOT NULL,
    member_key INT NOT NULL,
    tier_key INT NOT NULL,
    date_key INT NOT NULL,
    reward_type VARCHAR(30),
    points_redeemed INT,
    reward_value NUMERIC(12,2),
    FOREIGN KEY (member_key) REFERENCES loyalty_model.dim_member(member_key),
    FOREIGN KEY (tier_key) REFERENCES loyalty_model.dim_tier(tier_key),
    FOREIGN KEY (date_key) REFERENCES loyalty_model.dim_date(date_key)
);

CREATE TABLE loyalty_model.fact_point_balance_monthly (
    balance_snapshot_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_key INT NOT NULL,
    tier_key INT NOT NULL,
    date_key INT NOT NULL,
    points_balance INT,
    points_earned_month INT,
    points_redeemed_month INT,
    points_expired_month INT,
    FOREIGN KEY (member_key) REFERENCES loyalty_model.dim_member(member_key),
    FOREIGN KEY (tier_key) REFERENCES loyalty_model.dim_tier(tier_key),
    FOREIGN KEY (date_key) REFERENCES loyalty_model.dim_date(date_key),
    UNIQUE (member_key, date_key)
);
