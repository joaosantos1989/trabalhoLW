<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // Verificamos o tipo de conta de quem está a navegar
    int tipoAcesso = 0; // 0 significa visitante/não logado
    if (session.getAttribute("TipoConta") != null) {
        tipoAcesso = (int) session.getAttribute("TipoConta");
    }
%>

<div class="container mt-5 mb-5">
    <div class="row justify-content-center">
        <div class="col-11 col-sm-8 col-md-6 col-lg-4">

            <div class="text-center mb-4">
                <h2 class="fw-bold">Registo</h2>
            </div>

            <!-- Formulário-->
            <form action="registo_regista.jsp" method="POST" class="border p-4 rounded bg-white shadow-sm">

                <div class="mb-3">
                    <label class="form-label small fw-bold">O seu nome de Utilizador:</label>
                    <input type="text" name="username" class="form-control form-control-lg" placeholder="" required>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">A sua Password:</label>
                    <input type="password" name="password" class="form-control form-control-lg" placeholder="" required>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">O seu email:</label>
                    <input type="email" name="email" class="form-control form-control-lg" placeholder="" required>
                </div>
                <%
                    // Se for Admin (1) ou Funcionário (2), mostra a escolha
                    if (tipoAcesso == 1 || tipoAcesso == 2) {
                %>

                <div class="mb-4">
                    <label class="form-label fw-bold">Tipo de Conta</label>
                    <select name="tipoContaId" class="form-select" required>
                        <option value="" selected disabled>Selecione um perfil...</option>
                        <% if (tipoAcesso == 1) { // Só o Admin pode criar outro Admin %>
                        <option value="1">Administrador</option>
                        <% } %>
                        <option value="2">Funcionário</option>
                        <option value="3">Cliente</option>
                    </select>
                </div>
                <%
                } else {
                    // Se for um visitante, o perfil é 3 (Cliente) e fica escondido
                %>
                <input type="hidden" name="tipoContaId" value="3">
                <%
                    }
                %>

                <button type="submit" class="btn btn-success w-100 btn-lg shadow-sm">
                    Registar
                </button>

                <div class="text-center mt-4">
                    <a href="pagina_principal.jsp" class="text-decoration-none small text-success">Voltar</a>
                </div>
            </form>

        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>