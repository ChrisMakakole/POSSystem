<%@ page import="java.sql.*, java.util.List, java.util.ArrayList, java.util.HashMap" %>
<%@ include file="database.jsp" %>
<%
    // Initialize or retrieve cart from session
    HashMap<Integer, HashMap<String, Object>> cart = (HashMap<Integer, HashMap<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
        session.setAttribute("cart", cart);
    }

    Connection con = null;
    try {
        con = getConnection();
    } catch (Exception e) {
        // Handle database connection error
        e.printStackTrace();
        request.setAttribute("db_error", "Error connecting to the database.");
    }
%>
<html>
<head>
    <title>POS - Product List and Cart</title>
    <style>
        body {
            font-family: sans-serif;
            margin: 0;
            background-color: #f4f4f4;
            display: grid;
            grid-template-columns: 2fr 1fr; /* Left for products, right for cart */
            grid-template-rows: auto 1fr; /* Add a row for the topnav */
            min-height: 100vh;
            overflow: hidden; /* Prevent body scrollbar */
        }

        .topnav {
            background-color: #333;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            grid-column: 1 / 3; /* Span across both columns */
        }

        .topnav a {
            color: white;
            text-decoration: none;
            margin-right: 15px;
        }

        .topnav a:hover {
            color: #ddd;
        }

        .product-container {
            padding: 20px; /* Keep some padding around the grid */
            display: grid;
            grid-template-columns: repeat(4, minmax(150px, 1fr)); /* Explicitly create 4 columns */
            gap: 15px;
            overflow-y: auto;
            max-height: calc(100vh - 50px - 40px); /* Adjust for topnav and bottom spacing */
        }

        .product-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 10px; /* Standard padding within the card */
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            cursor: pointer;
            max-height: 250px; /* Keep a max height for individual cards */
        }

        .product-card:hover {
            transform: scale(1.02);
            transition: transform 0.2s ease-in-out;
        }

        .product-image {
            max-width: 100%;
            height: auto;
            margin-bottom: 5px;
            border-radius: 4px;
            max-height: 120px;
            object-fit: cover;
            pointer-events: none;
        }

        .no-image {
            background-color: #eee;
            color: #777;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 80px;
            border-radius: 4px;
            margin-bottom: 5px;
            pointer-events: none;
        }

        .product-name {
            font-weight: bold;
            margin-bottom: 3px;
            font-size: 0.8em;
            pointer-events: none;
        }

        .product-price {
            color: #007bff;
            font-weight: bold;
            font-size: 0.75em;
            pointer-events: none;
        }

        .cart-container {
            background-color: #fff;
            padding-top: 20px;
            padding-right: 20px;
            padding-bottom: 20px;
            padding-left: 20px;
            border-left: 1px solid #ddd;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: 650px; /* Adjust based on content */
            overflow-y: auto;
            border-radius: 8px;
            margin: 20px; /* Space from topnav */
        }

        .cart-title {
            text-align: center;
            margin-bottom: 10px;
            color: #333;
        }

        .cart-items {
            list-style: none;
            padding: 0;
            margin-bottom: 10px;
            overflow-y: auto;
            max-height: calc(100% - 200px); /* Adjust based on other cart elements */
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .cart-item-card {
            background-color: #f9f9f9;
            border-radius: 10px;
            padding: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .cart-item-details {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-grow: 1;
        }

        .cart-item-image-container {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background-color: #e0e0e0;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
        }

        .cart-item-image {
            max-width: 100%;
            max-height: 100%;
            object-fit: cover;
        }

        .no-image-cart {
            background-color: #e0e0e0;
            color: #777;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
            width: 100%;
            font-size: 0.7em;
            border-radius: 8px;
        }

        .cart-item-name-price {
            flex-grow: 1;
        }

        .cart-item-name-bold {
            display: block;
            font-weight: bold;
            font-size: 0.9em;
        }

        .cart-item-price {
            color: #007bff;
            font-size: 0.8em;
        }

        .cart-item-quantity-controls {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .quantity-button {
            background-color: #4a6572;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 10px 15px;
            cursor: pointer;
            font-size: 0.8em;
            line-height: 1;
        }

        .quantity-button:hover {
            background-color: #364e58;
        }

        .quantity-input {
            width: 34px;
            height: 34px;
            text-align: center;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 0.8em;
        }

        .cart-total-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #eee;
        }

        .cart-total-label {
            font-weight: bold;
            font-size: 0.9em;
        }

        .cart-total-price {
            font-weight: bold;
            color: #007bff;
            font-size: 1.1em;
        }

        .checkout-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.95em;
            width: 100%;
            margin-top: 15px;
        }

        .checkout-button:hover {
            background-color: #0056b3;
        }

        .cart-cash-section {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #eee;
        }

        .cart-cash-input-group {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .cart-cash-label {
            font-weight: bold;
            font-size: 0.9em;
        }

        #cash {
            width: 100px;
            text-align: right;
            border: 1px solid #ccc;
            border-radius: 4px;
            padding: 5px;
            font-size: 0.9em;
        }

        .cart-cash-buttons {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 5px;
        }

        .cart-change-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #eee;
        }

        #change-label {
            font-weight: bold;
            font-size: 0.9em;
        }

        #change-amount {
            font-weight: bold;
            color: #007bff;
            font-size: 1.1em;
        }
    </style>
    <script>
        let totalAmount = 0; // To store the total amount dynamically
        let currentCash = 0; // To store the current cash input value

        function addToCart(productId, name, price, imagePath) {
            // Store the current cash value before updating the cart
            const cashInput = document.getElementById('cash');
            if (cashInput) {
                currentCash = parseFloat(cashInput.value || 0);
            }

            fetch('add_to_cart.jsp?product_id=' + productId + '&name=' + encodeURIComponent(name) + '&price=' + price + '&image_path=' + encodeURIComponent(imagePath))
                .then(response => response.text())
                .then(data => {
                    document.getElementById('cart-container').innerHTML = data;
                    // Restore the cash value and update the display
                    const newCashInput = document.getElementById('cash');
                    if (newCashInput) {
                        newCashInput.value = currentCash;
                    }
                    updateCashDisplay();
                });
        }

        function validateQuantity(inputElement, productId) {
            const currentQty = parseInt(inputElement.value);

            if (isNaN(currentQty) || currentQty < parseInt(inputElement.min)) {
                inputElement.value = inputElement.dataset.previousQty;
            } else {
                updateQuantity(productId, currentQty);
                inputElement.dataset.previousQty = currentQty;
            }
        }

        function updateQuantity(productId, newQuantity) {
            // Store the current cash value before updating the cart
            const cashInput = document.getElementById('cash');
            if (cashInput) {
                currentCash = parseFloat(cashInput.value || 0);
            }

            fetch('update_cart.jsp?product_id=' + productId + '&quantity=' + newQuantity)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('cart-container').innerHTML = data;
                    // Restore the cash value and update the display
                    const newCashInput = document.getElementById('cash');
                    if (newCashInput) {
                        newCashInput.value = currentCash;
                    }
                    updateCashDisplay();
                });
        }

        function incrementCash(amount) {
            const cashInput = document.getElementById('cash');
            cashInput.value = parseFloat(cashInput.value || 0) + amount;
            updateChange();
        }

        function updateChange() {
            const cash = parseFloat(document.getElementById('cash').value || 0);
            const changeElement = document.getElementById('change-amount');
            const checkoutButton = document.getElementById('checkoutButton');

            let change = cash - totalAmount;

            if (change >= 0) {
                changeElement.textContent = 'R ' + formatNumber(change);
                document.getElementById('change-label').textContent = 'CHANGE';
                checkoutButton.disabled = false;
            } else {
                changeElement.textContent = 'R ' + formatNumber(change);
                document.getElementById('change-label').textContent = 'REMAINING';
                checkoutButton.disabled = true;
            }
        }

        function formatNumber(number) {
            return number.toLocaleString('id-ID', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
        }

        // Call this function after the cart is initially loaded or updated
        function updateCashDisplay() {
            const totalElement = document.querySelector('.cart-total-price');
            if (totalElement) {
                const totalText = totalElement.textContent.replace('R ', '').replace(/\./g, '');
                totalAmount = parseFloat(totalText);
                updateChange(); // Initial update of change/remaining
            }
        }
        function checkoutWithCash() {
            const cash = parseFloat(document.getElementById('cash').value || 0);
            const total = parseFloat(document.querySelector('.cart-total-price').textContent.replace('R ', '').replace(/\./g, '') || 0);
            const change = cash - total;

            // Store cash and change in session using a fetch request
            fetch('store_checkout_info.jsp?cash=' + cash + '&change=' + change)
                .then(response => response.text())
                .then(data => {
                    // After successfully storing the info, redirect to checkout.jsp
                    window.location.href = 'checkout.jsp';
                })
                .catch(error => {
                    console.error('Error storing checkout info:', error);
                    window.location.href = 'checkout.jsp'; // Redirect even if storing fails (for now)
                });
        }

        // Call updateCashDisplay when the page loads to initialize
        window.onload = updateCashDisplay;
    </script>
</head>
<body>
<div class="topnav">
    <a href="admin.jsp">Admin</a>
</div>

<div class="product-container">
    <%
        if (con != null) {
            try {
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery("SELECT id, name, price, image_path FROM products WHERE quantity > 0");
                while (rs.next()) {
                    int productId = rs.getInt("id");
                    String productName = rs.getString("name");
                    double productPrice = rs.getDouble("price");
                    String imagePath = rs.getString("image_path");
    %>
    <div class="product-card" onclick="addToCart(<%= productId %>, '<%= productName %>', <%= productPrice %>, '<%= imagePath %>')">
        <% if (imagePath != null && !imagePath.isEmpty()) { %>
        <img src="<%= request.getContextPath() %>/img/<%= imagePath %>" alt="<%= productName %>" class="product-image">
        <% } else { %>
        <div class="no-image">No Image</div>
        <% } %>
        <h4 class="product-name"><%= productName %></h4>
        <p class="product-price">R <%= String.format("%.2f", productPrice) %></p>
    </div>
    <%
                }
            } catch (Exception e) {
                out.println("<p class='error-message'>Error loading products: " + e.getMessage() + "</p>");
            } finally {
                try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    %>
</div>

<div class="cart-container" id="cart-container">
    <h2 class="cart-title">Your Cart</h2>
    <% if (cart == null || cart.isEmpty()) { %>
    <p style="text-align: center" class="cart-empty">Cart Empty</p>
    <% } else { %>
    <ul class="cart-items">
        <%
            double total = 0;
            for (HashMap.Entry<Integer, HashMap<String, Object>> entry : cart.entrySet()) {
                int itemId = entry.getKey();
                HashMap<String, Object> item = entry.getValue();
                String name = (String) item.get("name");
                double price = (Double) item.get("price");
                int itemQuantity = (Integer) item.get("quantity");
                String imagePath = (String) item.get("image_path");
                double subtotal = price * itemQuantity;
                total += subtotal;
        %>
        <li class="cart-item-card">
            <div class="cart-item-details">
                <div class="cart-item-image-container">
                    <% if (imagePath != null && !imagePath.isEmpty()) { %>
                    <img src="<%= request.getContextPath() %>/img/<%= imagePath %>" alt="<%= name %>" class="cart-item-image">
                    <% } else { %>
                    <div class="no-image-cart">No Image</div>
                    <% } %>
                </div>
                <div class="cart-item-name-price">
                    <span class="cart-item-name-bold"><%= name %></span>
                    <span class="cart-item-price">R <%= String.format("%.0f", price) %></span>
                </div>
            </div>
            <div class="cart-item-quantity-controls">
                <button class="quantity-button" type="button" onclick="updateQuantity(<%= itemId %>, parseInt(document.getElementById('qty_<%= itemId %>').value) - 1)">-</button>
                <input type="number" id="qty_<%= itemId %>" class="quantity-input" value="<%= itemQuantity %>" min="0" onchange="validateQuantity(this, <%= itemId %>)" data-previous-qty="<%= itemQuantity %>">
                <button class="quantity-button" type="button" onclick="updateQuantity(<%= itemId %>, parseInt(document.getElementById('qty_<%= itemId %>').value) + 1)">+</button>
            </div>
        </li>
        <%
            }
        %>
    </ul>
    <div class="cart-total-section">
        <span class="cart-total-label">Total</span>
        <span class="cart-total-price">R <%= String.format("%.0f", total) %></span>
    </div>

    <div class="cart-cash-section">
        <div class="cart-cash-input-group">
            <span class="cart-cash-label">CASH</span>
            <span>R</span>
            <input type="number" id="cash" style="width: 100px; text-align: right;" value="0" oninput="updateChange()">
        </div>
        <div class="cart-cash-buttons">
            <button type="button" class="quantity-button" onclick="incrementCash(5)">+5</button>
            <button type="button" class="quantity-button" onclick="incrementCash(10)">+10</button>
            <button type="button" class="quantity-button" onclick="incrementCash(20)">+20</button>
            <button type="button" class="quantity-button" onclick="incrementCash(50)">+50</button>
            <button type="button" class="quantity-button" onclick="incrementCash(100)">+100</button>
            <button type="button" class="quantity-button" onclick="incrementCash(200)">+200</button>
        </div>
    </div>

    <div class="cart-change-section">
        <span id="change-label">CHANGE</span>
        <span id="change-amount">R 0</span>
    </div>
    <button id="checkoutButton" class="checkout-button" onclick="checkoutWithCash()" disabled>Checkout</button>
    <% } %>
</div>
</body>
</html>
