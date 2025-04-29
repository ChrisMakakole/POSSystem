<%@ page import="java.sql.*" %>
<%!
    Connection getConnection() throws Exception {
        String url = "jdbc:mysql://localhost:3306/pos_system?useSSL=false&allowPublicKeyRetrieval=true";
        String user = "root";
        String password = "12345";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, password);
    }
%>
