drop database retaildb;
create database retaildb with log;
create table sales (customerid int, storeid int , bill_amount float);
create table sales_summary(storeid int , s_count int, s_sum float, s_avg float, s_min float, s_max float );

CREATE PROCEDURE store_agg(opType char(1), srcid integer, committime integer, txnid bigint, customerid_bef integer, storeid_bef int, bill_amount_bef float, customerid int, storeid_aft int , bill_amount float)
DEFINE l_min float;
DEFINE l_max float;
DEFINE l_avg float;
DEFINE l_sum float;
DEFINE l_count integer;

LET l_min = 0;
LET l_max = 0;
LET l_avg = 0;
LET l_sum = 0;
LET l_count = 0;

    --TRACE ON;
    IF opType != 'I' THEN
       RETURN;
    END IF
    SELECT COUNT(*) INTO l_count FROM sales_summary WHERE storeid = storeid_aft;
    IF l_count == 0 THEN
       LET l_min = bill_amount;
       LET l_max = bill_amount;
       LET l_avg = bill_amount;
       LET l_sum = bill_amount;
       LET l_count = 1;
       INSERT INTO sales_summary VALUES (storeid_aft, l_count, l_sum, l_avg, l_min, l_max);
    ELSE
       LET l_min, l_max, l_avg, l_sum, l_count = (SELECT s_min, s_max, s_avg, s_sum, s_count FROM sales_summary 
             WHERE storeid = storeid_aft);
      LET l_count = l_count + 1;
      LET l_sum = l_sum + bill_amount;
      LET l_avg = l_sum/l_count;
      IF l_min > bill_amount THEN
         LET l_min = bill_amount;
      END IF
      IF l_max < bill_amount THEN
         LET l_max = bill_amount;
      END IF
      UPDATE sales_summary SET (s_count, s_sum, s_avg, s_min, s_max) = (l_count, l_sum, l_avg, l_min, l_max)
           WHERE storeid = storeid_aft;
    END IF
END PROCEDURE;

-- cdr define repl retail -C always -S row -M g_informix -A -R --serial --splname=store_agg "retaildb@g_informix:informix.sales" "select * from sales" "retaildb@g_lb:informix.sales" "select * from sales"
-- infx cdr start repl retail
-- set debug fole to "/tmp/nag.out";
-- execute procedure store_agg('I', 1,1,1,NULL, NULL, NULL, 1, 1, 10.0);
-- execute procedure store_agg('I', 1,1,1,NULL, NULL, NULL, 1, 2, 30.0);

