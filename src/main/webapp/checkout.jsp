<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ include file="database.jsp" %>
<%
    Connection con = null;
    try {
        con = getConnection();
        HashMap<Integer, HashMap<String, Object>> cartMap = (HashMap<Integer, HashMap<String, Object>>) session.getAttribute("cart");

        if (cartMap != null && !cartMap.isEmpty()) {
            double total = 0;
            ArrayList<HashMap<String, Object>> cartItemsForReceipt = new ArrayList<>();

            // Calculate total and prepare data for receipt
            for (Map.Entry<Integer, HashMap<String, Object>> entry : cartMap.entrySet()) {
                HashMap<String, Object> itemDetails = entry.getValue();
                int productId = entry.getKey();
                String name = (String) itemDetails.get("name");
                int quantity = (Integer) itemDetails.get("quantity");
                double price = (Double) itemDetails.get("price");
                double subtotal = price * quantity;
                total += subtotal;

                HashMap<String, Object> receiptItem = new HashMap<>();
                receiptItem.put("id", productId);
                receiptItem.put("name", name);
                receiptItem.put("quantity", quantity);
                receiptItem.put("price", price);
                receiptItem.put("subtotal", subtotal);
                cartItemsForReceipt.add(receiptItem);
            }

            // Insert sale
            PreparedStatement salePs = con.prepareStatement("INSERT INTO sales (total, sale_time) VALUES (?, NOW())", Statement.RETURN_GENERATED_KEYS);
            salePs.setDouble(1, total);
            salePs.executeUpdate();
            ResultSet saleKeys = salePs.getGeneratedKeys();
            int saleId = 0;
            if (saleKeys.next()) {
                saleId = saleKeys.getInt(1);
            }
            salePs.close();

            // Insert sale items
            PreparedStatement itemPs = con.prepareStatement("INSERT INTO sale_items (sale_id, product_id, quantity, subtotal) VALUES (?, ?, ?, ?)");
            for (HashMap<String, Object> item : cartItemsForReceipt) {
                itemPs.setInt(1, saleId);
                itemPs.setInt(2, (Integer) item.get("id"));
                itemPs.setInt(3, (Integer) item.get("quantity"));
                itemPs.setDouble(4, (Double) item.get("subtotal"));
                itemPs.executeUpdate();
            }
            itemPs.close();

            // Update product stock
            PreparedStatement updatePs = con.prepareStatement("UPDATE products SET quantity = quantity - ? WHERE id = ?");
            for (Map.Entry<Integer, HashMap<String, Object>> entry : cartMap.entrySet()) {
                int productId = entry.getKey();
                int quantity = (Integer) entry.getValue().get("quantity");
                updatePs.setInt(1, quantity);
                updatePs.setInt(2, productId);
                updatePs.executeUpdate();
            }
            updatePs.close();

            // Store info for receipt
            session.setAttribute("receiptItems", cartItemsForReceipt);
            session.setAttribute("orderTotal", total);
            session.removeAttribute("cart");

            // Retrieve cash paid and change amount from session
            Double cashPaid = (Double) session.getAttribute("cashPaid");
            Double changeAmount = (Double) session.getAttribute("changeAmount");
            if (cashPaid == null) cashPaid = 0.0;
            if (changeAmount == null) changeAmount = 0.0;

%>
<html>
<head>
    <title>Receipt</title>
    <script>
        function printReceipt() {
            window.print();
        }
    </script>
    <style>
        @media print {
            button { display: none; }
        }
        body {
            font-family: sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #f4f4f4;
            margin: 0;
        }
        .receipt-container {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
            width: 400px; /* Adjust width as needed */
            max-width: 95%;
        }
        .logo-container {
            text-align: center;
            margin-bottom: 15px;
        }
        .logo {
            max-width: 100px; /* Adjust size as needed */
            height: auto;
        }
        h2 {
            text-align: center;
            margin-top: 0;
            margin-bottom: 10px;
            color: #333;
        }
        .info-line {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-size: 0.9em;
            color: #555;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 8px 0;
            text-align: left;
            border-bottom: 1px dashed #ccc;
        }
        th {
            font-weight: bold;
        }
        .total-section {
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #ccc;
        }
        .total-line {
            display: flex;
            justify-content: space-between;
            font-weight: bold;
            font-size: 1em;
            color: #333;
            margin-bottom: 5px;
        }
        .button-container {
            text-align: center;
            margin-top: 20px;
        }
        button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
        }
        button:hover {
            background-color: #0056b3;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 10px;
            color: #007bff;
            text-decoration: none;
            font-size: 0.9em;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="receipt-container">
    <div class="logo-container">
        <img src="<%= request.getContextPath() %>/logo/mylogo.png" alt="Your POS Logo" class="logo">
        <p style="text-align: center;">IGZZY'S IT SOLUTIONS</p>
    </div>
    <h2>Receipt</h2>
    <div class="info-line">
        <span><strong>Sale ID:</strong> <%= saleId %></span>
        <span><%= new SimpleDateFormat("dd/MM/yy, HH:mm").format(new java.util.Date()) %></span>
    </div>
    <table>
        <thead>
        <tr>
            <th>#</th>
            <th>Item</th>
            <th>Qty</th>
            <th style="text-align: right;">Subtotal</th>
        </tr>
        </thead>
        <tbody>
        <%
            ArrayList<HashMap<String, Object>> receiptItems = (ArrayList<HashMap<String, Object>>) session.getAttribute("receiptItems");
            Double orderTotal = (Double) session.getAttribute("orderTotal");
            if (receiptItems != null) {
                int itemCount = 1;
                for (HashMap<String, Object> item : receiptItems) {
        %>
        <tr>
            <td><%= itemCount++ %></td>
            <td><%= item.get("name") %></td>
            <td><%= item.get("quantity") %></td>
            <td style="text-align: right;">R <%= String.format("%.0f", item.get("subtotal")) %></td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
    <div class="total-section">
        <div class="total-line">
            <span><strong>TOTAL</strong></span>
            <span>R <%= orderTotal != null ? String.format("%.0f", orderTotal) : "0" %></span>
        </div>
        <div class="total-line">
            <span>PAY AMOUNT</span>
            <span>R <%= String.format("%.0f", cashPaid) %></span>
        </div>
        <div class="total-line">
            <span>CHANGE</span>
            <span>R <%= String.format("%.0f", changeAmount) %></span>
        </div>
    </div>
    <div class="button-container">
        <button onclick="printReceipt()">Print Receipt</button>
    </div>
    <a href="index.jsp" class="back-link">Back to products</a>
</div>
</body>
</html>
<%
} else {
%>
<h2>Cart is empty!</h2>
<a href="index.jsp">Back to products</a>
<%
        }
        con.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>