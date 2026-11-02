*** Settings ***
Documentation    Cadastro de novo usuario e validacao na listagem - Serve Rest Front
Resource         ../resource/server-rest-front_EXERCICIO.resource
Test Teardown    Run Keyword And Ignore Error    Close Browser

*** Test Cases ***
Cenario 01 - Cadastrar novo usuario e conferir na listagem
    [Documentation]    Cadastrar novo usuario com dados dinamicos e validar se aparece na lista de usuarios
    [Tags]             cadastro    listagem    smoke    playwright
    Given Abrir o navegador
    And Ir para o site Serve Rest Front
    When Preencher os dados do novo usuario e cadastrar
    Then Conferir usuario cadastrado com sucesso
    And Acessar a Lista de usuarios
    And Conferir que o usuario aparece na listagem    ${EMAIL}

Cenario 02 - Cadastrar novo usuario para logar, cadastrar produto e conferir na listagem
    [Documentation]    Cadastrar novo usuario para logar, cadastrar um novo produto e validar se aparece na listagem de produtos
    [Tags]             usuario    produto    listagem    cadastro    playwright
    Given Abrir o navegador
    And Ir para o site Serve Rest Front
    When Cadastrar novo usuario para logar
    And Fazer login com usuario cadastrado
    And Cadastrar um novo produto
    Then Conferir que o produto aparece na listagem