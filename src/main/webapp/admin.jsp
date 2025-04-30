<%@ page import="java.sql.*" %>
<%@ page import="com.example.pos.DatabaseConnection" %> <%-- Import the DatabaseConnection class --%>
<%
    // Check if admin is logged in
    String admin = (String) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    // Display success/error messages if any
    String msg = request.getParameter("msg");
    String error = (String) request.getAttribute("error");
%>

<html>
<head>
    <title>Admin Panel</title>
    <style>
        body {
            font-family: sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }

        h2, h3 {
            color: #333;
            margin-bottom: 15px;
        }

        a {
            color: #007bff;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        .message {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
        }

        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        form {
            background-color: #fff;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 10px;
            align-items: center;
            max-width: 500px;
        }

        label {
            font-weight: bold;
            grid-column: 1;
            text-align: left;
            padding-right: 10px;
        }

        input[type="text"],
        input[type="number"],
        input[type="file"] {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 100%;
            box-sizing: border-box;
            grid-column: 2;
        }

        input[type="submit"] {
            background-color: #007bff;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            grid-column: 2;
        }

        input[type="submit"]:hover {
            background-color: #0056b3;
        }

        .product-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .product-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 15px;
            text-align: center;
        }

        .product-image {
            max-width: 100%;
            height: auto;
            margin-bottom: 10px;
            border-radius: 4px;
        }

        .product-name {
            font-weight: bold;
            margin-bottom: 5px;
        }

        .product-details {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 8px;
        }

        .product-actions a {
            margin: 0 5px;
            padding: 5px 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 0.85em;
        }

        .product-actions a:hover {
            background-color: #f0f0f0;
        }

        .no-image {
            background-color: #eee;
            color: #777;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 80px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<h2>Admin Panel</h2>
<a href="logout.jsp" style="float: right;">Logout</a>
<br><br>

<%
    if (msg != null && !msg.trim().isEmpty()) {
%>
<p class="message success"><%= msg %></p>
<%
    }
    if (error != null) {
%>
<p class="message error"><%= error %></p>
<%
    }
%>

<h3>Add New Product</h3>
<form method="post" action="<%= request.getContextPath() %>/ProductAddServlet" enctype="multipart/form-data">
    <label>Product Name:</label>
    <input type="text" name="name" required><br>
    <label>Price:</label>
    <input type="text" name="price" required><br>
    <label>Quantity:</label>
    <input type="text" name="quantity" required><br>
    <label>SKU / Barcode:</label>
    <input type="text" name="sku"><br>
    <label>Category:</label>
    <input type="text" name="category"><br>
    <label>Product Image:</label>
    <input type="file" name="image"><br><br>
    <input type="submit" value="Add Product">
</form>

<h3>Product List</h3>
<div class="product-list">
    <%
        Connection con = null;
        try {
            con = DatabaseConnection.getConnection();
            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM products WHERE quantity > 0");
            while (rs.next()) {
    %>
    <div class="product-card">
        <% if (rs.getString("image_path") != null && !rs.getString("image_path").isEmpty()) { %>
        <img src="<%= request.getContextPath() %>/img/<%= rs.getString("image_path") %>" alt="<%= rs.getString("name") %>" class="product-image">
        <% } else { %>
        <div class="no-image">No Image</div>
        <% } %>
        <h4 class="product-name"><%= rs.getString("name") %></h4>
        <p class="product-details">Price: Rp. <%= String.format("%.2f", rs.getDouble("price")) %></p>
        <p class="product-details">Stock: <%= rs.getInt("quantity") %></p>
        <p class="product-details">SKU: <%= rs.getString("sku") != null ? rs.getString("sku") : "-" %></p>
        <p class="product-details">Category: <%= rs.getString("category") != null ? rs.getString("category") : "-" %></p>
        <div class="product-actions">
            <a href="Edit.jsp?id=<%= rs.getInt("id") %>">Edit</a>
            <%-- Add Delete/Restore links here if you implement those functionalities --%>
        </div>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<p class='message error'>Error loading products: " + e.getMessage() + "</p>");
        } finally {
            if (con != null) {
                DatabaseConnection.closeConnection(con);
            }
        }
    %>
</div>

</body>
</html>
