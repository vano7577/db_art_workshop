
CREATE TABLE IF NOT EXISTS providers (
    provider_id serial primary key,
    provider_name varchar(255) NOT NULL UNIQUE,
    contact_phone_num char(12) NOT NULL
    CONSTRAINT ch_tel_num CHECK ( char_length(contact_phone_num) =12 )
);
CREATE TABLE IF NOT EXISTS canvases_providers (
    canvas_provider_id serial primary key,
    provider_id int NOT NULL ,
    canvas_id int NOT NULL ,
    quantity int NOT NULL ,
    canvas_provider_date date NOT NULL,
    CONSTRAINT ch_date CHECK ( canvas_provider_date > '1900-01-01' ),
    CONSTRAINT ch_positive CHECK ( quantity>0 )
);
CREATE TABLE IF NOT EXISTS canvases (
    canvas_id serial primary key ,
    canvas_name varchar(255) NOT NULL ,
    width int NOT NULL ,
    height int NOT NULL ,
    canvas_type_id int NOT NULL
    CONSTRAINT ch_positive CHECK ( width>0 AND height>0)
);
CREATE TABLE IF NOT EXISTS canvas_types (
    canvas_type_id serial primary key ,
    canvas_type_name varchar(255) NOT NULL UNIQUE ,
    material_of_manufacture varchar(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS paints_providers (
    paint_provider_id serial primary key ,
    provider_id int NOT NULL ,
    paint_id int NOT NULL ,
    quantity int NOT NULL ,
    paint_provider_date date NOT NULL ,
    CONSTRAINT ch_date CHECK ( paint_provider_date > '1900-01-01' ),
    CONSTRAINT ch_positive CHECK ( quantity>0 )
);
CREATE TABLE IF NOT EXISTS genres_paintings (
    genre_painting_id serial primary key ,
    genre_id int NOT NULL ,
    painting_id int NOT NULL
);
CREATE TABLE IF NOT EXISTS paintings (
    painting_id serial primary key ,
    canvas_id int NOT NULL ,
    painting_name varchar(255) NOT NULL UNIQUE ,
    is_reproduction boolean NOT NULL
);
CREATE TABLE IF NOT EXISTS painting_paints (
    painting_paint_id serial primary key ,
    painting_id int NOT NULL ,
    paint_id int NOT NULL ,
    quantity int NOT NULL,
    CONSTRAINT ch_positive CHECK ( quantity>0 )
);
CREATE TABLE IF NOT EXISTS paints(
    paint_id serial primary key ,
    paint_name varchar(255) NOT NULL UNIQUE ,
    paint_color varchar(255) NOT NULL ,
    paint_type_id int NOT NULL
);
CREATE TABLE IF NOT EXISTS paints_types (
    paint_type_id serial primary key ,
    paint_type_name varchar(255) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS genres (
    genre_id serial primary key ,
    genre_name varchar(255) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS genres_painters (
    genre_painter_id serial primary key ,
    genre_id int NOT NULL ,
    painter_id int NOT NULL
);
CREATE TABLE IF NOT EXISTS painters (
    painter_id serial primary key ,
    painter_first_name varchar(255) NOT NULL ,
    painter_last_name varchar(255) NOT NULL ,
    painter_middle_name varchar(255) ,
    gender boolean NOT NULL ,
    birthday date NOT NULL ,
    experience date NOT NULL,
    CONSTRAINT ch_date CHECK ( birthday > '1900-01-01' AND experience>'1900-01-01' )
);
CREATE TABLE IF NOT EXISTS orders (
    order_id serial primary key ,
    painter_id int NOT NULL ,
    client_order_id int NOT NULL ,
    painting_id int NOT NULL ,
    deadline date NOT NULL ,
    price numeric(8,2) NOT NULL,
    CONSTRAINT ch_date CHECK ( deadline > '1900-01-01' ),
    CONSTRAINT ch_not_negative CHECK ( price>=0 )
);
CREATE TABLE IF NOT EXISTS accounts (
    account_id serial primary key ,
    login varchar(60) NOT NULL UNIQUE ,
    email varchar(255) NOT NULL ,
    password varchar(60) NOT NULL,
    CONSTRAINT ch_email CHECK ( email ~ '^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$')
);
CREATE TABLE IF NOT EXISTS clients(
    client_id serial primary key ,
    account_id int,
    client_first_name varchar(255) NOT NULL ,
    client_last_name varchar(255) NOT NULL ,
    client_middle_name varchar(255) ,
    gender boolean NOT NULL ,
    birthday date NOT NULL,
    CONSTRAINT ch_date CHECK ( birthday > '1900-01-01' )
);
CREATE TABLE IF NOT EXISTS client_orders (
    client_order_id serial primary key ,
    order_num int NOT NULL UNIQUE ,
    client_id int NOT NULL ,
    discount_id int ,
    price numeric(8,2) NOT NULL DEFAULT 0,
    CONSTRAINT ch_positive CHECK ( order_num>0 ),
    CONSTRAINT ch_not_negative CHECK ( price>=0 )
);
CREATE TABLE IF NOT EXISTS discounts(
    discount_id serial primary key ,
    discount_name varchar(255) NOT NULL UNIQUE ,
    percent numeric(5,2) NOT NULL,
    CONSTRAINT ch_percent CHECK ( percent BETWEEN 0 AND 100)
);

ALTER TABLE canvases_providers
    ADD CONSTRAINT fk_canvases_providers$provider_id
        FOREIGN KEY (provider_id)
            REFERENCES providers (provider_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_canvases_providers$canvas_id
        FOREIGN KEY (canvas_id)
            REFERENCES canvases (canvas_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE paints_providers
    ADD CONSTRAINT fk_paints_providers$provider_id
        FOREIGN KEY (provider_id)
            REFERENCES providers (provider_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_paints_providers$paint_id
        FOREIGN KEY (paint_id)
            REFERENCES paints (paint_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE canvases
    ADD CONSTRAINT  fk_canvases$canvas_type_id
        FOREIGN KEY (canvas_type_id)
            REFERENCES canvas_types (canvas_type_id)  ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE genres_paintings
    ADD CONSTRAINT fk_genres_paintings$genre_id
        FOREIGN KEY (genre_id)
            REFERENCES genres(genre_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_genres_paintings$painting_id
        FOREIGN KEY (painting_id)
            REFERENCES paintings(painting_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE paintings
    ADD CONSTRAINT fk_paintings$canvas_id
        FOREIGN KEY (canvas_id)
            REFERENCES canvases(canvas_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE painting_paints
    ADD CONSTRAINT fk_painting_paints$painting_id
        FOREIGN KEY (painting_id)
            REFERENCES paintings (painting_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_painting_paints$paint_id
        FOREIGN KEY (paint_id)
            REFERENCES paints (paint_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE paints
    ADD CONSTRAINT fk_paints$paint_type_id
        FOREIGN KEY (paint_type_id)
            REFERENCES paints_types (paint_type_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE genres_painters
    ADD CONSTRAINT fk_genres_painters$genre_id
        FOREIGN KEY (genre_id)
            REFERENCES genres (genre_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_genres_painters$painter_id
        FOREIGN KEY (painter_id)
            REFERENCES painters (painter_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE orders
    ADD CONSTRAINT fk_orders$painter_id
        FOREIGN KEY (painter_id)
            REFERENCES painters (painter_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_orders$client_order_id
        FOREIGN KEY (client_order_id)
            REFERENCES client_orders (client_order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_orders$painting_id
        FOREIGN KEY (painting_id)
            REFERENCES paintings (painting_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE client_orders
    ADD CONSTRAINT fk_client_orders$client_id
        FOREIGN KEY (client_id)
            REFERENCES clients (client_id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_client_orders$discount_id
        FOREIGN KEY (discount_id)
            REFERENCES discounts (discount_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE clients
    ADD CONSTRAINT fk_clients$account_id
        FOREIGN KEY (account_id)
            REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE;