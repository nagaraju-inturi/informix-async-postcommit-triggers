drop database gamedb;
create database gamedb with log;
create table scores (playerid int, score int); 
create table leaderboard(playerid int, score int);

CREATE PROCEDURE leaderboard_spl(opType char(1), srcid integer, committime integer, txnid bigint, playerid_bef integer, score_bef int, playerid_aft int, score_aft int)
DEFINE l_rowid integer;
DEFINE l_min integer;
DEFINE l_count integer;

LET l_min = 0;
LET l_rowid = 0;
LET l_count = 0;

    --TRACE ON;
    IF opType != 'I' THEN
       RETURN;
    END IF
    SELECT COUNT(*) INTO l_count FROM leaderboard;
    IF l_count < 10 THEN
       INSERT INTO leaderboard VALUES (playerid_aft, score_aft);
    ELSE
       LET l_min, l_rowid = (SELECT FIRST 1 score, rowid FROM leaderboard WHERE score in (SELECT MIN(score) FROM leaderboard));
       IF l_min >= score_aft THEN
          RETURN;
       END IF
       DELETE FROM leaderboard where rowid = l_rowid;
       INSERT INTO leaderboard VALUES (playerid_aft, score_aft);
    END IF
END PROCEDURE;

-- cdr define repl game -C always -S row -M g_informix -A -R --serial --splname=leaderboard_spl  "gamedb@g_informix:informix.scores" "select * from scores" "gamedb@g_lb:informix.scores" "select * from scores"
-- infx cdr start repl game
-- set debug fole to "/tmp/nag.out";
-- execute procedure leaderboard_spl('I', 1,1,1,NULL, NULL, 1, 1);
-- execute procedure leaderboard_spl('I', 1,1,1,NULL, NULL, 2, 2);

