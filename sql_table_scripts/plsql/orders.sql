CREATE OR REPLACE PACKAGE orders_pack IS
    PROCEDURE insert_item(
        p_user_id IN pbd_app_users.user_id%TYPE,
        p_shipping_id IN pbd_shipping_methods.shipping_id%TYPE,
        p_product_id IN pbd_products.product_id%TYPE,
        p_quantity IN pbd_orders.quantity%TYPE,
        p_total_amount IN pbd_orders.total_amount%TYPE,
        p_date_ordered IN pbd_orders.date_ordered%TYPE DEFAULT SYSDATE
    );
END orders_pack;
/

CREATE OR REPLACE PACKAGE BODY orders_pack IS
    PROCEDURE insert_item(
        p_user_id IN pbd_app_users.user_id%TYPE,
        p_shipping_id IN pbd_shipping_methods.shipping_id%TYPE,
        p_product_id IN pbd_products.product_id%TYPE,
        p_quantity IN pbd_orders.quantity%TYPE,
        p_total_amount IN pbd_orders.total_amount%TYPE,
        p_date_ordered IN pbd_orders.date_ordered%TYPE DEFAULT SYSDATE
    ) IS
    BEGIN
        INSERT INTO pbd_orders(user_id, shipping_id, product_id, quantity, total_amount, date_ordered) VALUES(p_user_id, p_shipping_id, p_product_id, p_quantity, p_total_amount, p_date_ordered);
    END;
END orders_pack;
