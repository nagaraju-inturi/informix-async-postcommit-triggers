import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.StringTokenizer;
import java.util.Date;
import java.text.SimpleDateFormat;
import com.informix.smartTrigger.IfmxSmartTriggerCallback;
import com.informix.smartTrigger.IfxSmartTrigger;
import com.informix.jdbc.IfmxConnection;

public class LeaderBoard implements IfmxSmartTriggerCallback {
    static IfmxConnection conn;
    static String         url;

public static void main(String[] args) throws SQLException {
        url = "jdbc:informix-sqli://informix:60000/gamedb:user=informix;password=changeme";
        getConnection(url);
	printLeaderBoard();

        IfxSmartTrigger trigger = new IfxSmartTrigger("jdbc:informix-sqli://informix:60000/sysadmin:user=informix;password=changeme");
        trigger.timeout(5).label("leaderboard_alert");  //optional parameters
        trigger.addTrigger("leaderboard", "informix", "gamedb", 
                "SELECT * FROM leaderboard", new LeaderBoard());
        trigger.watch();
}
@Override
public void notify(String json) {
        //System.out.println("Leader board Ping!");
        if(json.contains("ifx_isTimeout")) {
                        //System.out.println("-- No change to leader board");
        }
        else if (json.contains("insert")){
                        System.out.println("-- Changes detected to leader board!");
                        //System.out.println("   " + json);
			printLeaderBoard();
        }
}

    static void getConnection(String url) {
        try {
            Class.forName("com.informix.jdbc.IfxDriver");
        } catch (Exception e) {
            System.out.println("ERROR: failed to load Informix JDBC driver.");
            e.printStackTrace();
            return;
        }
        try {
            conn = (IfmxConnection) DriverManager.getConnection(url);
            conn.setAutoCommit(false);
            //System.out.println("**** Created a JDBC connection to the data source");
        } catch (SQLException e) {
            System.out.println("ERROR: failed to connect!");
            e.printStackTrace();
            return;
        }
        catch (Exception e) {
            System.out.println("ERROR: failed to connect!");
            e.printStackTrace();
            return;
        }

    }

static void printLeaderBoard() {
        Statement stmt = null;


	System.out.println("-- New Leader Board --");

    try
    {
      // Commit changes manually

      // Create the Statement
      stmt = conn.createStatement();
      System.out.println(String.format("%-5s    %-10s    %s", "Rank", "Player id","Score"));
      //System.out.println("------------------");

      // Execute a query and generate a ResultSet instance
      //ResultSet rs = stmt.executeQuery("SELECT * FROM leaderboard ORDER BY score desc");
      ResultSet rs = stmt.executeQuery("SELECT ROW_NUMBER() OVER(ORDER BY score DESC) AS rank, playerid, score FROM leaderboard");
      //System.out.println("**** Created JDBC ResultSet object");

      // Print all of the employee numbers to standard output device
      while (rs.next()) {
        int rank = rs.getInt(1);
        int playerid = rs.getInt(2);
        int score = rs.getInt(3);
        //System.out.println(playerid + "        " + score);
        System.out.println(String.format("%-5d    %-10d    %d", rank, playerid, score));
      }
      //System.out.println("**** Fetched all rows from JDBC ResultSet");
      // Close the ResultSet
      rs.close();
      //System.out.println("**** Closed JDBC ResultSet");

      // Close the Statement
      stmt.close();
      //System.out.println("**** Closed JDBC Statement");

      // Connection must be on a unit-of-work boundary to allow close
      conn.commit();
      //System.out.println ( "**** Transaction committed" );

    }
    catch(SQLException ex)
    {
      System.err.println("SQLException information");
      while(ex!=null) {
        System.err.println ("Error msg: " + ex.getMessage());
        System.err.println ("SQLSTATE: " + ex.getSQLState());
        System.err.println ("Error code: " + ex.getErrorCode());
        ex.printStackTrace();
        ex = ex.getNextException(); // For drivers that support chained exceptions
      }
    }


}

}
