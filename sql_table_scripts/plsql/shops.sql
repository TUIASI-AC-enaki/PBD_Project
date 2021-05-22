CREATE OR REPLACE PACKAGE LOCATION_PKG IS
    FUNCTION get_location_id(v_street pbd_locations.street_address%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE) RETURN pbd_locations.location_id%TYPE;
    PROCEDURE insert_location(v_street pbd_locations.street_address%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE);
END LOCATION_PKG;
/

CREATE OR REPLACE PACKAGE SHOP_PKG IS
    PROCEDURE delete_shop(v_street pbd_locations.street_address%TYPE, v_shop_name pbd_shops.shop_name%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE); 
    PROCEDURE insert_shop(v_street pbd_locations.street_address%TYPE, v_shop_name pbd_shops.shop_name%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE);
    PROCEDURE update_shop(v_street pbd_locations.street_address%TYPE, v_shop_name pbd_shops.shop_name%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE,
        v_street_to_be_updated pbd_locations.street_address%TYPE, v_shop_name_to_be_updated pbd_shops.shop_name%TYPE, v_city_to_be_updated pbd_locations.city%TYPE, v_country_to_be_updated pbd_locations.country%TYPE);
END SHOP_PKG;
/

CREATE OR REPLACE PACKAGE BODY LOCATION_PKG IS
    FUNCTION get_location_id(v_street pbd_locations.street_address%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE) 
    RETURN pbd_locations.location_id%TYPE
    IS
        v_location_id pbd_locations.location_id%TYPE;
    BEGIN
        SELECT location_id into v_location_id from pbd_locations where lower(street_address)=lower(v_street) and lower(city)=lower(v_city) and lower(country)=lower(v_country);
        return v_location_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
    END;
    
    
    PROCEDURE insert_location(v_street pbd_locations.street_address%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE)
    IS
    BEGIN
        INSERT INTO pbd_locations (street_address, city, country) VALUES (v_street, v_city, v_country);
    END;
END LOCATION_PKG;
/

CREATE OR REPLACE PACKAGE BODY SHOP_PKG IS
    PROCEDURE delete_shop(v_street pbd_locations.street_address%TYPE, v_shop_name pbd_shops.shop_name%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE)
    IS
        v_shop_id pbd_shops.shop_id%TYPE;
        v_location_id pbd_locations.location_id%TYPE;
    BEGIN
        SELECT shop_id into v_shop_id from pbd_shops s, pbd_locations l where s.location_id = l.location_id and s.shop_name = v_shop_name and l.street_address=v_street and l.city=v_city and l.country=v_country;
        DELETE FROM pbd_products WHERE shop_id = v_shop_id;
        
        v_location_id :=  LOCATION_PKG.get_location_id(v_street, v_city, v_country);
        DELETE FROM pbd_shops WHERE shop_id=v_shop_id;
    END;
    
    PROCEDURE insert_shop(v_street pbd_locations.street_address%TYPE, v_shop_name pbd_shops.shop_name%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE)
    IS
        v_location_id pbd_locations.location_id%TYPE;
    BEGIN
        v_location_id :=  LOCATION_PKG.get_location_id(v_street, v_city, v_country);
        IF (v_location_id = -1) THEN
            LOCATION_PKG.insert_location(v_street, v_city, v_country);
            v_location_id :=  LOCATION_PKG.get_location_id(v_street, v_city, v_country);
        END IF;
        
        INSERT INTO pbd_shops (shop_name, location_id) VALUES (v_shop_name, v_location_id);
    END;
    
    PROCEDURE update_shop(v_street pbd_locations.street_address%TYPE, v_shop_name pbd_shops.shop_name%TYPE, v_city pbd_locations.city%TYPE, v_country pbd_locations.country%TYPE,
        v_street_to_be_updated pbd_locations.street_address%TYPE, v_shop_name_to_be_updated pbd_shops.shop_name%TYPE, v_city_to_be_updated pbd_locations.city%TYPE, v_country_to_be_updated pbd_locations.country%TYPE
    )
    IS
        v_location_id pbd_locations.location_id%TYPE;
        v_location_id_to_be_updated pbd_locations.location_id%TYPE;
    BEGIN
        v_location_id :=  LOCATION_PKG.get_location_id(v_street, v_city, v_country);
        IF (v_location_id = -1) THEN
            LOCATION_PKG.insert_location(v_street, v_city, v_country);
            v_location_id :=  LOCATION_PKG.get_location_id(v_street, v_city, v_country);
        END IF;
        
        v_location_id_to_be_updated :=  LOCATION_PKG.get_location_id(v_street_to_be_updated, v_city_to_be_updated, v_country_to_be_updated);
        UPDATE pbd_shops SET shop_name = v_shop_name, location_id=v_location_id WHERE shop_name=v_shop_name_to_be_updated AND location_id=v_location_id_to_be_updated;
    END;
END SHOP_PKG;
/


--EXECUTE SHOP_PKG.insert_shop('test', 'test', 'test', 'test');
ROLLBACK;
