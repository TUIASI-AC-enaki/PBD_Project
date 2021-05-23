

CREATE OR REPLACE PACKAGE AUTH_PKG IS   
    TYPE user_account IS RECORD (
        user_id pbd_app_users.user_id%TYPE, 
        first_name pbd_app_users.first_name%TYPE, 
        last_name pbd_app_users.last_name%TYPE, 
        location_id pbd_app_users.location_id%TYPE, 
        email pbd_app_users.email%TYPE, 
        phone pbd_app_users.phone%TYPE, 
        user_level pbd_accounts.account_type%TYPE
    );
    
    PROCEDURE LOGIN(v_username pbd_accounts.username%TYPE, v_password pbd_accounts.password%TYPE, v_user_account OUT user_account);
    PROCEDURE SIGNUP(v_username pbd_accounts.username%TYPE, 
        v_password pbd_accounts.password%TYPE, 
        v_user_level pbd_accounts.account_type%TYPE,
        v_street pbd_locations.street_address%TYPE, 
        v_city pbd_locations.city%TYPE, 
        v_country pbd_locations.country%TYPE,
        v_first_name pbd_app_users.first_name%TYPE, 
        v_last_name pbd_app_users.last_name%TYPE, 
        v_email pbd_app_users.email%TYPE, 
        v_phone pbd_app_users.phone%TYPE,
        v_user_id OUT pbd_app_users.user_id%TYPE
        );
END AUTH_PKG;
/

CREATE OR REPLACE PACKAGE BODY AUTH_PKG IS   
    
    
    PROCEDURE LOGIN(v_username pbd_accounts.username%TYPE, v_password pbd_accounts.password%TYPE, v_user_account OUT user_account)
    IS
    BEGIN
        SELECT u.user_id, u.first_name, u.last_name, u.location_id, u.email, u.phone, a.account_type as user_level into v_user_account from pbd_app_users u, pbd_accounts a where u.user_id = a.user_id and a.username=v_username and a.password=v_password;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20100, 'No User Found');
    END;
    
    PROCEDURE SIGNUP(v_username pbd_accounts.username%TYPE, 
        v_password pbd_accounts.password%TYPE, 
        v_user_level pbd_accounts.account_type%TYPE,
        v_street pbd_locations.street_address%TYPE, 
        v_city pbd_locations.city%TYPE, 
        v_country pbd_locations.country%TYPE,
        v_first_name pbd_app_users.first_name%TYPE, 
        v_last_name pbd_app_users.last_name%TYPE, 
        v_email pbd_app_users.email%TYPE, 
        v_phone pbd_app_users.phone%TYPE,
        v_user_id OUT pbd_app_users.user_id%TYPE
        ) 
    IS
        v_location_id pbd_locations.location_id%TYPE;
    BEGIN
        v_location_id :=  LOCATION_PKG.get_location_id_with_upsert(v_street, v_city, v_country);
        INSERT INTO pbd_app_users (first_name, last_name, location_id, email, phone) VALUES (v_first_name, v_last_name, v_location_id, v_email, v_phone);
        
        SELECT u.user_id INTO v_user_id from pbd_app_users u where email=v_email;
        INSERT INTO pbd_accounts (user_id, username, password, account_type) VALUES (v_user_id, v_username, v_password, v_user_level);
    END;
END AUTH_PKG;
/

SET SERVEROUTPUT ON;
DECLARE
    test1 auth_pkg.user_account;
    v_user_id pbd_app_users.user_id%TYPE;
BEGIN
    --auth_pkg.login('test', 'test', test1);
    auth_pkg.signup('test1', 'test12', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', v_user_id);
    DBMS_OUTPUT.PUT_LINE(v_user_id);
    rollback;
END;
/
