<%@ page import="java.sql.*" %>
<%@ include file="database.jsp" %>
<%
    String admin = (String) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    String id = request.getParameter("id");

    try (Connection con = getConnection()) {
        PreparedStatement ps = con.prepareStatement("UPDATE products SET active = TRUE WHERE id = ?");
        ps.setInt(1, Integer.parseInt(id));
        ps.executeUpdate();
        response.sendRedirect("admin.jsp");
    } catch (Exception e) {
        System.out.println("Error restoring product: " + e.getMessage());
    }
%>
