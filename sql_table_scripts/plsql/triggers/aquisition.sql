CREATE OR REPLACE TRIGGER trg_delete_prod
BEFORE DELETE ON pbd_products
FOR EACH ROW
DECLARE
    v_product_id pbd_products.product_id%TYPE;
    v_temp NUMBER := 0;
    v_percent_from_total_cost NUMBER := 0.5;
    v_total_cost NUMBER;
BEGIN
    SELECT count(*) into v_temp FROM pbd_orders WHERE product_id = :old.product_id;
    
    IF v_temp > 0 THEN
        RAISE_APPLICATION_ERROR(-20200, 'Inregistrarea nu poate fi stearsa. Exista dependente externe.');
    END IF;
    
    v_total_cost := v_percent_from_total_cost * :old.available_quantity * :old.price;
    UPDATE pbd_shops SET stocks = stocks + v_total_cost WHERE shop_id = :old.shop_id;
END;

CREATE OR REPLACE TRIGGER trg_delete_shipping
BEFORE DELETE ON pbd_shipping_methods
FOR EACH ROW
DECLARE
    v_provider_id pbd_shipping_methods.shipping_id%TYPE;
    v_temp NUMBER := 0;
BEGIN
    SELECT count(*) into v_temp FROM pbd_orders WHERE shipping_id = :old.shipping_id;
    
    IF v_temp > 0 THEN
        RAISE_APPLICATION_ERROR(-20200, 'Inregistrarea nu poate fi stearsa. Exista dependente externe.');
    END IF;
END;


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
        UPDATE pbd_shops SET stocks = stocks + v_percent_from_total_cost*:old.available_quantity * :old.price WHERE shop_id = :old.shop_id;
    END IF;
    v_total_cost := v_percent_from_total_cost * v_total_cost;
    
    SELECT stocks INTO v_stocks FROM pbd_shops WHERE shop_id = :new.shop_id;
    IF (v_stocks < v_total_cost) THEN
        RAISE_APPLICATION_ERROR(-20102, 'Not enough stocks in shop ' || :new.shop_id || '. Required: ' || v_total_cost || ', but there are ' || v_stocks);
    END IF;
    
    UPDATE pbd_shops SET stocks = v_stocks - v_total_cost WHERE shop_id = :new.shop_id;

END;
/

CREATE OR REPLACE TRIGGER order_trigger_insert_or_update
BEFORE INSERT OR UPDATE ON pbd_orders
FOR EACH ROW
DECLARE
    v_product_price pbd_products.price%TYPE;
    v_date_acquired pbd_products.date_acquired%TYPE;
    v_delivering_price pbd_shipping_methods.delivering_price%TYPE;
    
    v_available_quantity pbd_products.available_quantity%TYPE;
    v_quantity_of_product_id_until_order_date NUMBER := 0;
    v_shop_id pbd_products.shop_id%TYPE;
BEGIN
    --updateaza total amount la pbd_orders
    SELECT price, date_acquired INTO v_product_price, v_date_acquired FROM pbd_products p WHERE p.product_id = :new.product_id;
    IF (:new.date_ordered < v_date_acquired) THEN
        RAISE_APPLICATION_ERROR(-20101, 'Product was not available at the date ' || :new.date_ordered);
    END IF;

    SELECT delivering_price INTO v_delivering_price FROM pbd_shipping_methods s WHERE s.shipping_id = :new.shipping_id;
    :new.total_amount := v_product_price * :new.quantity + v_delivering_price;

    --verifica availabilitatea cantitatii
    SELECT shop_id INTO v_shop_id FROM pbd_products WHERE product_id = :new.product_id;

    IF INSERTING THEN
        SELECT available_quantity INTO v_available_quantity FROM pbd_products WHERE product_id = :new.product_id;
        SELECT nvl(sum(quantity), 0) INTO v_quantity_of_product_id_until_order_date FROM pbd_orders WHERE product_id = :new.product_id;
        DBMS_OUTPUT.PUT_LINE('Available quantity for product id ' || :new.product_id || ' is ' || (v_available_quantity - v_quantity_of_product_id_until_order_date));
        v_available_quantity := v_available_quantity - v_quantity_of_product_id_until_order_date - :new.quantity;
        IF (v_available_quantity < 0) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Quantity not enough for product ' || :new.product_id);
        END IF;
    END IF;
    
    --UPDATE pbd_products SET available_quantity = v_available_quantity WHERE product_id = :new.product_id;
    UPDATE pbd_shops SET stocks = stocks + :new.total_amount WHERE shop_id = v_shop_id;
END;
/

CREATE OR REPLACE TRIGGER order_trigger_update
AFTER UPDATE ON pbd_orders
DECLARE
    CURSOR v_product_cursor IS SELECT DISTINCT(product_id) as product_id FROM pbd_products;
    v_available_quantity pbd_products.available_quantity%TYPE;
    v_quantity_of_product_id NUMBER := 0;
BEGIN
    --verifica availabilitatea cantitatii
    FOR v_product IN v_product_cursor LOOP
        SELECT available_quantity INTO v_available_quantity FROM pbd_products WHERE product_id = v_product.product_id;

        SELECT nvl(sum(quantity), 0) INTO v_quantity_of_product_id FROM pbd_orders WHERE product_id = v_product.product_id;
        v_available_quantity := v_available_quantity - v_quantity_of_product_id;
        IF (v_available_quantity < 0) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Quantity not enough for last updated product ' || v_product.product_id);
        END IF;
    END LOOP;
END;
/

--test order transition
SET SERVEROUTPUT ON;
DECLARE
    v_user_id NUMBER := 2;
    v_shipping_id NUMBER := 3;
    v_product_id NUMBER := 18;
    v_quantity NUMBER := 1;
    v_date_ordered DATE := TO_DATE('2022-01-01','YYYY-MM-DD');
    v_inserted_product_id NUMBER;
BEGIN
    utils_pkg.print_product_status(v_product_id);
    --orders_pack.insert_item(v_user_id, v_shipping_id, v_product_id, v_quantity, NULL, v_date_ordered);
    UPDATE pbd_orders SET DATE_ORDERED = TO_DATE('2021-01-01','YYYY-MM-DD') WHERE order_id = 8;
    utils_pkg.print_product_status(v_product_id);
    --ROLLBACK;
END;
/
ROLLBACK;

--test product aquisition
DECLARE
    v_product_name pbd_products.product_name%TYPE := 'test';
    v_price NUMBER := 10;
    v_available_quantity NUMBER := 15;
    v_shop_id NUMBER := 2;
    v_date_acquired DATE := TO_DATE('2022-01-01','YYYY-MM-DD');
    
    v_inserted_product_id NUMBER;
BEGIN
    utils_pkg.print_shop_status(v_shop_id);
    --products_pack.insert_item(v_product_name, v_price, v_date_acquired, v_available_quantity, v_shop_id, '');
    products_pack.update_item(v_product_name, v_price, v_date_acquired, v_available_quantity, v_shop_id, '', v_product_name, v_price, v_shop_id);
    SELECT MAX(product_id) into v_inserted_product_id FROM pbd_products;
    utils_pkg.print_product_status(v_inserted_product_id);
    ROLLBACK;
END;
/
commit;

SELECT * FROM pbd_orders;
SELECT * FROM pbd_app_users;
SELECT * FROM pbd_shops;
SELECT * FROM pbd_products;
SELECT * FROM pbd_orders WHERE product_id = 18;

SELECT product_id, product_name, price, available_quantity as quantity, shop_id, description, (available_quantity - NVL((SELECT SUM(quantity) FROM pbd_orders o WHERE o.product_id = product_id), 0)) as available_quantity from pbd_products