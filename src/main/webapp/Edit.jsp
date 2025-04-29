<%@ page import="java.sql.*" %>
<%@ include file="database.jsp" %>
<%
  String admin = (String) session.getAttribute("admin");
  if (admin == null) {
    response.sendRedirect("admin_login.jsp");
    return;
  }

  int id = Integer.parseInt(request.getParameter("id"));
  String message = "";

  // Load existing product data
  String name = "", sku = "", category = "", imagePath = "";
  double price = 0;
  int quantity = 0;

  try (Connection con = getConnection()) {
    PreparedStatement ps = con.prepareStatement("SELECT * FROM products WHERE id=?");
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      name = rs.getString("name");
      price = rs.getDouble("price");
      quantity = rs.getInt("quantity");
      sku = rs.getString("sku");
      category = rs.getString("category");
      imagePath = rs.getString("image_path");
    } else {
      message = "Product not found!";
    }
  } catch (Exception e) {
    message = "Error loading product: " + e.getMessage();
  }

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String updatedName = request.getParameter("name");
    double updatedPrice = Double.parseDouble(request.getParameter("price"));
    int updatedQuantity = Integer.parseInt(request.getParameter("quantity"));
    String updatedSku = request.getParameter("sku");
    String updatedCategory = request.getParameter("category");

    try (Connection con = getConnection()) {
      PreparedStatement ps = con.prepareStatement("UPDATE products SET name=?, price=?, quantity=?, sku=?, category=? WHERE id=?");
      ps.setString(1, updatedName);
      ps.setDouble(2, updatedPrice);
      ps.setInt(3, updatedQuantity);
      ps.setString(4, updatedSku);
      ps.setString(5, updatedCategory);
      ps.setInt(6, id);
      int rowsAffected = ps.executeUpdate();
      if (rowsAffected > 0) {
        response.sendRedirect("admin.jsp?msg=Product+updated+successfully!");
        return;
      } else {
        message = "Error updating product.";
      }
    } catch (Exception e) {
      message = "Error: " + e.getMessage();
    }
  }
%>
<html>
<head>
  <title>Edit Product</title>
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

    .edit-container {
      background-color: #fff;
      padding: 30px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      display: grid;
      grid-template-columns: 1fr 1fr; /* Two equal columns */
      gap: 20px;
      width: 800px; /* Adjust as needed */
    }

    .image-column {
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .product-image {
      max-width: 100%;
      max-height: 300px; /* Adjust as needed */
      border-radius: 4px;
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
    }

    .no-image {
      background-color: #eee;
      color: #777;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 300px; /* Match max-height of image */
      border-radius: 4px;
      font-size: 1.2em;
    }

    .details-column {
      display: flex;
      flex-direction: column;
    }

    h2 {
      color: #333;
      margin-bottom: 20px;
      text-align: left; /* Align heading to the left in its column */
    }

    label {
      display: block;
      margin-bottom: 8px;
      color: #555;
      font-weight: bold;
      text-align: left;
    }

    input[type="text"],
    input[type="number"] {
      width: calc(100% - 22px);
      padding: 10px;
      margin-bottom: 15px;
      border: 1px solid #ccc;
      border-radius: 4px;
      box-sizing: border-box;
      font-size: 1em;
    }

    .button-container {
      display: flex;
      gap: 10px; /* Space between buttons */
      margin-top: 15px;
    }

    input[type="submit"],
    .cancel-button {
      background-color: #007bff;
      color: white;
      padding: 12px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 1em;
      width: 100%; /* Make buttons take equal width */
      text-decoration: none; /* Remove underline from link */
      text-align: center; /* Center text in button/link */
      box-sizing: border-box; /* Include padding and border in width */
    }

    input[type="submit"]:hover,
    .cancel-button:hover {
      background-color: #0056b3;
    }

    .cancel-button {
      background-color: #6c757d; /* Gray color for cancel */
    }

    .cancel-button:hover {
      background-color: #545b62;
    }

    p.error-message {
      color: red;
      margin-top: 15px;
      font-size: 0.9em;
      text-align: left;
    }
  </style>
</head>
<body>
<div class="edit-container">
  <div class="image-column">
    <% if (imagePath != null && !imagePath.isEmpty()) { %>
    <img src="<%= request.getContextPath() %>/img/<%= imagePath %>" alt="<%= name %>" class="product-image">
    <% } else { %>
    <div class="no-image">No Image</div>
    <% } %>
  </div>
  <div class="details-column">
    <h2>Edit Product</h2>
    <form method="post">
      <label for="name">Name:</label>
      <input type="text" id="name" name="name" value="<%= name %>" required><br>
      <label for="price">Price:</label>
      <input type="text" id="price" name="price" value="<%= price %>" required><br>
      <label for="quantity">Quantity:</label>
      <input type="number" id="quantity" name="quantity" value="<%= quantity %>" required><br>
      <label for="sku">SKU:</label>
      <input type="text" id="sku" name="sku" value="<%= sku %>"><br>
      <label for="category">Category:</label>
      <input type="text" id="category" name="category" value="<%= category %>"><br>
      <div class="button-container">
        <a href="admin.jsp" class="cancel-button">Cancel</a>
        <input type="submit" value="Update Product">
      </div>
    </form>
    <% if (!message.isEmpty()) { %>
    <p class="error-message"><%= message %></p>
    <% } %>
  </div>
</div>
</body>
</html>