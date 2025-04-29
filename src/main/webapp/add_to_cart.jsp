<%@ page import="java.util.HashMap" %>
<%
    int productId = Integer.parseInt(request.getParameter("product_id"));
    String name = request.getParameter("name");
    double price = Double.parseDouble(request.getParameter("price"));
    String imagePath = request.getParameter("image_path"); // Get image path

    HashMap<Integer, HashMap<String, Object>> cart = (HashMap<Integer, HashMap<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
    }

    if (cart.containsKey(productId)) {
        HashMap<String, Object> item = cart.get(productId);
        item.put("quantity", (Integer) item.get("quantity") + 1);
    } else {
        HashMap<String, Object> newItem = new HashMap<>();
        newItem.put("name", name);
        newItem.put("price", price);
        newItem.put("quantity", 1);
        newItem.put("image_path", imagePath); // Store image path in cart item
        cart.put(productId, newItem);
    }

    session.setAttribute("cart", cart);

    // Re-render the cart content with the enhanced visual representation
%>
<h2 class="cart-title">Your Cart</h2>
<% if (cart.isEmpty()) { %>
<p style="text-align: center" class="cart-empty">Cart Empty</p>
<% } else { %>
<ul class="cart-items">
    <%
        double total = 0;
        for (HashMap.Entry<Integer, HashMap<String, Object>> entry : cart.entrySet()) {
            productId = entry.getKey();
            HashMap<String, Object> item = entry.getValue();
            String itemName = (String) item.get("name");
            double itemPrice = (Double) item.get("price");
            int quantity = (Integer) item.get("quantity");
            String itemImagePath = (String) item.get("image_path");
            double subtotal = itemPrice * quantity;
            total += subtotal;
    %>
    <li class="cart-item-card">
        <div class="cart-item-details">
            <div class="cart-item-image-container">
                <% if (itemImagePath != null && !itemImagePath.isEmpty()) { %>
                <img src="<%= request.getContextPath() %>/img/<%= itemImagePath %>" alt="<%= itemName %>" class="cart-item-image">
                <% } else { %>
                <div class="no-image-cart">No Image</div>
                <% } %>
            </div>
            <div class="cart-item-name-price">
                <span class="cart-item-name-bold"><%= itemName %></span>
                <span class="cart-item-price">R <%= String.format("%.0f", itemPrice) %></span>
            </div>
        </div>
        <div class="cart-item-quantity-controls">
            <button class="quantity-button" type="button" onclick="updateQuantity(<%= productId %>, parseInt(document.getElementById('qty_<%= productId %>').value) - 1)">-</button>
            <input type="number" id="qty_<%= productId %>" class="quantity-input" value="<%= quantity %>" min="1">
            <button class="quantity-button" type="button" onclick="updateQuantity(<%= productId %>, parseInt(document.getElementById('qty_<%= productId %>').value) + 1)">+</button>
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
        <input type="number" id="cash" style="width: 100px; text-align: right;" value="<%= request.getParameter("cash") != null ? request.getParameter("cash") : "0" %>" oninput="updateChange()">
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
