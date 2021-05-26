import re
from datetime import date
from tkinter import ttk

import cx_Oracle
from GUI_Pages.BasicPage import BasicPage
import tkinter as tk
from tkinter import font as tkfont

from Utilities.TableFrame import TableFrame


class HomePage(BasicPage):
    def __init__(self, parent, controller):
        super().__init__(parent, controller)
        self.init()

    def get_product_tuples(self):
        query_select = self.controller.run_query("SELECT p.product_id, p.product_name, p.price, p.available_quantity quantity from pbd_products p order by p.product_name")
        return query_select

    def get_product_price(self, product_id):
        query_select = self.controller.run_query("SELECT price from pbd_products where product_id={}".format(product_id))
        return query_select

    def get_shipping_tuples(self):
        query_select = self.controller.run_query(
            "SELECT shipping_id, provider, delivering_price from pbd_shipping_methods order by provider")
        return query_select

    def init(self):
        self.button_home['bg'] = 'dark orange'
        bg_color = 'gold'
        btn_fg = 'white'
        width_label = 20
        width_entry = 20

        text_font = tkfont.Font(family='Helvetica', size=13)
        button_font = tkfont.Font(family='Helvetica', size=10)

        self.home_page_welcome_label_var = tk.StringVar()
        tk.Label(self, textvariable=self.home_page_welcome_label_var, font=self.title_font, bg=bg_color, fg='black').pack(side=tk.TOP, fill=tk.X)

        home_frame = tk.Frame(master=self, bg=bg_color)
        home_frame.pack(side=tk.TOP, fill=tk.BOTH, expand=True)
        home_frame.grid_rowconfigure(1, weight=1)
        home_frame.grid_columnconfigure(0, weight=1)
        home_frame.grid_columnconfigure(1, weight=1)

        #buy menu
        order_menu = tk.LabelFrame(home_frame, text="Buy", fg='blue', width=10, bg='light gray')
        order_menu.grid(row=0, column=0, columnspan=3, padx=5, pady=5)

        # Label + Combobox -> select product
        tk.Label(order_menu, text='Id/ Product/ Price/ Av Qty', font=text_font, bg=order_menu['bg'],
                 fg='red', width=width_label)\
            .grid(row=0, column=0, padx=5, pady=5)
        self.product_id_combo = ttk.Combobox(order_menu, state='readonly', width=width_entry*2,
                                             values=self.get_product_tuples())
        self.product_id_combo.grid(row=1, column=0, padx=5, pady=5)

        # Label + Combobox -> select quantity
        tk.Label(order_menu, text='Quantity', font=text_font, bg=order_menu['bg'], fg='red', width=width_label).grid(
            row=0, column=1, padx=5, pady=5)
        self.quantity_combo = ttk.Combobox(order_menu, width=width_entry, values=[x for x in range(1, 1000)])
        self.quantity_combo.grid(row=1, column=1, padx=5, pady=5)

        # Label + Combobox -> select shipping
        tk.Label(order_menu, text='Id/ Shipping/ Price', font=text_font, bg=order_menu['bg'], fg='red',
                 width=width_label)\
            .grid(row=0, column=2, padx=5, pady=5)
        self.ship_combo = ttk.Combobox(order_menu, width=width_entry*2, state='readonly',
                                       values=self.get_shipping_tuples())
        self.ship_combo.grid(row=1, column=2, padx=5, pady=5)

        # Label + Entry -> insert data
        tk.Label(order_menu, text='Purchase data', font=text_font, bg=order_menu['bg'], fg='red', width=width_label).grid(
            row=0, column=3, padx=5, pady=5)
        self.order_entry = ttk.Entry(order_menu, width=width_entry*2)
        self.order_entry.insert(0, 'YYYY-MM-DD')
        self.order_entry.grid(row=1, column=3, padx=5, pady=5)

        # Buy button
        tk.Button(order_menu, text="Buy", command=self.on_buy, width=10, bg='red', fg=btn_fg,
                  font=tkfont.Font(family='Helvetica', size=15))\
            .grid(row=2, column=0, columnspan=4, padx=5, pady=15)

        # Options row
        tk.Button(home_frame, text="Logout", command=self.on_logout, bg='red', fg=btn_fg, font=self.title_font)\
            .grid(row=2, column=0, padx=35, pady=15, sticky='w')
        tk.Button(home_frame, text="Refresh", command=self.on_refresh, bg='blue', fg=btn_fg, font=self.title_font)\
            .grid(row=2, column=1, padx=35, pady=15, sticky='w')
        self.advanced_options_button = tk.Button(home_frame, text="Advanced Options", command=self.on_advanced_opt,
                                                 bg='black', fg=btn_fg, font=self.title_font)
        self.advanced_options_button.grid(row=2, column=2, padx=35, pady=15, sticky='e')

        # Table
        columns_names = ['Order Id', 'Product Name', 'Price', 'Quantity',
                         'Shipping Provider', 'Provider Price', 'Total Amount', 'Date Ordered']
        self.table = TableFrame(home_frame, columns_names)
        self.table.grid(row=1, column=0, columnspan=3, sticky="nesw", padx=5, pady=5)
        self.populate_the_table_with_all_values()
        self.table.tree.bind('<<TreeviewSelect>>', self.on_select)

    def on_refresh(self):
        if not self.session_is_allright():
            return
        self.populate_the_table_with_all_values()

    def on_logout(self):
        from tkinter import messagebox
        if messagebox.askokcancel("Logout", "Are you sure you want to logout?"):
            self.controller.show_frame("LoginPage")

    @staticmethod
    def fields_are_empty(product_id, amount, shipping_id, purchase_date):
        from tkinter import messagebox
        if product_id == '':
            messagebox.showinfo("Buy Error", "Product id required")
            return True
        if amount == '':
            messagebox.showinfo("Buy Error", "Quantity required")
            return True
        if shipping_id == '':
            messagebox.showinfo("Buy Error", "Shipping id required")
            return True
        if purchase_date == '':
            messagebox.showinfo("Buy Error", "Purchase date required")
            return True
        return False

    def is_valid_date(self, purchase_date: str) -> bool:
        pattern = r'(19|20)\d\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])'
        match = re.search(pattern, purchase_date)
        return True if match else False

    def on_buy(self):
        if not self.session_is_allright():
            return
        from tkinter import messagebox

        # Extract data from inputs
        product_id = self.product_id_combo.get().split(' ')[0]
        amount = self.quantity_combo.get()
        shipping_id = self.ship_combo.get().split(' ')[0]
        purchase_date: str = self.order_entry.get()

        if self.fields_are_empty(product_id, amount, shipping_id, purchase_date):
            return
        if not amount.isdigit() or not self.is_number(amount, max_range=1_0000):
            messagebox.showinfo("Buy error", "Amount is not valid number")
            return
        if not self.is_valid_date(purchase_date):
            messagebox.showinfo("Buy error", "The purchase date is not valid.")
            return
        purchase_date = date(*map(int, purchase_date.split('-')))

        if not messagebox.askokcancel("Buy", "Are you sure you want to buy this item?"):
            return

        try:
            self.controller.run_procedure(
                'ORDERS_PACK.insert_item',
                [
                    self.controller.user_info['user_id'],
                    shipping_id,
                    product_id,
                    amount,
                    str(int(self.get_shipping_price(shipping_id)) +
                        int(amount)*int(self.get_product_price(product_id)[0][0])),
                    purchase_date
                ]
            )
        except cx_Oracle.DatabaseError as exc_db_err:
            from tkinter import messagebox
            messagebox.showinfo("Purchase error", "Can't purchase items.\n{}"
                                .format(exc_db_err.args[0].message.split("\n")[0]))
            return
        except KeyError:
            messagebox.showinfo("Account Error", "User invalid")
            self.controller.show_frame('LoginPage')
        self.populate_the_table_with_all_values()

    def get_shipping_price(self, shipping_id):
        query = "SELECT delivering_price from pbd_shipping_methods where shipping_id={}".format(shipping_id)
        return self.controller.run_query(query)[0][0]

    def on_select(self, event):
        pass

    def on_advanced_opt(self):
        # if not self.session_is_allright():
        #     return
        self.controller.show_frame("AdvancedAdminPage")

    def update_buy(self):
        self.product_id_combo['values'] = self.get_product_tuples()
        self.ship_combo['values'] = self.get_shipping_tuples()

    def populate_the_table_with_all_values(self):
        self.table.clear_table()
        if self.controller.user_info:
            query_select = self.controller.run_query(
                "SELECT o.order_id, p.product_name, p.price, o.quantity, ship.provider, ship.delivering_price, o.total_amount, o.date_ordered from pbd_orders o, pbd_products p, pbd_shipping_methods ship "
                "where o.product_id = p.product_id and o.shipping_id=ship.shipping_id and o.user_id={} order by p.product_name".format(self.controller.user_info['user_id']))
            for row in query_select:
                self.table.insert('', 'end', values=row)