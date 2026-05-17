<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    //recebe os dados do formulário
    String utilizador = request.getParameter("username");
    String pass = request.getParameter("password");

    if (conn != null) { //vamos procurar os dados do utilizador e tambem da carteira
        String sql = "SELECT u.*, c.*" +
                "FROM UTILIZADOR u " +
                "LEFT JOIN carteira c ON u.id_utilizador = c.id_utilizador " + //left join para manter os dados de utilizador do admin e funcionario porque não teem carteira
                "WHERE u.username = ? AND u.password = MD5(?)";

        PreparedStatement statement = conn.prepareStatement(sql);
        statement.setString(1, utilizador);
        statement.setString(2, pass);

        ResultSet result = statement.executeQuery();

        // verifica se a base de dados devolveu algum registo (se o username existe e a password está correta)
        if (result.next()) {
            String username = result.getString("username");
            int id_utilizador = result.getInt("id_utilizador");
            int tipoContaId = result.getInt("tipoContaId");
            int validation = result.getInt("validation");
            int id_carteira = result.getInt("id_carteira");
            int tipo_carteiraId = result.getInt("tipoCarteiraId");

            // validation == 1 significa que a conta está aprovada/ativa
            if (validation == 1) {
                // Cria as variáveis de sessão
                session.setAttribute("utilizador", username);
                session.setAttribute("idUtilizador", id_utilizador);
                session.setAttribute("TipoConta", tipoContaId);
                session.setAttribute("autenticado", true);
                session.setAttribute("idCarteira", id_carteira);
                session.setAttribute("tipoCarteiraId", tipo_carteiraId);

                // reencaminha com base no tipo de conta
                if (tipoContaId == 1) {
                    session.setAttribute("user", "Admin");
                    out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>Login efetuado com sucesso!</h1>");
                    response.setHeader("Refresh", "1; URL=pagina_principal.jsp");

                }
                else if (tipoContaId == 2) {
                    session.setAttribute("user", "Funcionario");
                    out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>Login efectuado com sucesso!</h1>");
                    response.setHeader("Refresh", "1; URL=pagina_principal.jsp");

                } else if (tipoContaId == 3) {
                    session.setAttribute("user", "Cliente");
                    out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>Login efectuado com sucesso!</h1>");
                    response.setHeader("Refresh", "1; URL=pagina_principal.jsp");
                }
            }
            // validation == 2 significa que a conta está por aprovar
            else if (validation == 2) {
                out.println("<h1 style='color:orange; text-align:center; margin-top:50px;'>Conta de utilizador desativada, deve aguardar validação do administrador!</h1>");
                response.setHeader("Refresh", "3; URL=pagina_principal.jsp");
            }

        } else {
            //as credenciais estão erradas
            out.println("<h1 style='color:red; text-align:center; margin-top:50px;'>Credenciais incorrectas!</h1>");
            response.setHeader("Refresh", "3; URL=login.jsp");
        }

        result.close();
        statement.close();

    }
%>