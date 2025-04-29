<%@ page import="java.util.HashMap" %>
<%
    int productId = Integer.parseInt(request.getParameter("product_id"));
    int quantity = Integer.parseInt(request.getParameter("quantity"));

    HashMap<Integer, HashMap<String, Object>> cart = (HashMap<Integer, HashMap<String, Object>>) session.getAttribute("cart");

    if (cart != null && cart.containsKey(productId)) {
        if (quantity > 0) {
            cart.get(productId).put("quantity", quantity);
        } else {
            cart.remove(productId);
        }
        session.setAttribute("cart", cart);
    }

    // Re-render the cart content with the enhanced visual representation
%>
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
