<%@ page language="java" import="java.sql.*" %>
<%
    String url = "jdbc:mysql://localhost:3306/felix_uber_shop_20240304";
    String user = "root"; 
    String password = ""; 

    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        conn = DriverManager.getConnection(url, user, password);
        
    } catch (Exception e) {
        out.println("Não foi possível ligar à base de dados. Detalhes: " + e.getMessage());
    }
%>
