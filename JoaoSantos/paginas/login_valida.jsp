<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    //Recebe os dados do formulário
    String utilizador = request.getParameter("username");
    String pass = request.getParameter("password");

    try {
        if (conn != null) {
            String sql = "SELECT * FROM UTILIZADOR WHERE username = ? AND password = MD5(?)";

            //Ao usar setString(), a base de dados é forçada a tratar o conteúdo destas variáveis estritamente como texto normal, nunca como código SQL executável.
            PreparedStatement statement = conn.prepareStatement(sql);
            statement.setString(1, utilizador);
            statement.setString(2, pass);

            ResultSet result = statement.executeQuery();

            // verifica se a base de dados devolveu algum registo (se o username existe e a password está correta)
            if (result.next()) {
                int tipoContaId = result.getInt("tipoContaId");
                int validation = result.getInt("validation");

                // validation == 1 significa que a conta está aprovada/ativa
                if (validation == 1) {
                    // Cria as variáveis de sessão
                    session.setAttribute("utilizador", result.getString("username"));
                    session.setAttribute("TipoConta", tipoContaId);
                    session.setAttribute("autenticado", true);

                    // reencaminha com base no tipo de conta
                    if (tipoContaId == 1) {
                        session.setAttribute("user", "Admin");
                        out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>Login efetuado com sucesso!</h1>");
                        response.setHeader("Refresh", "1; URL=pagina_admin.jsp");

                    } else if (tipoContaId == 2) {
                        session.setAttribute("user", "Funcionario");
                        out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>Login efectuado com sucesso!</h1>");
                        response.setHeader("Refresh", "1; URL=pagina_funcionario.jsp");

                    } else if (tipoContaId == 3) {
                        session.setAttribute("user", "Cliente");
                        out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>Login efectuado com sucesso!</h1>");
                        response.setHeader("Refresh", "1; URL=pagina_cliente.jsp");
                    }
                }
                // validation == 2 significa que a conta está por aprovar
                else if (validation == 2) {
                    out.println("<h1 style='color:orange; text-align:center; margin-top:50px;'>Utilizador registado, deve aguardar por confirmação do admin.</h1>");
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
    } catch (Exception e) {
        out.println("<h1 style='color:red'>Erro na base de dados: " + e.getMessage() + "</h1>");
    }
%>