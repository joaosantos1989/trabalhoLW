<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    // --- 1. Segurança de Login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return;
    }

    // --- 2. Definir página de retorno (Admin ou Funcionário) ---
    int tipoLogado = (int)tipoConta;
    String pagVolta = (tipoLogado == 1) ? "pagina_admin.jsp?secao=encomendas" : "pagina_funcionario.jsp?secao=encomendas";

    String idEncRecebido = request.getParameter("id_enc");

    if (idEncRecebido != null && conn != null) {
        int idEnc = Integer.parseInt(idEncRecebido);

        // --- 3. Apenas mudar o estado da encomenda ---
        // Como o dinheiro já foi retirado no "preparar_encomenda.jsp",
        // aqui o Admin apenas confirma que a encomenda foi finalizada/enviada.
        String sqlValida = "UPDATE ENCOMENDA SET estado = 2 WHERE id_encomenda = ?";
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