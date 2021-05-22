import os

import cx_Oracle


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
run_procedure(conn, 'SHOP_PKG.insert_shop', ['test', 'test', 'test', 'test'])