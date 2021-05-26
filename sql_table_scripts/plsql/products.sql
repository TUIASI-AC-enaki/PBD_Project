CREATE OR REPLACE PACKAGE products_pack IS
    PROCEDURE insert_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_acquired_date IN pbd_products.date_acquired%TYPE,
        p_available_quantity IN pbd_products.available_quantity%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE
    );
    PROCEDURE delete_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE
    );
    PROCEDURE update_item(
        p_product_name IN pbd_products.product_name%TYPE,
        p_price IN pbd_products.price%TYPE,
        p_acquired_date IN pbd_products.date_acquired%TYPE,
        p_available_quantity IN pbd_products.available_quantity%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE,
        p_product_name_old IN pbd_products.product_name%TYPE,
        p_price_old IN pbd_products.price%TYPE,
        p_shop_id_old IN pbd_products.shop_id%TYPE
    );
END products_pack;
/
CREATE OR REPLACE PACKAGE BODY products_pack IS
    PROCEDURE insert_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_acquired_date IN pbd_products.date_acquired%TYPE,
        p_available_quantity IN pbd_products.available_quantity%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE
    ) IS
    BEGIN
        INSERT INTO pbd_products (product_name, price, date_acquired, available_quantity, shop_id, description) 
            VALUES
        (p_product_name, p_price, p_acquired_date, p_available_quantity, p_shop_id, p_description);
    END;
    
    PROCEDURE delete_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE
    ) IS
    BEGIN
        DELETE FROM pbd_products 
        WHERE product_name = p_product_name AND price = p_price AND shop_id = p_shop_id;
    END;
    
    PROCEDURE update_item(
        p_product_name IN pbd_products.product_name%TYPE,
        p_price IN pbd_products.price%TYPE,
        p_acquired_date IN pbd_products.date_acquired%TYPE,
        p_available_quantity IN pbd_products.available_quantity%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE,
        p_product_name_old IN pbd_products.product_name%TYPE,
        p_price_old IN pbd_products.price%TYPE,
        p_shop_id_old IN pbd_products.shop_id%TYPE
    ) IS
        v_max_order_date DATE;
        v_total_quantity NUMBER;
        v_product_id pbd_products.product_id%TYPE;
    BEGIN
        SELECT product_id INTO v_product_id FROM pbd_products WHERE product_name = p_product_name_old AND price = p_price_old AND shop_id = p_shop_id_old;
        SELECT MAX(date_ordered) INTO v_max_order_date FROM pbd_orders WHERE product_id = v_product_id;
        DBMS_OUTPUT.PUT_LINE('Max date: '  || v_max_order_date);
        IF (v_max_order_date IS NOT NULL AND v_max_order_date < p_acquired_date) THEN
            RAISE_APPLICATION_ERROR(-20104, 'Produsul nu poate fi updatat. Exista order comandat mai devreme la data de ' || v_max_order_date);
        END IF;
        
        SELECT nvl(sum(quantity), 0) INTO v_total_quantity FROM pbd_orders WHERE product_id = v_product_id;
        IF (v_total_quantity > p_available_quantity) THEN
            RAISE_APPLICATION_ERROR(-20104, 'Produsul nu poate fi updatat. Cantitatea totala a order-urilor pe acest produs este ' || v_total_quantity);
        END IF;
        
        UPDATE pbd_products SET product_name = p_product_name, price = p_price, date_acquired = p_acquired_date, available_quantity = p_available_quantity, shop_id = p_shop_id, description = p_description 
        WHERE product_id = v_product_id;
    END;
END products_pack;
/

