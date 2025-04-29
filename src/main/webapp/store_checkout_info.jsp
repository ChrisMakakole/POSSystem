<%@ page import="java.util.HashMap" %>
<%
  String cashParam = request.getParameter("cash");
  String changeParam = request.getParameter("change");

  if (cashParam != null && changeParam != null) {
    try {
      double cash = Double.parseDouble(cashParam);
      double change = Double.parseDouble(changeParam);

      session.setAttribute("cashPaid", cash);
      session.setAttribute("changeAmount", change);
      response.getWriter().write("success"); // Send a success response back to the client
    } catch (NumberFormatException e) {
      response.getWriter().write("error: Invalid cash or change value.");
      e.printStackTrace();
    }
  } else {
    response.getWriter().write("error: Missing cash or change parameters.");
  }
%>