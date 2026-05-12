import java.sql.*;
import java.util.Random;

public class Consumer {

    private static final int WORKER_ID = new Random().nextInt(1000);
    private static final int MAX_ATTEMPTS = 3;

    public static void main(String[] args) throws Exception {
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/gub_test", "postgres", "$Okol622");
        Random random = new Random();

        while (true) {
            conn.setAutoCommit(false);
            try {
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM tasks WHERE status='Ready' AND scheduled_at <= NOW() ORDER BY priority DESC, scheduled_at ASC LIMIT 1 FOR UPDATE SKIP LOCKED");
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    int id = rs.getInt("id");
                    int attempts = rs.getInt("attempts");
                    int priority = rs.getInt("priority");
                    String payload = rs.getString("payload");

                    PreparedStatement runStmt = conn.prepareStatement("UPDATE tasks SET status='Running', worker_id=?, updated_at = NOW() WHERE id=?");
                    runStmt.setInt(1, WORKER_ID);
                    runStmt.setInt(2, id);
                    runStmt.executeUpdate();
                    runStmt.close();

                    System.out.println("Задача взята");
                    Thread.sleep(1000);

                    boolean success = random.nextInt(100) < 90;
                    if (success) {
                        PreparedStatement done = conn.prepareStatement("UPDATE tasks SET status='Completed', updated_at=NOW() WHERE id=?");
                        System.out.println("Задача выполнена");
                        done.setInt(1, id);
                        done.executeUpdate();
                        done.close();

                        PreparedStatement log = conn.prepareStatement("INSERT INTO logs(message) VALUES (?)");
                        log.setString(1, "Worker " + WORKER_ID + " выполнил задачу id=" + id + " priority=" + priority + " created_at=" + rs.getTimestamp("created_at"));
                        log.executeUpdate();
                        log.close();
                    } else {
                        if (attempts + 1 >= MAX_ATTEMPTS) {
                            PreparedStatement dlq = conn.prepareStatement("INSERT INTO tasks_dlq(original_task_id, payload, attempts, failed_at, error) VALUES (?, ?::jsonb, ?, NOW(), ?)");
                            dlq.setInt(1, id);
                            dlq.setString(2, payload);
                            dlq.setInt(3, attempts + 1);
                            dlq.setString(4, "Ошибка обработки после " + (attempts + 1) + " попытки");
                            dlq.executeUpdate();

                            PreparedStatement delete = conn.prepareStatement("DELETE FROM tasks WHERE id=?");
                            delete.setInt(1, id);
                            delete.executeUpdate();
                        } else {
                            PreparedStatement retry = conn.prepareStatement("UPDATE tasks SET status='Ready', attempts=attempts+1, scheduled_at=NOW() + INTERVAL '5 minutes', updated_at=NOW() WHERE id=?");
                            retry.setInt(1, id);
                            retry.executeUpdate();
                        }
                    }
                }
                conn.commit();
            } catch(Exception e) {
                conn.rollback();
            }

            Thread.sleep(500);
        }
    }
}
