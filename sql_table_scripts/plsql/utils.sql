SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE utils_pkg IS
    PROCEDURE print_product_status(v_product_id pbd_products.product_id%TYPE);
    PROCEDURE print_shop_status(v_shop_id pbd_shops.shop_id%TYPE);
END;
/

CREATE OR REPLACE PACKAGE BODY utils_pkg IS
    PROCEDURE print_shop_status(v_shop_id pbd_shops.shop_id%TYPE)
    IS
        CURSOR v_shop_cursor IS SELECT * FROM pbd_shops WHERE shop_id = v_shop_id;
    BEGIN
        FOR v_shop IN v_shop_cursor LOOP
            DBMS_OUTPUT.PUT_LINE('Shop Id = ' || v_shop.shop_id || ', Shop Name = ' || v_shop.shop_name || ', Stonks = ' || v_shop.stocks);
        END LOOP;
    END;
    
    PROCEDURE print_product_status(v_product_id pbd_products.product_id%TYPE)
    IS
        CURSOR v_product_cursor(v_product_id pbd_products.product_id%TYPE) IS SELECT * FROM pbd_products WHERE product_id = v_product_id;
    BEGIN
        FOR v_product IN v_product_cursor(v_product_id) LOOP
            DBMS_OUTPUT.PUT_LINE('Product Id = ' || v_product.product_id || ', Product Name = ' || v_product.product_name || ', Product Price = ' || v_product.price || ', Product Acquired On = ' || v_product.date_acquired || ', Shop Id = ' || v_product.shop_id || ', Available Quantity= ' || v_product.available_quantity);
            print_shop_status(v_product.shop_id);
        END LOOP;
    END;
END;
/