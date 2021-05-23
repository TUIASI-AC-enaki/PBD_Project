import tkinter as tk
from tkinter import font as tkfont, ttk

import logging as log
import sys

from cx_Oracle import DatabaseError

from GUI_Pages.BasicPage import TitlePage
from Utilities.Cipher import Cipher, get_hash

FORMAT = '[%(asctime)s] [%(levelname)s] : %(message)s'
log.basicConfig(stream=sys.stdout, level=log.DEBUG, format=FORMAT)


class LoginPage(TitlePage):
    def __init__(self, parent, controller):
        super().__init__(parent, controller)
        self.init()

    def init(self):
        width_label = 10
        width_entry = 25

        text_font = tkfont.Font(family='Helvetica', size=13)
        button_font = tkfont.Font(family='Helvetica', size=10)

        login_frame = tk.Frame(master=self, bg='gold')
        login_frame.pack(side=tk.TOP, fill=tk.BOTH, expand=True)
        login_frame.grid_rowconfigure(0, weight=1)
        login_frame.grid_columnconfigure(0, weight=1)

        login_label_frame = tk.LabelFrame(login_frame, bg='gray80')
        login_label_frame.grid(row=0, column=0)

        tk.Label(login_label_frame, text='username', font=text_font, bg=login_label_frame['bg'], fg='red',
                 width=width_label).grid(row=0, column=0, padx=5, pady=10)
        self.username_entry = tk.Entry(login_label_frame, width=width_entry)
        self.username_entry.grid(row=0, column=1,)

        tk.Label(login_label_frame, text='password', font=text_font, bg=login_label_frame['bg'], fg='red',
                 width=width_label).grid(row=1, column=0, padx=5, pady=10)
        self.password_entry = tk.Entry(login_label_frame, show="*", width=width_entry)
        self.password_entry.grid(row=1, column=1, padx=5, pady=10)

        self.login_button = tk.Button(login_label_frame, text='Login', font=button_font, command=self.on_login, bg='green', fg='white')
        self.login_button.grid(row=2, column=1, padx=5, pady=5)

        self.sign_up_button = tk.Button(login_label_frame, text='Sign Up', font=button_font, command=self.on_sign_up, bg='blue', fg='white')
        self.sign_up_button.grid(row=2, column=0, padx=5, pady=5)

    def set_states(self, user_level):
        if user_level == 'admin':
            return
        else:
            self.controller.set_state(self.controller.frames['HomePage'].advanced_options_button)
            self.controller.set_state(self.controller.frames['ShopPage'].insert_frame)
            self.controller.set_state(self.controller.frames['ShopPage'].update_frame)
            self.controller.set_state(self.controller.frames['ShopPage'].delete_frame)
            self.controller.set_state(self.controller.frames['ProductPage'].insert_frame)
            self.controller.set_state(self.controller.frames['ProductPage'].update_frame)
            self.controller.set_state(self.controller.frames['ProductPage'].delete_frame)
            self.controller.set_state(self.controller.frames['ShippingPage'].insert_frame)
            self.controller.set_state(self.controller.frames['ShippingPage'].update_frame)
            self.controller.set_state(self.controller.frames['ShippingPage'].delete_frame)
            if user_level == 'admin_shop':
                self.controller.set_state(self.controller.frames['ShopPage'].insert_frame, 'normal')
                self.controller.set_state(self.controller.frames['ShopPage'].update_frame, 'normal')
                self.controller.set_state(self.controller.frames['ShopPage'].delete_frame, 'normal')
                self.controller.set_state(self.controller.frames['ProductPage'].insert_frame, 'normal')
                self.controller.set_state(self.controller.frames['ProductPage'].update_frame, 'normal')
                self.controller.set_state(self.controller.frames['ProductPage'].delete_frame, 'normal')
            if user_level == 'admin_ship':
                self.controller.set_state(self.controller.frames['ShippingPage'].insert_frame, 'normal')
                self.controller.set_state(self.controller.frames['ShippingPage'].update_frame, 'normal')
                self.controller.set_state(self.controller.frames['ShippingPage'].delete_frame, 'normal')

    def on_login(self):
        username = self.username_entry.get()
        password = self.password_entry.get()

        #-------Use encryption when sending data across internet
        pass_encrypted = Cipher.encrypt(password)
        log.info("Password encrypted: {}".format(pass_encrypted.decode()))
        password = Cipher.decrypt(pass_encrypted)
        log.info("Password decrypted: {}".format(password))
        #end encryption and decryption part

        # --------Get hash of password
        password = get_hash(password)
        log.info("Password Hash: {}".format(password))

        try:
            user_account_var = self.controller.get_complex_type_var('AUTH_PKG.USER_ACCOUNT')
            self.controller.run_procedure('auth_pkg.login', [username, password, user_account_var])
        except DatabaseError as e:
            log.info("Login Failed Incorect username as password")
            if e.args[0].code == 20100:
                from tkinter import messagebox
                messagebox.showinfo("Login Failed", "Wrong username or password")
            return
        user_info = self.controller.get_dict_from_oracle_object(user_account_var)

        self.controller.user_info = user_info
        self.controller.re_create_frames()
        self.set_states(user_info['user_level'])

        self.controller.frames["HomePage"].home_page_welcome_label_var.set("Welcome {}".format(user_info['first_name']))
        self.controller.frames["HomePage"].populate_the_table_with_all_values()
        self.controller.show_frame("HomePage")

    def on_sign_up(self):
        self.controller.show_frame("SignUpPage")