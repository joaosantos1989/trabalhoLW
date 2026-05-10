<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    String idEncomenda = request.getParameter("id_enc");

    // identificar quem está logado
    int tipoUser = Integer.parseInt(session.getAttribute("TipoConta").toString());
    int idLogado = Integer.parseInt(session.getAttribute("idUtilizador").toString());

    if (idEncomenda != null && conn != null) {
        int idEnc = Integer.parseInt(idEncomenda);

        if (tipoUser == 3) { //se for o cliente
            // primeiro apagamos os itens (senão a BD dá erro de chave estrangeira)
            String sqlItens = "DELETE FROM ITEM_ENCOMENDA WHERE id_encomenda = ?";
            PreparedStatement statement1 = conn.prepareStatement(sqlItens);
            statement1.setInt(1, idEnc);
            statement1.executeUpdate();

            // depois apagamos a encomenda (apenas se for do próprio cliente)
            String sqlEnc = "DELETE FROM ENCOMENDA WHERE id_encomenda = ? AND id_utilizador = ?";
            PreparedStatement statement2 = conn.prepareStatement(sqlEnc);
            statement2.setInt(1, idEnc);
            statement2.setInt(2, idLogado);
            statement2.executeUpdate();

            response.sendRedirect("pagina_cliente.jsp?secao=encomendas&msg=cancelada");

        } else {
            // se for admin/funcionario muda o estado para

            String sqlUpdate = "UPDATE ENCOMENDA SET estado = 3 WHERE id_encomenda = ?";
            PreparedStatement statement3 = conn.prepareStatement(sqlUpdate);
            statement3.setInt(1, idEnc);
            statement3.executeUpdate();

            if (tipoUser == 1) {
                response.sendRedirect("pagina_admin.jsp?secao=encomendas&msg=cancelada");
            } else {
                response.sendRedirect("pagina_funcionario.jsp?secao=encomendas&msg=cancelada");
            }
        }
    }
%>