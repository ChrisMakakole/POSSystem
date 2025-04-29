<%@ page import="java.sql.*" %>
<%@ include file="database.jsp" %>
<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection con = getConnection()) {
            PreparedStatement ps = con.prepareStatement("SELECT * FROM admin WHERE username=? AND password=?");
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                session.setAttribute("admin", username);
                response.sendRedirect("admin.jsp");
                return;
            } else {
                message = "Invalid username or password!";
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<html>
<head>
    <title>Admin Login</title>
    <style>
        body {
            font-family: sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .login-container {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            text-align: center;
            width: 350px;
        }

        h2 {
            color: #333;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
            text-align: left;
        }

        input[type="text"],
        input[type="password"] {
            width: calc(100% - 22px);
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 1em;
        }

        input[type="submit"] {
            background-color: #007bff;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1em;
            width: 100%;
        }

        input[type="submit"]:hover {
            background-color: #0056b3;
        }

        p.error-message {
            color: red;
            margin-top: 15px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
<div class="login-container">
    <h2>Admin Login</h2>
    <form method="post" autocomplete="off">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" autocomplete="off" required><br>
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" autocomplete="new-password" required><br><br>
        <input type="submit" value="Login">
    </form>
    <p class="error-message"><%= message %></p>
</div>
</body>
</html>