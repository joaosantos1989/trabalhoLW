<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%-- alerta de produto adicionado ao carrinho --%>
<% if ("add".equals(request.getParameter("adicionado"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        ✅ Produto adicionado ao carrinho!
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<%-- alerta de encomenda submetida para o funcionário validar --%>
<% if ("pendente".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        <strong>📩 Encomenda Submetida!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<!-- Apresentação de promoções -->
<section class="py-2">
    <div class="container mt-3">
        <div class="card bg-danger text-white shadow-sm border-0">
            <% //procura as promoções na bd
                if (conn != null) {
                    String sql = "SELECT * FROM PROMOCAO WHERE ESTADO = '1'";
                    PreparedStatement statement = conn.prepareStatement(sql);
                    ResultSet result = statement.executeQuery();

                    while(result.next()) {
            %>
            <!-- cartões das promoções -->
            <div class="card-body text-center py-4">
                <h2 class="fw-bold mb-2">🔥 <%= result.getString("titulo") %>🔥</h2>
                <p class="lead mb-0">
                    <%= result.getString("mensagem") %>
                    <br>
                </p>
            </div>
            <%
                    }
                    result.close();
                    statement.close();
                }
            %>
        </div>
    </div>
</section>

<!-- produtos disponiveis -->
<section class="py-2">
    <div class="container px-4 mt-5">

        <!-- tipo de ordenação dos produtos disponiveis -->
        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <h2 class="fw-bold text-success mb-0">Os Nossos Produtos</h2>
            <div class="small">
                <span class="fw-bold me-2">Ordenar por:</span>
                <!-- envia o valor da variavel(ordem) por get -->
                <a href="pagina_principal.jsp?ordem=nome" class="btn btn-sm btn-outline-success">Nome</a>
                <a href="pagina_principal.jsp?ordem=barato" class="btn btn-sm btn-outline-success">Mais Barato</a>
                <a href="pagina_principal.jsp?ordem=caro" class="btn btn-sm btn-outline-success">Mais Caro</a>
            </div>
        </div>

        <div class="row gx-4 row-cols-1 row-cols-md-3 row-cols-xl-4 justify-content-center">

            <%
                if (conn != null) {
                    // recebe a variavel(ordem) com o tipo de ordenação escolhido
                    String ordem = request.getParameter("ordem");

                    String sql = "SELECT * FROM PRODUTO ORDER BY nome ASC";

                    // tipo de query para cada tipo de ordenação
                    if (ordem != null) {
                        if (ordem.equals("barato")) {
                            sql = "SELECT * FROM PRODUTO ORDER BY preco ASC"; //mais barato
                        } else if (ordem.equals("caro")) {
                            sql = "SELECT * FROM PRODUTO ORDER BY preco DESC"; //mais caro
                        } else if (ordem.equals("nome")) {
                            sql = "SELECT * FROM PRODUTO ORDER BY nome ASC"; //ordem alfabetica
                        }
                    }

                    PreparedStatement statement = conn.prepareStatement(sql);
                    ResultSet result = statement.executeQuery();

                    while(result.next()) {
            %>
            <!-- cartões com os produtos disponiveis -->
            <div class="col mb-5">
                <div class="card h-100 shadow-sm border-0 bg-light">
                    <img class="card-img-top" src="https://dummyimage.com/450x300/dee2e6/6c757d.jpg" alt="Imagem" />
                    <div class="card-body p-4 text-center">
                        <h5 class="fw-bolder"><%= result.getString("nome") %></h5>
                        <p class="small text-muted text-truncate"><%= result.getString("descricao") %></p>
                        <span class="text-success fw-bold fs-5"><%= result.getBigDecimal("preco") %>€</span>
                    </div>
                    <div class="card-footer p-4 pt-0 border-top-0 bg-transparent">
                        <div class="text-center">
                            <a class="btn btn-success mt-auto" href="adicionar_carrinho.jsp?id=<%= result.getInt("id_produto") %>">Adicionar</a>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                    result.close();
                    statement.close();
                }
            %>

        </div>
    </div>
</section>

<!-- Apresentação de informações -->
<div class="container mt-4">
    <div class="alert alert-success text-center">
        <strong>📍 Localização:</strong> EST Castelo Branco |
        <strong>📞 Contacto:</strong> 272 339 300 |
        <strong>⏰ Horário:</strong> 08h - 20h
    </div>
</div>

<%@ include file="footer.jsp" %>