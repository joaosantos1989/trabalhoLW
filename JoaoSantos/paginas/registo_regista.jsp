<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    //Recebe os dados do formulário
    String utilizador = request.getParameter("username");
    String pass = request.getParameter("password");
    String email = request.getParameter("email");
    int tipoConta = Integer.parseInt(request.getParameter("tipoContaId"));


    if (conn != null) {
        //verifica se o utilizador já existe
        String sqlCheck = "SELECT * FROM UTILIZADOR WHERE username = ?";
        PreparedStatement statement = conn.prepareStatement(sqlCheck);
        statement.setString(1, utilizador);
        ResultSet result = statement.executeQuery();

        if (result.next()) {
            // Utilizador já existe
            out.println("<h1 style='color:red; text-align:center;'>Erro: O nome de utilizador '" + utilizador + "' já existe!</h1>");
            response.setHeader("Refresh", "3; URL=registo.jsp");
        }
        else {
            //por validar
            int validation = 2;

            Object sessaoTipo = session.getAttribute("TipoConta"); //precisamos de saber se foi o admin a criar novo utilizador
            //se for o admin a criar o utilizador não precisa de validar
            if (sessaoTipo != null && (int)sessaoTipo == 1) {
                validation = 1;
            }

            //insere o novo utilizador
            String sql = "INSERT INTO UTILIZADOR (username, email, password, tipoContaId, validation) VALUES (?, ?, MD5(?), ?, ?)";
            PreparedStatement insert = conn.prepareStatement(sql);

            insert.setString(1, utilizador);
            insert.setString(2, email);
            insert.setString(3, pass);
            insert.setInt(4, tipoConta);
            insert.setInt(5, validation);

            //retorna o numero de linhas afetadas, neste caso 1 se inserir o novo utilizador ou 0 se não introduzir
            if (insert.executeUpdate() > 0) {

                String sqlSearch = "SELECT * FROM UTILIZADOR " +
                        "WHERE username = utilizador AND email = email";
                PreparedStatement search = conn.prepareStatement(sqlSearch);
                ResultSet resultSearch = statement.executeQuery();

                if (resultSearch.next()) {
                    int idEncontrado = resultSearch.getInt("id_utilizador");

                    // Se for um Cliente (tipo 3), criamos a carteira dele
                    if (tipoConta == 3) {
                        String sqlCart = "INSERT INTO carteira (id_utilizador, saldo, tipoCarteiraID) VALUES (?, 0, 1)";
                        PreparedStatement statementCart = conn.prepareStatement(sqlCart);
                        statementCart.setInt(1, idEncontrado);
                        statementCart.executeUpdate();
                        statementCart.close();
                    }
                }

                if (validation == 1) {
                    out.println("<h1 style='color:green; text-align:center;'>Utilizador criado com sucesso!</h1>");
                    response.setHeader("Refresh", "2; URL=pagina_admin.jsp");
                } else {
                    out.println("<h1 style='color:orange; text-align:center;'>Registo efetuado! Aguarde a aprovação do administrador.</h1>");
                    response.setHeader("Refresh", "3; URL=pagina_principal.jsp");
                }
            } else {
                out.println("<h1 style='color:red; text-align:center;'>Erro ao processar o registo.</h1>");
                response.setHeader("Refresh", "3; URL=registo.jsp");
            }

            insert.close();
        }

        result.close();
        statement.close();
    }
%>

