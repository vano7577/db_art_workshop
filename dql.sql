
CREATE FUNCTION f_total_price (in in_client_order_id int, out numeric(8,2)) AS $$
SELECT sum(price) FROM orders WHERE client_order_id = in_client_order_id
    $$ LANGUAGE SQL;

CREATE FUNCTION f_update_total_price () RETURNS TRIGGER AS $$
    BEGIN
UPDATE client_orders
        SET price = f_total_price(new.client_order_id)
WHERE client_orders.client_order_id = new.client_order_id;
    RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
CREATE TRIGGER t_update_total_price
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW EXECUTE PROCEDURE f_update_total_price();

 --1
UPDATE orders
SET price = 12000
WHERE order_id=1;
--2
SELECT painting_name, sum(orders.price) FROM orders
INNER JOIN paintings on paintings.painting_id = orders.painting_id
INNER JOIN client_orders on client_orders.client_order_id = orders.client_order_id
INNER JOIN clients ON client_orders.client_id = clients.client_id AND
                      client_first_name = 'Petr' AND
                      client_last_name = 'Petrov'
GROUP BY painting_name
ORDER BY painting_name;
--3
SELECT DISTINCT painting_name FROM paintings
INNER JOIN painting_paints on paintings.painting_id = painting_paints.painting_id
INNER JOIN paints on paints.paint_id = painting_paints.paint_id
INNER JOIN paints_types on paints_types.paint_type_id = paints.paint_type_id AND
                           paints_types.paint_type_name = 'oil';
--4
SELECT painting_name FROM paintings
INNER JOIN canvases on canvases.canvas_id = paintings.canvas_id AND
                       canvases.width BETWEEN 100 AND 120;
--5
CREATE FUNCTION count_painter_paintings()
RETURNS TABLE (painter_last_name varchar(255), painter_first_name varchar(255), quantity bigint) AS $$
SELECT  painter_last_name, painter_first_name, count(orders.painting_id) FROM orders
RIGHT OUTER JOIN painters p on p.painter_id = orders.painter_id
GROUP BY painter_last_name, painter_first_name
ORDER BY 3 DESC;
    $$
LANGUAGE SQL;
SELECT * FROM count_painter_paintings();
--6
CREATE FUNCTION count_paintings_by_paint_types()
RETURNS TABLE (paint_type_name varchar(255), quantity_paintings bigint) AS $$
SELECT paints_types.paint_type_name, COUNT(DISTINCT painting_paints.painting_id) FROM paints_types
LEFT OUTER JOIN paints on paints_types.paint_type_id = paints.paint_type_id
LEFT OUTER JOIN painting_paints on paints.paint_id = painting_paints.paint_id
GROUP BY paints_types.paint_type_name
ORDER BY 2 DESC;
    $$
LANGUAGE SQL;
SELECT * FROM count_paintings_by_paint_types();
--7
CREATE FUNCTION find_3_most_expensive_paintings()
RETURNS TABLE (painting_name varchar(255), painting_price numeric(8,2)) AS $$
SELECT painting_name, sum(orders.price) as painting_price FROM orders
INNER JOIN paintings on paintings.painting_id = orders.painting_id
GROUP BY painting_name
ORDER BY painting_price DESC
LIMIT 3;$$ LANGUAGE SQL;
SELECT *FROM find_3_most_expensive_paintings();

--8
SELECT DISTINCT painting_name FROM paintings
INNER JOIN orders on paintings.painting_id = orders.painting_id AND
                     painting_name LIKE '%portrait' AND
                     NOT is_reproduction;
--9
SELECT concat(painter_last_name,' ', painter_first_name) as painter, count(order_id) FROM painters
INNER JOIN orders on painters.painter_id = orders.painter_id AND (deadline BETWEEN '2021-01-01' AND '2021-03-01')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
--10
--insert
--11
--insert
--12
CREATE FUNCTION find_3_most_demanded_providers()RETURNS TABLE(provider_name varchar(255),quantity numeric(10)) AS $$
SELECT provider_name, sum(qua) FROM (
SELECT provider_name, sum(canvases_providers.quantity) as qua FROM providers
LEFT OUTER JOIN canvases_providers on providers.provider_id = canvases_providers.provider_id
GROUP BY provider_name
HAVING sum(canvases_providers.quantity) IS NOT NULL
UNION
SELECT provider_name, sum(paints_providers.quantity) as qua FROM providers
LEFT OUTER JOIN paints_providers on providers.provider_id = paints_providers.provider_id
GROUP BY provider_name
HAVING sum(paints_providers.quantity) IS NOT NULL) as res
GROUP BY provider_name
ORDER BY 2 DESC
LIMIT 3;
    $$ LANGUAGE SQL;
SELECT * FROM find_3_most_demanded_providers();
--13
SELECT DISTINCT concat(painter_last_name,' ', painter_first_name) as painter FROM painters
INNER JOIN genres_painters on painters.painter_id = genres_painters.painter_id
INNER JOIN genres on genres.genre_id = genres_painters.genre_id
WHERE age(experience)> INTERVAL '20' YEAR;
--14
CREATE FUNCTION count_paintings_by_genre(out genre_name varchar(255), out quantity bigint) AS $$
SELECT genres.genre_name, count(paintings.painting_id) FROM genres
INNER JOIN genres_paintings on genres.genre_id = genres_paintings.genre_id
INNER JOIN paintings on paintings.painting_id = genres_paintings.painting_id AND is_reproduction
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
    $$ LANGUAGE SQL;
SELECT * FROM count_paintings_by_genre();
--15
CREATE FUNCTION find_paints_which_ended ()RETURNS TABLE(paint_type_name varchar(255),paint_color varchar(255)) AS $$
SELECT paint_type_name, paint_color FROM (
SELECT paint_type_name, paint_color, sum(paints_providers.quantity) as qua FROM paints
INNER JOIN paints_types on paints_types.paint_type_id = paints.paint_type_id
INNER JOIN paints_providers on paints.paint_id = paints_providers.paint_id
GROUP BY paint_type_name, paint_color
UNION
SELECT paint_type_name, paint_color,-sum(painting_paints.quantity) as qua FROM paints
INNER JOIN paints_types on paints_types.paint_type_id = paints.paint_type_id
INNER JOIN painting_paints on paints.paint_id = painting_paints.paint_id
GROUP BY paint_type_name, paint_color) as res
GROUP BY paint_type_name, paint_color
HAVING sum(qua)=0
$$ LANGUAGE SQL;
SELECT * FROM find_paints_which_ended();
DELETE FROM providers WHERE provider_name = 'PoltavaCanvases';