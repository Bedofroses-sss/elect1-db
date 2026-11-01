-- ============================================================
-- МИНИ-МАРКЕТ ЭЛЕКТРОНИКИ (ИСПРАВЛЕННЫЙ ФИНАЛ)
-- ============================================================

DROP DATABASE IF EXISTS electronics_market;
CREATE DATABASE electronics_market
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE electronics_market;

-- 1. КЛИЕНТЫ
CREATE TABLE Customers (
    C_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    C_FNAME VARCHAR(100) NOT NULL,
    C_NAME VARCHAR(100) NOT NULL,
    C_MNAME VARCHAR(100) NULL 
    C_PHONE VARCHAR(30) NOT NULL,
    C_EMAIL VARCHAR(254) NULL,
    PRIMARY KEY (C_ID),
    UNIQUE KEY uq_customers_phone (C_PHONE),
    CONSTRAINT chk_customers_email CHECK (C_EMAIL IS NULL OR C_EMAIL LIKE '%_@_%._%')
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- 2. КАТЕГОРИИ
CREATE TABLE Product_Categories (
    CAT_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    CAT_NAME VARCHAR(100) NOT NULL,
    PRIMARY KEY (CAT_ID),
    UNIQUE KEY uq_product_categories_name (CAT_NAME)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- 3. ТОВАРЫ
CREATE TABLE Products (
    P_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    P_NAME VARCHAR(200) NOT NULL,
    P_MANUFACTURER VARCHAR(100) NOT NULL,
    P_PRICE DECIMAL(10, 2) NOT NULL,
    P_STOCK INT UNSIGNED NOT NULL DEFAULT 0,
    CAT_ID INT UNSIGNED NOT NULL,
    PRIMARY KEY (P_ID),
    CONSTRAINT chk_products_price CHECK (P_PRICE > 0),
    CONSTRAINT fk_products_category FOREIGN KEY (CAT_ID) REFERENCES Product_Categories (CAT_ID)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- 4. ЗАКАЗЫ
CREATE TABLE Orders (
    O_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    C_ID INT UNSIGNED NOT NULL,
    O_DATE DATE NOT NULL,
    O_STATUS VARCHAR(20) NOT NULL DEFAULT 'Оформлен',
    O_ADDRESS VARCHAR(500) NULL,
    PRIMARY KEY (O_ID),
    CONSTRAINT chk_orders_status CHECK (O_STATUS IN ('Оформлен', 'Оплачен', 'Доставлен', 'Отменён')),
    CONSTRAINT fk_orders_customer FOREIGN KEY (C_ID) REFERENCES Customers (C_ID)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- 5. УСЛУГИ
CREATE TABLE Services (
    S_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    S_NAME VARCHAR(200) NOT NULL,
    S_PRICE DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (S_ID),
    UNIQUE KEY uq_services_name (S_NAME),
    CONSTRAINT chk_services_price CHECK (S_PRICE > 0)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- 6. ЗАКАЗ_ТОВАРЫ
CREATE TABLE Order_Items (
    O_ID INT UNSIGNED NOT NULL,
    P_ID INT UNSIGNED NOT NULL,
    OI_QUANTITY INT UNSIGNED NOT NULL,
    OI_PRICE DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (O_ID, P_ID),
    CONSTRAINT chk_order_items_quantity CHECK (OI_QUANTITY > 0),
    CONSTRAINT chk_order_items_price CHECK (OI_PRICE > 0),
    CONSTRAINT fk_order_items_order FOREIGN KEY (O_ID) REFERENCES Orders (O_ID),
    CONSTRAINT fk_order_items_product FOREIGN KEY (P_ID) REFERENCES Products (P_ID)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- 7. ЗАКАЗ_УСЛУГИ
CREATE TABLE Order_Services (
    O_ID INT UNSIGNED NOT NULL,
    S_ID INT UNSIGNED NOT NULL,
    OS_DATE DATE NOT NULL,
    OS_COUNT INT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (O_ID, S_ID),
    CONSTRAINT chk_order_services_count CHECK (OS_COUNT > 0),
    CONSTRAINT fk_order_services_order FOREIGN KEY (O_ID) REFERENCES Orders (O_ID),
    CONSTRAINT fk_order_services_service FOREIGN KEY (S_ID) REFERENCES Services (S_ID)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;


-- ============================================================
-- ЗАПОЛНЕНИЕ ДАННЫХ
-- ============================================================

-- 1. Клиент (Иванов И.И.) - СТРОГО 1 КЛИЕНТ
INSERT INTO Customers (C_FNAME, C_NAME, C_MNAME, C_PHONE, C_EMAIL) 
VALUES ('Иванов', 'Иван', 'Иванович', '+7-900-111-22-33', 'ivanov@mail.ru');

-- 2. Категории (3 штуки)
INSERT INTO Product_Categories (CAT_NAME) 
VALUES ('Телефоны'), ('Ноутбуки'), ('Планшеты');

-- 3. Товары (СТРОГО 3 ШТУКИ ИЗ ТАБЛИЦЫ)
INSERT INTO Products (P_NAME, P_MANUFACTURER, P_PRICE, P_STOCK, CAT_ID) 
VALUES 
('iPhone 18 pro', 'Apple', 100000.00, 10, 1),  -- Телефоны
('MacBook Pro', 'Apple', 150000.00, 5, 2),     -- Ноутбуки
('iPad mini', 'Apple', 50000.00, 8, 3);        -- Планшеты

-- 4. Заказ (Один заказ №1001 для Иванова)
INSERT INTO Orders (O_ID, C_ID, O_DATE, O_STATUS, O_ADDRESS) 
VALUES (1001, 1, '2026-05-20', 'Оформлен', 'г. Москва, ул. Пушкина, д. 1');

-- 5. Услуги (Оставляем 4 услуги, как ты хотел)
INSERT INTO Services (S_NAME, S_PRICE) 
VALUES 
('Доставка', 500.00),
('Настройка устройства', 1500.00),
('Установка защитного стекла', 700.00),
('Расширенная гарантия на 1 год', 3000.00);

-- 6. Привязка 3 товаров к заказу 1001
INSERT INTO Order_Items (O_ID, P_ID, OI_QUANTITY, OI_PRICE) 
VALUES 
(1001, 1, 1, 100000.00), -- iPhone 18 pro
(1001, 2, 1, 150000.00), -- MacBook Pro
(1001, 3, 1, 50000.00);  -- iPad mini

-- 7. Привязка ВСЕХ 4-х услуг к заказу 1001 (М:N)
INSERT INTO Order_Services (O_ID, S_ID, OS_DATE, OS_COUNT) 
VALUES 
(1001, 1, '2026-05-20', 1), -- Доставка
(1001, 2, '2026-05-20', 1), -- Настройка устройства
(1001, 3, '2026-05-20', 1), -- Установка защитного стекла
(1001, 4, '2026-05-20', 1); -- Расширенная гарантия
