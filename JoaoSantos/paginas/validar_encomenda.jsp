<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    // ---segurança de Login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null || (int) tipoConta != 1 && (int) tipoConta != 2) {
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return;
    }

    // --- pagina de utilizador a voltar  ---
    int tipoLogado = (int)tipoConta;
    String pagVolta = (tipoLogado == 1) ? "pagina_admin.jsp?secao=encomendas" : "pagina_funcionario.jsp?secao=encomendas";

    String idEncRecebido = request.getParameter("id_enc");

    if (idEncRecebido != null && conn != null) {
        int idEnc = Integer.parseInt(idEncRecebido);

        // --- mudar o estado da encomenda ---
        // o admin apenas confirma que a encomenda foi validada.
        String sqlValida = "UPDATE ENCOMENDA SET estado = 2 WHERE id_encomenda = ?"; //encomenda validada
        PreparedStatement statementValida = conn.prepareStatement(sqlValida);
        statementValida.setInt(1, idEnc);
        statementValida.executeUpdate();

        // Redireciona com sucesso
        response.sendRedirect(pagVolta + "&msg=sucesso");
        return;

    } else {
        response.sendRedirect("pagina_principal.jsp");
        return;
    }
%>