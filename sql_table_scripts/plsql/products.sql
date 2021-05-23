CREATE OR REPLACE PACKAGE products_pack IS
    PROCEDURE insert_item(
        p_product_name IN pbd_products.product_name%TYPE, 
        p_price IN pbd_products.price%TYPE,
        p_available_quantity pbd_products.available_quantity%TYPE,
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
        p_available_quantity pbd_products.available_quantity%TYPE,
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE
    ) IS
    BEGIN
        INSERT INTO pbd_products VALUES(1, p_product_name, p_price, p_available_quantity, p_shop_id, p_description);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20222, 'Eroare generala.');
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
        p_shop_id IN pbd_products.shop_id%TYPE,
        p_description IN pbd_products.description%TYPE,
        p_product_name_old IN pbd_products.product_name%TYPE,
        p_price_old IN pbd_products.price%TYPE,
        p_shop_id_old IN pbd_products.shop_id%TYPE
    ) IS
    BEGIN

        UPDATE pbd_products SET product_name = p_product_name, price = p_price, shop_id = p_shop_id, description = p_description 
        WHERE product_name = p_product_name_old AND price = p_price_old AND shop_id = p_shop_id_old;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20222, 'Eroare generala.');
    END;
END products_pack;
/
CREATE OR REPLACE TRIGGER trg_delete_prod
BEFORE DELETE ON pbd_products
FOR EACH ROW
DECLARE
    v_product_id pbd_products.product_id%TYPE;
    v_temp NUMBER := 0;
BEGIN
    SELECT count(*) into v_temp FROM pbd_orders WHERE product_id = :old.product_id;
    
    IF v_temp > 0 THEN
        RAISE_APPLICATION_ERROR(-20200, 'Inregistrarea nu poate fi stearsa. Exista dependente externe.');
    END IF;
END;
