package com.example.pos.servlet; // Replace with your actual package name

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.example.pos.DatabaseConnection;

@WebServlet("/ProductAddServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 5,   // 5MB
        maxRequestSize = 1024 * 1024 * 10) // 10MB
public class ProductAddServlet extends HttpServlet {

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String filename = s.substring(s.indexOf("=") + 2, s.length() - 1);
                // Fix for IE and Edge which sometimes include full path
                filename = filename.substring(filename.lastIndexOf('\\') + 1);
                return filename;
            }
        }
        return "";
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");
        String sku = request.getParameter("sku");
        String category = request.getParameter("category");
        Part filePart = request.getPart("image");
        String fileName = getFileName(filePart);
        String uploadDirectory = getServletContext().getRealPath("img");
        String message = "";

        // Validate input (basic validation, you might want to add more)
        if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty() || quantityStr == null || quantityStr.trim().isEmpty()) {
            message = "Error: Product Name, Price, and Quantity are required.";
            request.setAttribute("error", message);
            request.getRequestDispatcher("admin.jsp").forward(request, response);
            return;
        }

        double price;
        int quantity;
        try {
            price = Double.parseDouble(priceStr);
            quantity = Integer.parseInt(quantityStr);
            if (price < 0 || quantity < 0) {
                message = "Error: Price and Quantity cannot be negative.";
                request.setAttribute("error", message);
                request.getRequestDispatcher("admin.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            message = "Error: Invalid Price or Quantity format.";
            request.setAttribute("error", message);
            request.getRequestDispatcher("admin.jsp").forward(request, response);
            return;
        }

        String finalFileName = "";
        if (filePart != null && filePart.getSize() > 0) {
            // Create upload directory if it doesn't exist
            File uploadDir = new File(uploadDirectory);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Generate a unique filename (you can enhance this)
            String baseName = fileName;
            String ext = "";
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex > 0) {
                baseName = fileName.substring(0, dotIndex);
                ext = fileName.substring(dotIndex);
            }
            finalFileName = baseName + "_" + System.currentTimeMillis() + ext;
            File uploadedFile = new File(uploadDir, finalFileName);

            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, Paths.get(uploadedFile.getAbsolutePath()), StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException e) {
                message = "Error saving image: " + e.getMessage();
                request.setAttribute("error", message);
                request.getRequestDispatcher("admin.jsp").forward(request, response);
                return;
            }
        } else {
            finalFileName = ""; // No image uploaded
        }

        // Database interaction
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DatabaseConnection.getConnection(); // Assuming you have this utility class
            String sql = "INSERT INTO products (name, price, quantity, sku, category, image_path) VALUES (?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setDouble(2, price);
            ps.setInt(3, quantity);
            ps.setString(4, sku);
            ps.setString(5, category);
            ps.setString(6, finalFileName);
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                message = "Product added successfully!";
                request.setAttribute("msg", message);
            } else {
                message = "Error adding product to the database.";
                request.setAttribute("error", message);
            }
        } catch (SQLException e) {
            message = "Database error: " + e.getMessage();
            e.printStackTrace();
            request.setAttribute("error", message);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        } finally {
            DatabaseConnection.closeConnection(con); // Assuming you have this utility method
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
        }

        response.sendRedirect("admin.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}