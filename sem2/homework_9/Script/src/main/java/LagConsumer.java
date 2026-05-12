import java.sql.*;

public class LagConsumer {
    public static void main(String[] args) throws Exception {
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/gub_test", "postgres", "$Okol622");

        while (true) {
            try {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT EXTRACT(EPOCH FROM NOW() - MIN(created_at)) AS lag_seconds FROM tasks WHERE status = 'Ready'");
                int lag = 0;
                if (rs.next()) {
                    lag = rs.getInt("lag_seconds");
                }

                Statement stmt2 = conn.createStatement();
                ResultSet rs2 = stmt2.executeQuery("SELECT COUNT(*) / 10.0 AS processed_per_sec FROM tasks WHERE status = 'Completed' AND updated_at >= NOW() - INTERVAL '10 seconds'");
                int proc = 0;
                if (rs2.next()) {
                    proc = rs2.getInt("processed_per_sec");
                }

                PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO lag_log(lag_seconds, processed_per_sec) VALUES (?, ?)");
                insertStmt.setInt(1, lag);
                insertStmt.setInt(2, proc);
                insertStmt.executeUpdate();

                System.out.println("Лог добавлен");
            } catch (SQLException e) {
                e.printStackTrace();
            }
            Thread.sleep(5000);
        }
    }
}
