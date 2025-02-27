# Online_Shopping_DB

![SS](https://github.com/TUIASI-AC-enaki/PBD_Project/blob/master/Documentation/ss.png)

## 1. Introduction

This project mimics the functionality of a database in the field of online shopping 
through an API (application programming interface). 

The API in the current project gives the user the ability to navigate the table of 
products, stores and distributors.
 
For a start, the user is redirected to the 'login' page, where he can log in with the profile he has or create a new profile. There are 4 types of users in the application, depending on the type of account, each user has different roles and privileges:
- customer
- admin shop
- admin shipping
- global admin

An application using SQLPlus DB

### 1.1 User Roles
1. __Client__ - The user with the type of customer account benefits from the possibility to search in the table of stores, products and distributors having several search fields available according to need (name, price, price range, id, location, etc.).
2. __Admin Shop__ - In addition to the customer benefits, the store manager has the ability to insert, edit or delete records from the Shops table and the Products table.
3. __Admin Shipping__ - The user with the type of distributor administrator account has the advantages that the customer has, as well as the possibility to insert, modify and delete the records from the Shipping_Methods table.
4. __Global Admin__ - The user with the global admin account has the advantages that both admin_shop and admin_shipping have. In addition, it has its own page for viewing all users, with the necessary information (Name, surname, location, email, phone, username, password) stating that it will not be able to view the passwords of other users who have the type of global_admin account.

## 2. Technologies used for front-end and back-end

The database used in this application is SQLPlus. 

Python tkinter library was used for the front end.

The main frame called the container is in the `BdGui` class. 
This class has a dictionary with another 7 frames, which depending on the 
user can be invoked via the tkraise () function. 
The relationship between the classes `LoginPage`, `SignUpPage`, `AdvancedAdminPage`, 
`HomePage`, `ShopPage`, `ShippingPage`, `ProductPage` is the aggregation compared to the `BdGui` class.

To view the records, a TableFrame class has been created that contains an attribute of
 type `tkinter.TreeView`. The `AdvancedAdminPage`, `HomePage`, `ShopPage`, `ShippingPage`,
  `ProductPage` classes have the `TableFrame` class as an attribute creating a 
  composition relationship. The `tkinter.Entry`, `tkinter.Combobox` and `tkinter.CheckBox`
   widgets within the tkinter library were used to enter the data.


#### Class Diagram for GUI Pages
![App Pages Diagram](https://github.com/TUIASI-AC-enaki/PBD_Project/blob/master/Documentation/app_pages.png)

#### Class Diagram of the Application without BdGui class
![Class Diagram](https://github.com/TUIASI-AC-enaki/PBD_Project/blob/master/Documentation/class_diagram.png)

## 3. Password encryption and decryption

Encrypt and decrypt methods in the `Cipher` class are used to encrypt and decrypt the 
password, which uses the `Fernet` class in the cryptography library. 
Password encryption and decryption is required when the database is not running locally,
 in this case the given operations are done for academic purposes when logging in and 
 creating an account, before executing the sql instructions. 
 Encryption and decryption is done using a key, in this case the key being: 
 _“my deep darkest secret is secure”_ encrypted in a string of bytes using the 
 base64 library (`Fernet` class only accept keys "32 url-safe base64-encoded bytes" ).
The password is maintained in the database in the form of a hash generated by the md5 
cryptographic function using the hashlib library.

## 4. ER-Diagram

![ER Diagram](https://github.com/TUIASI-AC-enaki/PBD_Project/blob/master/Documentation/er_diagram_1.png)


![ER Diagram](https://github.com/TUIASI-AC-enaki/PBD_Project/blob/master/Documentation/er_diagram_3.png)


## 5. How to start the project

Required for this app:

1) cx_oracle library - `pip install cx_Oracle`
2) cryptography library - `pip install cryptography`
3) [Oracle XE DB](https://www.oracle.com/database/technologies/xe-downloads.html)


Start the application:

- Create a database and run the scripts create_table.sql and insert_into_tables.sql
- Change `username`, `password` of the database and the `oracle client location`  from `bd_gui.py` .
- Run the application main.py
