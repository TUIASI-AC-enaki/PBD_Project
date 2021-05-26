CREATE OR REPLACE PACKAGE shipping_pack IS
    PROCEDURE insert_item(
        p_provider IN pbd_shipping_methods.provider%TYPE, 
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE
    );
    PROCEDURE delete_item(
        p_provider IN pbd_shipping_methods.provider%TYPE
    );
    PROCEDURE update_item(
        p_provider_old IN pbd_shipping_methods.provider%TYPE,
        p_provider IN pbd_shipping_methods.provider%TYPE,
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE
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
    BEGIN
        DELETE FROM pbd_shipping_methods WHERE provider = p_provider;
    END;
    
    PROCEDURE update_item(
        p_provider_old IN pbd_shipping_methods.provider%TYPE,
        p_provider IN pbd_shipping_methods.provider%TYPE,
        p_delivering_price IN pbd_shipping_methods.delivering_price%TYPE
    ) IS
    BEGIN
        UPDATE pbd_shipping_methods SET provider = p_provider, delivering_price = p_delivering_price WHERE provider = p_provider_old;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20222, 'Eroare generala.');
    END;
END shipping_pack;
/
