import os

import cx_Oracle
from cx_Oracle import DatabaseError


def run_procedure(conn, procedure_name, params):
    cursor = conn.cursor()
    try:
        cursor.callproc(procedure_name, params)
        conn.commit()
        cursor.close()
        return True
    except cx_Oracle.InterfaceError:
        conn.commit()
        cursor.close()
        return False


cx_Oracle.init_oracle_client(lib_dir="D:\Programs\oracle\instantclient_19_8")
bd_config = {
    "username": os.environ.get("username_pbd_proiect"),
    "password": os.environ.get("password_pbd_proiect")
}

conn = cx_Oracle.connect(bd_config["username"], bd_config["password"], "bd-dc.cs.tuiasi.ro:1539/orcl")

# run_procedure(conn, 'SHOP_PKG.insert_shop', ['test', 'test', 'test', 'test'])

try:
    with conn.cursor() as cursor:
        objType = conn.gettype("AUTH_PKG.USER_ACCOUNT")
        output = cursor.var(objType)
        run_procedure(conn, 'auth_pkg.login', ['enaki', 't', output])
        print(output.get_value())
except DatabaseError as e:
    print(e)

try:
    with conn.cursor() as cursor:
        output = cursor.var(cx_Oracle.NUMBER)
        run_procedure(conn, 'auth_pkg.signup', ['test1', 'test12', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', output])
        print(output.get_value())
except DatabaseError as e:
    print(e)
