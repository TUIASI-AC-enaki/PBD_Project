CREATE OR REPLACE PACKAGE shipping_pack IS
    PROCEDURE insert_item(
        p_provider IN pbd_shipping_methods.provider%TYPE, 
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE
    );
    PROCEDURE delete_item(
        p_provider IN pbd_shipping_methods.provider%TYPE
    );
    PROCEDURE update_item(
        p_id IN pbd_shipping_methods.shipping_id%TYPE,
        p_provider IN pbd_shipping_methods.provider%TYPE DEFAULT NULL,
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE DEFAULT NULL
    );
END shipping_pack;
/
CREATE OR REPLACE PACKAGE BODY shipping_pack IS
    PROCEDURE insert_item(
        p_provider IN pbd_shipping_methods.provider%TYPE, 
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE
    ) IS
    BEGIN
        INSERT INTO pbd_shipping_methods VALUES(1, p_provider, p_delivering_price);
    END;
    
    PROCEDURE delete_item(
        p_provider IN pbd_shipping_methods.provider%TYPE
    ) IS
        e_no_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_parameter, -2292);
    BEGIN
        IF p_provider IS NOT NULL THEN
            DELETE FROM pbd_shipping_methods WHERE provider = p_provider;
        ELSE
            RAISE e_no_parameter;
        END IF;
    EXCEPTION
        WHEN e_no_parameter THEN
            RAISE_APPLICATION_ERROR(-20100, 'Nu a fost oferit nici un parametru functiei de delete.');
    END;
    
    PROCEDURE update_item(
        p_id IN pbd_shipping_methods.shipping_id%TYPE,
        p_provider IN pbd_shipping_methods.provider%TYPE DEFAULT NULL,
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE DEFAULT NULL
    ) IS
        e_no_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_parameter, -2294);
    BEGIN
        IF p_provider IS NULL AND p_delivering_price IS NULL THEN
            RAISE e_no_parameter;
        END IF;
        
        IF p_provider IS NOT NULL THEN
            UPDATE pbd_shipping_methods SET provider = p_provider WHERE shipping_id = p_id;
        END IF;
        
        IF p_delivering_price IS NOT NULL THEN
            UPDATE pbd_shipping_methods SET delivering_price = p_delivering_price WHERE shipping_id = p_id;
        END IF;
        
        EXCEPTION
            WHEN e_no_parameter THEN
                RAISE_APPLICATION_ERROR(-20100, 'Nu a fost oferit nici un parametru functiei de update.');
    END;
END shipping_pack;
