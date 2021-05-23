CREATE OR REPLACE PACKAGE orders_pack IS
    PROCEDURE insert_item(
        p_user_id IN pbd_app_users.user_id%TYPE,
        p_shipping_id IN pbd_shipping_methods.shipping_id%TYPE,
        p_product_id IN pbd_products.product_id%TYPE,
        p_quantity IN pbd_orders.quantity%TYPE,
        p_total_amount IN pbd_orders.total_amount%TYPE
    );
    PROCEDURE delete_item(
        p_id IN pbd_orders.order_id%TYPE
    );
END orders_pack;
/
CREATE OR REPLACE PACKAGE BODY orders_pack IS
    PROCEDURE insert_item(
        p_user_id IN pbd_app_users.user_id%TYPE,
        p_shipping_id IN pbd_shipping_methods.shipping_id%TYPE,
        p_product_id IN pbd_products.product_id%TYPE,
        p_quantity IN pbd_orders.quantity%TYPE,
        p_total_amount IN pbd_orders.total_amount%TYPE
    ) IS
    BEGIN
        INSERT INTO pbd_orders(order_id, user_id, shipping_id, product_id, quantity, total_amount) VALUES(1, p_user_id, p_shipping_id, p_product_id, p_quantity, p_total_amount);
    END;
    
    PROCEDURE delete_item(
        p_id IN pbd_orders.order_id%TYPE
    ) IS
        e_no_parameter EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_no_parameter, -2292);
    BEGIN
        IF p_id IS NOT NULL THEN
            DELETE FROM pbd_orders WHERE order_id = p_id;
        ELSE
            RAISE e_no_parameter;
        END IF;
    EXCEPTION
        WHEN e_no_parameter THEN
            RAISE_APPLICATION_ERROR(-20100, 'Nu a fost oferit nici un parametru functiei de delete.');
    END;
END orders_pack;
