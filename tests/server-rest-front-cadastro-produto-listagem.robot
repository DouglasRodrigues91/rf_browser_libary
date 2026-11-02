*** Settings ***
Documentation    Cadastro de usuario para logar, cadastro de produto e validacao na listagem - Serve Rest Front
Resource         ../resource/server-rest-front_EXERCICIO.resource
Test Teardown    Run Keyword And Ignore Error    Close Browser
Suite Teardown    Close Browser    ALL


*** Test Cases ***
Cenario 02 - Cadastrar novo usuario para logar, cadastrar produto e conferir na listagem
    [Documentation]    Cadastrar novo usuario para logar, cadastrar um novo produto e validar se aparece na listagem de produtos
    [Tags]             usuario    produto    listagem    cadastro    playwright
    Abrir o navegador
    Ir para o site Serve Rest Front
    Cadastrar novo usuario para logar
    Fazer login com usuario cadastrado
    Cadastrar um novo produto
    Conferir que o produto aparece na listagem
