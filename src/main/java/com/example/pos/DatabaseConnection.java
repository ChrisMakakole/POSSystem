// DatabaseConnection.java
package com.example.pos; // Consider creating a 'util' package for utility classes

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/pos_system?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASSWORD = "12345";
    private static final String DRIVER_CLASS = "com.mysql.cj.jdbc.Driver";

    // Private constructor to prevent instantiation from other classes
    private DatabaseConnection() {}

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // Load the driver class only once.
        Class.forName(DRIVER_CLASS); // Load the driver
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                // Log the error (very important!) -  Do NOT just print to console in real apps
                e.printStackTrace(); //  Good for development, but use a proper logger (like Log4j) in production
            }
        }
    }
}
