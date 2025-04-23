
CREATE SCHEMA IF NOT EXISTS hive.default;

SHOW TABLES FROM hive.default;

CREATE TABLE hive.default.customer_sf100
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.customer;

CREATE TABLE hive.default.orders_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.orders;

CREATE TABLE hive.default.lineitem_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.lineitem;

CREATE TABLE hive.default.part_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.part;

CREATE TABLE hive.default.partsupp_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.partsupp;

CREATE TABLE hive.default.supplier_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.supplier;

CREATE TABLE hive.default.nation_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.nation;

CREATE TABLE hive.default.region_sf150
       WITH (format = 'PARQUET')
AS SELECT * FROM tpch.sf150.region;

-- Q1
SELECT
    l_returnflag,
    l_linestatus,
    SUM(l_quantity) AS sum_qty,
    SUM(l_extendedprice) AS sum_base_price,
    SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
    SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
    AVG(l_quantity) AS avg_qty,
    AVG(l_extendedprice) AS avg_price,
    AVG(l_discount) AS avg_disc,
    COUNT(*) AS count_order
FROM
    hive.default.lineitem_sf50
WHERE
    l_shipdate <= DATE '1998-12-01' - INTERVAL '90' DAY
GROUP BY
    l_returnflag,
    l_linestatus
ORDER BY
    l_returnflag,
    l_linestatus;

-- Q3
SELECT /*+ BROADCAST(customer) */
    l_orderkey,
    SUM(l_extendedprice * (1 - l_discount)) AS revenue,
    o_orderdate,
    o_shippriority
FROM
    hive.default.customer_sf50,
    hive.default.orders_sf50,
    hive.default.lineitem_sf50
WHERE
    c_mktsegment = 'BUILDING'
    AND c_custkey = o_custkey
    AND l_orderkey = o_orderkey
    AND o_orderdate < DATE '1995-03-15'
    AND l_shipdate > DATE '1995-03-15'
GROUP BY
    l_orderkey,
    o_orderdate,
    o_shippriority
ORDER BY
    revenue DESC,
    o_orderdate limit 10;

   
 -- Q5
SELECT
    n_name,
    SUM(l_extendedprice * (1 - l_discount)) AS revenue
FROM
    hive.default.customer_sf50,
    hive.default.orders_sf50,
    hive.default.lineitem_sf50,
    hive.default.supplier_sf50,
    hive.default.nation_sf50,
    hive.default.region_sf50
WHERE
    c_custkey = o_custkey
    AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey
    AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey
    AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= DATE '1994-01-01'
    AND o_orderdate < DATE '1995-01-01'
GROUP BY
    n_name
ORDER BY
    revenue DESC;
   
-- Q6
SELECT
    SUM(l_extendedprice * l_discount) AS revenue
FROM
     hive.default.lineitem_sf50
WHERE
    l_shipdate >= DATE '1994-01-01'
    AND l_shipdate < DATE '1995-01-01'
    AND l_discount BETWEEN 0.06 - 0.01 AND 0.06 + 0.01
    AND l_quantity < 24;


-- Q13
SELECT
    c_count,
    COUNT(*) AS custdist
FROM (
    SELECT
        c.c_custkey,
        COUNT(o.o_orderkey) AS c_count
    FROM
        hive.default.customer_sf50 c
        LEFT OUTER JOIN hive.default.orders_sf50 o
            ON c.c_custkey = o.o_custkey
            AND o.o_comment NOT LIKE '%special%requests%'
    GROUP BY
        c.c_custkey
) AS c_orders
GROUP BY
    c_count
ORDER BY
    custdist DESC,
    c_count DESC;

