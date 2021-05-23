CREATE OR REPLACE PACKAGE products_pack IS
    PROCEDURE insert_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE DEFAULT NULL
    );
    PROCEDURE delete_item(
        p_id IN pbd_products.product_id%TYPE
    );
    PROCEDURE update_item(
        p_id IN pbd_products.product_id%TYPE,
        p_product_name IN pbd_products.product_name%TYPE,
        p_price IN pbd_products.price%TYPE DEFAULT NULL,
        p_shop_id IN pbd_products.shop_id%TYPE DEFAULT NULL,
        p_description IN pbd_products.description%TYPE DEFAULT NULL
    );
END products_pack;
/
CREATE OR REPLACE PACKAGE BODY products_pack IS
    PROCEDURE insert_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO pbd_products VALUES(1, p_product_name, p_price, p_shop_id, p_description);
    END;
    
    PROCEDURE delete_item(
        p_id IN pbd_products.product_id%TYPE
    ) IS
        e_no_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_parameter, -2290);
    BEGIN
        IF p_id IS NULL THEN
            RAISE e_no_parameter;
        ELSE
            DELETE FROM pbd_products WHERE product_id = p_id;
        END IF;
    EXCEPTION
        WHEN e_no_parameter THEN
            RAISE_APPLICATION_ERROR(-20100, 'Nu a fost oferit nici un parametru functiei de delete.');
    END;
    
    PROCEDURE update_item(
        p_id IN pbd_products.product_id%TYPE,
        p_product_name IN pbd_products.product_name%TYPE DEFAULT NULL,
        p_price IN pbd_products.price%TYPE DEFAULT NULL,
        p_shop_id IN pbd_products.shop_id%TYPE DEFAULT NULL,
        p_description IN pbd_products.description%TYPE DEFAULT NULL
    ) IS
        e_no_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_parameter, -2294);
    BEGIN
        IF p_price IS NULL AND p_shop_id IS NULL AND p_description IS NULL AND p_product_name IS NULL THEN
            RAISE e_no_parameter;
        END IF;
        
        IF p_price IS NOT NULL THEN
            UPDATE pbd_products SET price = p_price WHERE product_id = p_id;
        END IF;
        
        IF p_shop_id IS NOT NULL THEN
            UPDATE pbd_products SET shop_id = p_shop_id WHERE product_id = p_id;
        END IF;
        
        UPDATE pbd_products SET description = p_description WHERE product_id = p_id;
        
        EXCEPTION
            WHEN e_no_parameter THEN
                RAISE_APPLICATION_ERROR(-20100, 'Nu a fost oferit nici un parametru functiei de update.');
    END;
END products_pack;
