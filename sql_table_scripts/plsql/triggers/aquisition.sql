CREATE OR REPLACE TRIGGER products_trigger
BEFORE INSERT OR UPDATE ON pbd_products
FOR EACH ROW
DECLARE
    v_total_cost NUMBER;
    v_stocks NUMBER;
    v_percent_from_total_cost NUMBER := 0.5;
BEGIN
    v_total_cost := :new.available_quantity * :new.price;
    IF UPDATING THEN
        v_total_cost := v_total_cost - :old.available_quantity * :old.price;
    END IF;
    v_total_cost := v_percent_from_total_cost * v_total_cost;
    
    SELECT stocks INTO v_stocks FROM pbd_shops WHERE shop_id = :new.shop_id;
    IF (v_stocks < v_total_cost) THEN
        RAISE_APPLICATION_ERROR(-20102, 'Not enough stocks in shop ' || :new.shop_id || '. Required: ' || v_total_cost || ', but there are ' || v_stocks);
    END IF;
    
    UPDATE pbd_shops SET stocks = v_stocks - v_total_cost WHERE shop_id = :new.shop_id;
END;
/

CREATE OR REPLACE TRIGGER order_trigger
BEFORE INSERT OR UPDATE ON pbd_orders
FOR EACH ROW
DECLARE
    v_product_price pbd_products.price%TYPE;
    v_delivering_price pbd_shipping_methods.delivering_price%TYPE;
BEGIN
    SELECT price INTO v_product_price FROM pbd_products p WHERE p.product_id = :new.product_id;
    SELECT delivering_price INTO v_delivering_price FROM pbd_shipping_methods s WHERE s.shipping_id = :new.shipping_id;
    :new.total_amount := v_product_price * :new.quantity + v_delivering_price;
END;
/

CREATE OR REPLACE TRIGGER order_trigger_update_other_dependencies
AFTER INSERT OR UPDATE ON pbd_orders
FOR EACH ROW
DECLARE
    v_available_quantity pbd_products.available_quantity%TYPE;
    v_shop_id pbd_products.shop_id%TYPE;
BEGIN
    SELECT available_quantity INTO v_available_quantity FROM pbd_products WHERE product_id = :new.product_id;
    SELECT shop_id INTO v_shop_id FROM pbd_products WHERE product_id = :new.product_id;
    
    v_available_quantity := v_available_quantity - :new.quantity;
    IF (v_available_quantity < 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'Quantity not enough for product ' || :new.product_id);
    END IF;
    
    UPDATE pbd_products SET available_quantity = v_available_quantity WHERE product_id = :new.product_id;
    UPDATE pbd_shops SET stocks = stocks + :new.total_amount WHERE shop_id = v_shop_id;
END;
/

--test order transition
DECLARE
    v_user_id NUMBER := 1;
    v_shipping_id NUMBER := 3;
    v_product_id NUMBER := 4;
    v_quantity NUMBER := 10;
    
    v_inserted_product_id NUMBER;
BEGIN
    utils_pkg.print_product_status(v_product_id);
    INSERT INTO pbd_orders (user_id, shipping_id, product_id, quantity) VALUES (v_user_id, v_shipping_id, v_product_id, v_quantity);
    utils_pkg.print_product_status(v_product_id);
    ROLLBACK;

END;
/

--test product aquisition
DECLARE
    v_product_name pbd_products.product_name%TYPE := 'test';
    v_price NUMBER := 10;
    v_available_quantity NUMBER := 15;
    v_shop_id NUMBER := 3;
    
    v_inserted_product_id NUMBER;
BEGIN
    utils_pkg.print_shop_status(v_shop_id);
    INSERT INTO pbd_products (product_name, price, available_quantity, shop_id, description) VALUES (v_product_name, v_price, v_available_quantity, v_shop_id, '');
    SELECT MAX(product_id) into v_inserted_product_id FROM pbd_products;
    utils_pkg.print_product_status(v_inserted_product_id);
    ROLLBACK;
END;
/

SELECT * FROM pbd_orders;
SELECT * FROM pbd_shops;
SELECT * FROM pbd_products;

