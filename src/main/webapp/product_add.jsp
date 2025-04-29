<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.IOException" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="javax.servlet.annotation" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ include file="database.jsp" %>

<%
    //@MultipartConfig(fileSizeThreshold = 1024 * 1024,maxFileSize = 1024 * 1024 * 5,maxRequestSize = 1024 * 1024 * 10); // 10 MB

    String admin = (String) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    String name = request.getParameter("name");
    String priceStr = request.getParameter("price");
    String quantityStr = request.getParameter("quantity");
    String sku = request.getParameter("sku");
    String category = request.getParameter("category");
    Part filePart = null;
    String fileName = null;
    String uploadDirectory = application.getRealPath("img"); // Ensure this directory exists in your web app
    String msg = "";

    // Validate input
    if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty() || quantityStr == null || quantityStr.trim().isEmpty()) {
        msg = "Error: Product Name, Price, and Quantity are required.";
        response.sendRedirect("admin.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        return;
    }

    double price = 0;
    int quantity = 0;
    try {
        price = Double.parseDouble(priceStr);
        quantity = Integer.parseInt(quantityStr);
        if (price < 0 || quantity < 0) {
            msg = "Error: Price and Quantity cannot be negative.";
            response.sendRedirect("admin.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
            return;
        }
    } catch (NumberFormatException e) {
        msg = "Error: Invalid Price or Quantity format.";
        response.sendRedirect("admin.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        return;
    }

    try (Connection con = getConnection()) {
        filePart = request.getPart("image");

        if (filePart != null && filePart.getSize() > 0) {
            fileName = getFileName(filePart);
            File uploads = new File(uploadDirectory);
            if (!uploads.exists()) {
                uploads.mkdirs(); // Create directory if it doesn't exist
            }
            File file = new File(uploads, fileName);
            try {
                filePart.write(file.getAbsolutePath());
            } catch (IOException e) {
                e.printStackTrace();
                msg = "Error uploading image: " + e.getMessage();
                response.sendRedirect("admin.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
                return;
            }
        } else {
            fileName = ""; // No image uploaded
        }

        PreparedStatement ps = con.prepareStatement(
                "INSERT INTO products (name, price, quantity, sku, category, image_path) VALUES (?, ?, ?, ?, ?, ?)"
        );
        ps.setString(1, name);
        ps.setDouble(2, price);
        ps.setInt(3, quantity);
        ps.setString(4, sku);
        ps.setString(5, category);
        ps.setString(6, fileName);
        int rowsAffected = ps.executeUpdate();

        if (rowsAffected > 0) {
            msg = "Product added successfully!";
        } else {
            msg = "Error adding product.";
        }

    } catch (Exception e) {
        msg = "Database Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        response.sendRedirect("admin.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    }
%>

<%!
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String filename = s.substring(s.indexOf("=") + 2, s.length() - 1);
                // Remove surrounding quotes if present
                if (filename.startsWith("\"") && filename.endsWith("\"")) {
                    filename = filename.substring(1, filename.length() - 1);
                }
                return filename;
            }
        }
        return "";
    }
%>