import java.sql.*;
import java.util.Random;

public class Producer {
    public static void main(String[] args) throws Exception {
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/gub_test", "postgres", "$Okol622");
        Random random = new Random();

        while (true) {
            boolean isCritical = random.nextInt(100) < 20;
            int priority = isCritical ? 100 : 0;

            conn.setAutoCommit(false);
            try {
                PreparedStatement stmt = conn.prepareStatement("INSERT INTO tasks(payload, priority) VALUES (?::jsonb, ?)");
                stmt.setString(1, "{\"task\":\"do_this\"}");
                stmt.setInt(2, priority);
                stmt.executeUpdate();

                conn.commit();

                System.out.println("Задача добавлена");
            } catch (Exception e) {
                conn.rollback();
            }
            Thread.sleep(10);
        }
    }
}
