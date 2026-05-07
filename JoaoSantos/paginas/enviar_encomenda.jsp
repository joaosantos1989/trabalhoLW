<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    String idEnc = request.getParameter("id_enc");
    if (idEnc != null && conn != null) {
        // Muda o estado para 1 (Aguardar validação do funcionário)
        String sql = "UPDATE ENCOMENDA SET estado = 1 WHERE id_encomenda = ?";
        PreparedStatement statement = conn.prepareStatement(sql);
        statement.setInt(1, Integer.parseInt(idEnc));
        statement.executeUpdate();

        // Redireciona com uma mensagem de sucesso
        response.sendRedirect("pagina_principal.jsp?msg=pendente");
    }
%>