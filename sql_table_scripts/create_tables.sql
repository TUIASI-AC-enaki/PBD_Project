CREATE TABLE pbd_locations(
    location_id NUMBER(4) NOT NULL,
    street_address VARCHAR2(50) NOT NULL,
    city VARCHAR2(30) NOT NULL,
    country VARCHAR2(30) NOT NULL,
    CONSTRAINT location_id_pk PRIMARY KEY (location_id),
    CONSTRAINT location_id_uk UNIQUE (street_address, city, country));

CREATE TABLE pbd_shops(
    shop_id NUMBER(4) NOT NULL,
    shop_name VARCHAR2(20) NOT NULL,
    stocks NUMBER DEFAULT 100,
    location_id NUMBER(4) NOT NULL,
    CONSTRAINT shop_id_pk PRIMARY KEY(shop_id),
    CONSTRAINT shop_location_id_fk FOREIGN KEY (location_id) REFERENCES pbd_locations,
    CONSTRAINT shop_uk UNIQUE (shop_name, location_id));
    
CREATE TABLE pbd_products(
    product_id NUMBER(4) NOT NULL,
    product_name VARCHAR2(20) NOT NULL,
    price NUMBER(6, 2) NOT NULL,
    date_acquired DATE DEFAULT sysdate NOT NULL,
    available_quantity NUMBER NOT NULL,
    shop_id NUMBER(4) NOT NULL,
    description VARCHAR2(100),
    CONSTRAINT product_id_pk PRIMARY KEY(product_id),
    CONSTRAINT product_shop_id_fk FOREIGN KEY(shop_id) REFERENCES pbd_shops,
    CONSTRAINT price_range_ch CHECK (price > 0 and price < 1000000),
    CONSTRAINT product_uk UNIQUE (product_name, price, shop_id));
    
CREATE TABLE pbd_shipping_methods(
    shipping_id NUMBER(4) NOT NULL,
    provider VARCHAR2(100) NOT NULL,
    delivering_price NUMBER(6,2) NOT NULL,
    CONSTRAINT shipping_id_pk PRIMARY KEY(shipping_id),
    CONSTRAINT delivering_price_range_ch CHECK (delivering_price > 0 and delivering_price < 1000000),
    CONSTRAINT shipping_uk UNIQUE (provider));
    
CREATE TABLE pbd_app_users(
    user_id NUMBER(4) NOT NULL ,
    first_name VARCHAR2(20) NOT NULL,
    last_name VARCHAR2(20) NOT NULL,
    location_id NUMBER(4) NOT NULL,
    email VARCHAR2(30) NOT NULL UNIQUE,
    phone VARCHAR2(20) NOT NULL UNIQUE,
    CONSTRAINT user_id_pk PRIMARY KEY(user_id),
    CONSTRAINT user_location_id_fk FOREIGN KEY(location_id) REFERENCES pbd_locations);

CREATE TABLE pbd_accounts(
    user_id NUMBER(4) NOT NULL,
    username VARCHAR2(30) NOT NULL UNIQUE,
    password VARCHAR2(100) NOT NULL,
    account_type VARCHAR2(10) NOT NULL,
    CONSTRAINT account_id_pk PRIMARY KEY(user_id),
    CONSTRAINT account_user_id_fk FOREIGN KEY(user_id) REFERENCES pbd_app_users,
    CONSTRAINT account_user_pass_ch CHECK (length(password) >= 6)
);
    
CREATE TABLE pbd_orders(
    order_id NUMBER(4) NOT NULL,
    user_id NUMBER(4) NOT NULL,
    shipping_id NUMBER(4) NOT NULL,
    product_id NUMBER(4) NOT NULL,
    quantity NUMBER(4) NOT NULL,
    total_amount NUMBER(10, 2),
    date_ordered DATE DEFAULT sysdate NOT NULL,
    CONSTRAINT order_id_pk PRIMARY KEY(order_id), 
    CONSTRAINT order_user_id_fk FOREIGN KEY(user_id) REFERENCES pbd_app_users,
    CONSTRAINT order_shipping_id_fk FOREIGN KEY(shipping_id) REFERENCES pbd_shipping_methods,
    CONSTRAINT order_product_id_fk FOREIGN KEY(product_id) REFERENCES pbd_products,
    CONSTRAINT quantity_range_ch CHECK (quantity > 0 and quantity < 10000),
    CONSTRAINT amount_range_ch CHECK (total_amount > 0 and total_amount < 10000000000)
);
    
CREATE SEQUENCE pbd_location_sequence_incrementer START WITH 1 INCREMENT BY 1;   
CREATE SEQUENCE pbd_shop_sequence_incrementer START WITH 1 INCREMENT BY 1;   
CREATE SEQUENCE pbd_product_sequence_incrementer START WITH 1 INCREMENT BY 1;   
CREATE SEQUENCE pbd_shipping_method_sequence_incrementer START WITH 1 INCREMENT BY 1;   
CREATE SEQUENCE pbd_user_sequence_incrementer START WITH 1 INCREMENT BY 1;   
CREATE SEQUENCE pbd_order_sequence_incrementer START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER pbd_location_inc_on_insert_trigger
BEFORE INSERT
    ON pbd_locations
    FOR EACH ROW
BEGIN
    :NEW.location_id := pbd_location_sequence_incrementer.nextval;
END;
/

CREATE OR REPLACE TRIGGER pbd_shop_inc_on_insert_trigger
BEFORE INSERT
    ON pbd_shops
    FOR EACH ROW
BEGIN
    :NEW.shop_id := pbd_shop_sequence_incrementer.nextval;
END;
/

CREATE OR REPLACE TRIGGER pbd_product_inc_on_insert_trigger
BEFORE INSERT
    ON pbd_products
    FOR EACH ROW
BEGIN
    :NEW.product_id := pbd_product_sequence_incrementer.nextval;
END;
/

CREATE OR REPLACE TRIGGER pbd_shipping_inc_on_insert_trigger
BEFORE INSERT
    ON pbd_shipping_methods
    FOR EACH ROW
BEGIN
    :NEW.shipping_id := pbd_shipping_method_sequence_incrementer.nextval;
END;
/

CREATE OR REPLACE TRIGGER pbd_user_inc_on_insert_trigger
BEFORE INSERT
    ON pbd_app_users
    FOR EACH ROW
BEGIN
    :NEW.user_id := pbd_user_sequence_incrementer.nextval;
END;
/

CREATE OR REPLACE TRIGGER pbd_order_inc_on_insert_trigger
BEFORE INSERT
    ON pbd_orders
    FOR EACH ROW
BEGIN
    :NEW.order_id := pbd_order_sequence_incrementer.nextval;
END;
/

/* this trigger fuked our lives
CREATE OR REPLACE TRIGGER pbd_order_date_trigger
BEFORE INSERT
    ON pbd_orders
    FOR EACH ROW
BEGIN
    :NEW.date_ordered := SYSDATE;
END;
/
*/




