drop database mqtt;
create database mqtt with log;
create table customer (name char(128), id int);
execute procedure sqlj.install_jar
  ('file:$INFORMIXDIR/jars/mqtt_trigger.jar',
    'mqtt_trigger_jar',
    1);
-- cdr define repl mqrepl -C always -S row -M g_informix -A -R --serial --jsonsplname=mqtt_put "mqtt@g_informix:informix.customer" "select * from customer" "mqtt@g_lb:informix.customer" "select * from customer"
-- infx cdr start repl mqrepl
